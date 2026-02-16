// Knex query builder for database operations
import { knex } from '../../config/database.js';
// Socket.io service for real-time notifications
import { sendNotificationToUser } from '../../services/socketService.js';
// Response helper for including request body in responses
import { createPostResponse } from '../../utils/responseHelper.js';

/**
 * Get all rides with optional filtering
 * Supports filtering by status, ride type, and date range
 * Returns rides with joined rider, driver, and vehicle information
 */
export const getAllRides = async (req, res) => {
  try {
    // Extract query parameters for filtering
    const { status, ride_type, from_date, to_date } = req.query;
    
    // Build complex query joining rides with users (riders/drivers) and vehicles
    let queryBuilder = knex('rides as r')
      .select(
        'r.*',  // All ride fields
        // Rider information
        'rider.name as rider_name', 'rider.email as rider_email', 'rider.phone as rider_phone',
        // Driver information
        'driver.name as driver_name', 'driver.email as driver_email', 'driver.phone as driver_phone',
        // Vehicle information
        'd.vehicle_type', 'd.vehicle_model', 'd.license_plate'
      )
      // Left join to include rides even if rider/driver data is missing
      .leftJoin('users as rider', 'r.rider_id', 'rider.id')
      .leftJoin('users as driver', 'r.driver_id', 'driver.id')
      .leftJoin('drivers as d', 'driver.id', 'd.user_id');

    // Apply status filter if provided and not 'all'
    if (status && status !== 'all') {
      queryBuilder = queryBuilder.where('r.status', status);
    }

    // Apply ride type filter (solo, carpool, etc.)
    if (ride_type && ride_type !== 'all') {
      queryBuilder = queryBuilder.where('r.ride_type', ride_type);
    }

    // Apply date range filters for analytics
    if (from_date) {
      // Get rides created on or after this date
      queryBuilder = queryBuilder.where('r.created_at', '>=', from_date);
    }

    if (to_date) {
      // Get rides created on or before this date
      queryBuilder = queryBuilder.where('r.created_at', '<=', to_date);
    }

    // Sort by most recent rides first
    queryBuilder = queryBuilder.orderBy('r.created_at', 'desc');

    // Execute the query
    const result = await queryBuilder;
    
    // Return rides with count for pagination
    res.json({
      success: true,
      data: result,
      count: result.length
    });
  } catch (error) {
    console.error('Error fetching rides:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching rides',
      error: error.message
    });
  }
};

/**
 * Get detailed information for a specific ride by ID
 * Includes rider, driver, and vehicle details
 */
export const getRideById = async (req, res) => {
  try {
    // Extract ride ID from URL parameters
    const { id } = req.params;
    
    // Query ride with joined information, return only first match
    const ride = await knex('rides as r')
      .select(
        'r.*',
        'rider.name as rider_name', 'rider.email as rider_email', 'rider.phone as rider_phone',
        'driver.name as driver_name', 'driver.email as driver_email', 'driver.phone as driver_phone',
        'd.vehicle_type', 'd.vehicle_model', 'd.license_plate'
      )
      .leftJoin('users as rider', 'r.rider_id', 'rider.id')
      .leftJoin('users as driver', 'r.driver_id', 'driver.id')
      .leftJoin('drivers as d', 'driver.id', 'd.user_id')
      .where('r.id', id)
      .first(); // Get only first result (ride IDs are unique)

    // Check if ride exists
    if (!ride) {
      return res.status(404).json({
        success: false,
        message: 'Ride not found'
      });
    }

    // Return ride details
    res.json({
      success: true,
      data: ride
    });
  } catch (error) {
    console.error('Error fetching ride:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching ride',
      error: error.message
    });
  }
};

/**
 * Create a new ride booking
 * Handles both immediate and scheduled rides
 */
