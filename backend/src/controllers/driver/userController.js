import { knex } from '../../config/database.js';
import bcrypt from 'bcrypt';
import { createPostResponse } from '../../utils/responseHelper.js';

// Get all users with optional filters
export const getAllUsers = async (req, res) => {
  try {
    const { role, status, verified, search } = req.query;
    
    let queryBuilder = knex('users as u')
      .select(
        'u.*',
        'd.vehicle_type', 'd.vehicle_model', 'd.license_plate', 
        'd.available', 'd.verification_status'
      )
      .leftJoin('drivers as d', 'u.id', 'd.user_id');

    if (role && role !== 'all') {
      queryBuilder = queryBuilder.where('u.role', role);
    }

    if (status && status !== 'all') {
      queryBuilder = queryBuilder.where('u.status', status);
    }

    if (verified && verified !== 'all') {
      queryBuilder = queryBuilder.where('u.verified', verified === 'verified');
    }

    if (search) {
      queryBuilder = queryBuilder.where(function() {
        this.where('u.name', 'ilike', `%${search}%`)
            .orWhere('u.email', 'ilike', `%${search}%`);
      });
    }

    queryBuilder = queryBuilder.orderBy('u.created_at', 'desc');

    const result = await queryBuilder;
    
    res.json({
      success: true,
      data: result,
      count: result.length
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching users',
      error: error.message
    });
  }
};

// Get user by ID
export const getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const user = await knex('users as u')
      .select(
        'u.*',
        'd.vehicle_type', 'd.vehicle_model', 'd.license_plate', 
        'd.available', 'd.license_number', 'd.vehicle_year'
      )
      .leftJoin('drivers as d', 'u.id', 'd.user_id')
      .where('u.id', id)
      .first();

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching user',
      error: error.message
    });
  }
};

// Create new user
export const createUser = async (req, res) => {
  try {
    const {
      name, email, password, phone, location, role,
      vehicle_type, vehicle_model, license_plate, license_number, vehicle_year
    } = req.body;

    // Check if email already exists
    const existingUser = await knex('users')
      .select('id')
      .where('email', email)
      .first();
      
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already exists'
      });
    }

    // Hash password before storing
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    const [newUser] = await knex('users')
      .insert({
        name,
        email,
        password: hashedPassword,
        phone,
        location,
        role: role || 'Rider'
      })
      .returning('*');

    // If driver, insert driver details
    if (role === 'Driver' && vehicle_type) {
      await knex('drivers').insert({
        user_id: newUser.id,
        vehicle_type,
        vehicle_model,
        license_plate,
        license_number,
        vehicle_year
      });
    }

    res.status(201).json(createPostResponse({
      success: true,
      message: 'User created successfully',
      data: newUser,
      requestBody: req.body
    }));
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json(createPostResponse({
      success: false,
      message: 'Error creating user',
      data: {
        error: error.message
      },
      requestBody: req.body
    }));
  }
};

// Update user
export const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name, email, phone, location, status, verified, rating,
      vehicle_type, vehicle_model, license_plate, license_number, vehicle_year
    } = req.body;

    // Check if user exists
    const user = await knex('users')
      .select('*')
      .where('id', id)
      .first();
      
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Build update object dynamically
    const updates = {};
    
    if (name !== undefined) updates.name = name;
    if (email !== undefined) updates.email = email;
    if (phone !== undefined) updates.phone = phone;
    if (location !== undefined) updates.location = location;
    if (status !== undefined) updates.status = status;
    if (verified !== undefined) updates.verified = verified;
    if (rating !== undefined) updates.rating = rating;
    
    updates.updated_at = knex.fn.now();

    const [updatedUser] = await knex('users')
      .where('id', id)
      .update(updates)
      .returning('*');

    // Update driver details if applicable
    if (user.role === 'Driver' && (vehicle_type || vehicle_model || license_plate)) {
      const driverUpdates = {};
      
      if (vehicle_type !== undefined) driverUpdates.vehicle_type = vehicle_type;
      if (vehicle_model !== undefined) driverUpdates.vehicle_model = vehicle_model;
      if (license_plate !== undefined) driverUpdates.license_plate = license_plate;
      if (license_number !== undefined) driverUpdates.license_number = license_number;
      if (vehicle_year !== undefined) driverUpdates.vehicle_year = vehicle_year;

      if (Object.keys(driverUpdates).length > 0) {
        driverUpdates.updated_at = knex.fn.now();
        
        await knex('drivers')
          .where('user_id', id)
          .update(driverUpdates);
      }
    }

    res.json({
      success: true,
      message: 'User updated successfully',
      data: updatedUser
    });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating user',
      error: error.message
    });
  }
};

// Delete user
export const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    const [deletedUser] = await knex('users')
      .where('id', id)
      .del()
      .returning('*');

    if (!deletedUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      message: 'User deleted successfully',
      data: deletedUser
    });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting user',
      error: error.message
    });
  }
};

// Get user statistics
export const getUserStats = async (req, res) => {
  try {
    const stats = await knex('users')
      .select(
        knex.raw("COUNT(*) FILTER (WHERE role = 'Rider') as total_riders"),
        knex.raw("COUNT(*) FILTER (WHERE role = 'Driver') as total_drivers"),
        knex.raw("COUNT(*) FILTER (WHERE status = 'Active') as active_users"),
        knex.raw("COUNT(*) FILTER (WHERE status = 'Pending') as pending_users"),
        knex.raw("COUNT(*) FILTER (WHERE status = 'Suspended') as suspended_users"),
        knex.raw("COUNT(*) FILTER (WHERE verified = true) as verified_users"),
        knex.raw("AVG(rating) FILTER (WHERE role = 'Driver') as avg_driver_rating")
      )
      .first();

    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Error fetching user stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching user statistics',
      error: error.message
    });
  }
};
