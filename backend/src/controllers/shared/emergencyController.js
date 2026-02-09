import { knex } from '../../config/database.js';

// Get all emergency incidents
export const getAllIncidents = async (req, res) => {
  try {
    const { status, priority } = req.query;
    
    let queryBuilder = knex('emergency_incidents as e')
      .select(
        'e.*',
        'u.name as user_name',
        'u.email as user_email',
        'u.phone as user_phone',
        'r.pickup_location',
        'r.dropoff_location'
      )
      .leftJoin('users as u', 'e.user_id', 'u.id')
      .leftJoin('rides as r', 'e.ride_id', 'r.id');

    if (status && status !== 'all') {
      queryBuilder = queryBuilder.where('e.status', status);
    }

    if (priority && priority !== 'all') {
      queryBuilder = queryBuilder.where('e.priority', priority);
    }

    const result = await queryBuilder.orderBy('e.created_at', 'desc');
    
    res.json({
      success: true,
      data: result,
      count: result.length
    });
  } catch (error) {
    console.error('Error fetching incidents:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching incidents',
      error: error.message
    });
  }
};

// Create incident
export const createIncident = async (req, res) => {
  try {
    const {
      ride_id, user_id, incident_type, description,
      location, latitude, longitude, priority
    } = req.body;

    const [incident] = await knex('emergency_incidents')
      .insert({
        ride_id,
        user_id,
        incident_type,
        description,
        location,
        latitude,
        longitude,
        priority: priority || 'Medium',
        status: 'Open'
      })
      .returning('*');

    res.status(201).json({
      success: true,
      message: 'Incident created successfully',
      data: incident
    });
  } catch (error) {
    console.error('Error creating incident:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating incident',
      error: error.message
    });
  }
};

// Update incident
export const updateIncident = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, priority, resolved_at } = req.body;

    const updates = { updated_at: knex.fn.now() };

    if (status !== undefined) {
      updates.status = status;
      
      if (status === 'Resolved' && !resolved_at) {
        updates.resolved_at = knex.fn.now();
      }
    }
    if (priority !== undefined) {
      updates.priority = priority;
    }
    if (resolved_at !== undefined) {
      updates.resolved_at = resolved_at;
    }

    if (Object.keys(updates).length === 1) {
      return res.status(400).json({
        success: false,
        message: 'No fields to update'
      });
    }

    const result = await knex('emergency_incidents')
      .where('id', id)
      .update(updates)
      .returning('*');

    if (result.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Incident not found'
      });
    }

    res.json({
      success: true,
      message: 'Incident updated successfully',
      data: result[0]
    });
  } catch (error) {
    console.error('Error updating incident:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating incident',
      error: error.message
    });
  }
};

// Delete incident
export const deleteIncident = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await knex('emergency_incidents')
      .where('id', id)
      .del()
      .returning('*');

    if (result.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Incident not found'
      });
    }

    res.json({
      success: true,
      message: 'Incident deleted successfully',
      data: result[0]
    });
  } catch (error) {
    console.error('Error deleting incident:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting incident',
      error: error.message
    });
  }
};
