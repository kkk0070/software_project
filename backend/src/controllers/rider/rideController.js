import { knex } from '../../config/database.js';
import { sendNotificationToUser } from '../../services/socketService.js';

// Get all rides with filters
export const getAllRides = async (req, res) => {
  try {
    const { status, ride_type, from_date, to_date } = req.query;
    
    let queryBuilder = knex('rides as r')
      .select(
        'r.*',
        'rider.name as rider_name', 'rider.email as rider_email', 'rider.phone as rider_phone',
        'driver.name as driver_name', 'driver.email as driver_email', 'driver.phone as driver_phone',
        'd.vehicle_type', 'd.vehicle_model', 'd.license_plate'
      )
      .leftJoin('users as rider', 'r.rider_id', 'rider.id')
      .leftJoin('users as driver', 'r.driver_id', 'driver.id')
      .leftJoin('drivers as d', 'driver.id', 'd.user_id');

    if (status && status !== 'all') {
      queryBuilder = queryBuilder.where('r.status', status);
    }

    if (ride_type && ride_type !== 'all') {
      queryBuilder = queryBuilder.where('r.ride_type', ride_type);
    }

    if (from_date) {
      queryBuilder = queryBuilder.where('r.created_at', '>=', from_date);
    }

    if (to_date) {
      queryBuilder = queryBuilder.where('r.created_at', '<=', to_date);
    }

    queryBuilder = queryBuilder.orderBy('r.created_at', 'desc');

    const result = await queryBuilder;
    
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

// Get ride by ID
export const getRideById = async (req, res) => {
  try {
    const { id } = req.params;
    
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
      .first();

    if (!ride) {
      return res.status(404).json({
        success: false,
        message: 'Ride not found'
      });
    }

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

// Create new ride
export const createRide = async (req, res) => {
  try {
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

    res.status(201).json({
      success: true,
      message: 'Ride created successfully and driver notified',
      data: ride
    });
  } catch (error) {
    console.error('Error creating ride:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating ride',
      error: error.message
    });
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