export const createRide = async (req, res) => {
  try {
    // Extract ride details from request body
    const {
      rider_id, driver_id, pickup_location, dropoff_location,
      pickup_lat, pickup_lng, dropoff_lat, dropoff_lng,
      ride_type, fare, distance, scheduled_time
    } = req.body;

    const [ride] = await knex('rides')
      .insert({
        rider_id,
        driver_id,
        pickup_location,
        dropoff_location,
        pickup_lat,
        pickup_lng,
        dropoff_lat,
        dropoff_lng,
        ride_type,
        fare,
        distance,
        scheduled_time,
        status: 'Pending'
      })
      .returning('*');

    // Get rider and driver information
    const userInfo = await knex('users')
      .select('id', 'name', 'email')
      .whereIn('id', [rider_id, driver_id]);

    const riderInfo = userInfo.find(u => u.id === rider_id);
    const driverInfo = userInfo.find(u => u.id === driver_id);

    const riderName = riderInfo?.name || 'Rider';
    const driverName = driverInfo?.name || 'Driver';

    // Create notification in database for the driver
    const [notification] = await knex('notifications')
      .insert({
        user_id: driver_id,
        title: 'New Ride Booking',
        message: `${riderName} has booked a ride with you from ${pickup_location} to ${dropoff_location}`,
        type: 'Info',
        category: 'Ride'
      })
      .returning('*');

    // Send real-time notification via WebSocket
    try {
      sendNotificationToUser(driver_id, {
        id: notification.id,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        category: notification.category,
        ride_id: ride.id,
        rider_name: riderName,
        pickup_location,
        dropoff_location,
        created_at: notification.created_at
      });
    } catch (socketError) {
      console.error('Error sending WebSocket notification:', socketError);
      // Continue even if WebSocket fails - notification is still in database
    }

    res.status(201).json(createPostResponse({
      success: true,
      message: 'Ride created successfully and driver notified',
      data: ride,
      requestBody: req.body
    }));
  } catch (error) {
    console.error('Error creating ride:', error);
    res.status(500).json(createPostResponse({
      success: false,
      message: 'Error creating ride',
      data: {
        error: error.message
      },
      requestBody: req.body
    }));
  }
};

// Update ride
export const updateRide = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      status, driver_id, fare, distance, duration, 
      carbon_saved, rating, started_at, completed_at
    } = req.body;

    const updates = { updated_at: knex.fn.now() };

    if (status !== undefined) updates.status = status;
    if (driver_id !== undefined) updates.driver_id = driver_id;
    if (fare !== undefined) updates.fare = fare;
    if (distance !== undefined) updates.distance = distance;
    if (duration !== undefined) updates.duration = duration;
    if (carbon_saved !== undefined) updates.carbon_saved = carbon_saved;
    if (rating !== undefined) updates.rating = rating;
    if (started_at !== undefined) updates.started_at = started_at;
    if (completed_at !== undefined) updates.completed_at = completed_at;

    if (Object.keys(updates).length === 1) {
      return res.status(400).json({
        success: false,
        message: 'No fields to update'
      });
    }

    const result = await knex('rides')
      .where('id', id)
      .update(updates)
      .returning('*');

    if (result.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Ride not found'
      });
    }

    res.json({
      success: true,
      message: 'Ride updated successfully',
      data: result[0]
    });
  } catch (error) {
    console.error('Error updating ride:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating ride',
      error: error.message
    });
  }
};

// Delete ride
export const deleteRide = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await knex('rides')
      .where('id', id)
      .del()
      .returning('*');

    if (result.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Ride not found'
      });
    }

    res.json({
      success: true,
      message: 'Ride deleted successfully',
      data: result[0]
    });
  } catch (error) {
    console.error('Error deleting ride:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting ride',
      error: error.message
    });
  }
};

// Get ride statistics
export const getRideStats = async (req, res) => {
  try {
    const stats = await knex('rides')
      .select(
        knex.raw('COUNT(*) as total_rides'),
        knex.raw("COUNT(*) FILTER (WHERE status = 'Active') as active_rides"),
        knex.raw("COUNT(*) FILTER (WHERE status = 'Completed') as completed_rides"),
        knex.raw("COUNT(*) FILTER (WHERE status = 'Cancelled') as cancelled_rides"),
        knex.raw("COUNT(*) FILTER (WHERE ride_type = 'EV') as ev_rides"),
        knex.raw("COUNT(*) FILTER (WHERE ride_type = 'Pool') as pool_rides"),
        knex.raw('AVG(fare) as avg_fare'),
        knex.raw('AVG(distance) as avg_distance'),
        knex.raw('AVG(rating) as avg_rating'),
        knex.raw('SUM(carbon_saved) as total_carbon_saved')
      )
      .first();

    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Error fetching ride stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching ride statistics',
      error: error.message
    });
  }
};
