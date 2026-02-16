import { knex } from '../../config/database.js';
import { createPostResponse } from '../../utils/responseHelper.js';

// Get all settings
export const getAllSettings = async (req, res) => {
  try {
    const { category } = req.query;
    
    let queryBuilder = knex('settings');

    if (category && category !== 'all') {
      queryBuilder = queryBuilder.where('category', category);
    }

    const result = await queryBuilder.orderBy(['category', 'key']);
    
    res.json({
      success: true,
      data: result,
      count: result.length
    });
  } catch (error) {
    console.error('Error fetching settings:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching settings',
      error: error.message
    });
  }
};

// Get setting by key
export const getSettingByKey = async (req, res) => {
  try {
    const { key } = req.params;
    
    const result = await knex('settings')
      .where('key', key)
      .first();

    if (!result) {
      return res.status(404).json({
        success: false,
        message: 'Setting not found'
      });
    }

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error fetching setting:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching setting',
      error: error.message
    });
  }
};

// Create new setting
export const createSetting = async (req, res) => {
  try {
    const { key, value, category, description } = req.body;

    if (!key || !value) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: key, value'
      });
    }

    // Check if key already exists
    const existing = await knex('settings')
      .where('key', key)
      .select('id')
      .first();
      
    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'Setting with this key already exists'
      });
    }

    const [setting] = await knex('settings')
      .insert({ key, value, category, description })
      .returning('*');

    res.status(201).json(createPostResponse({
      success: true,
      message: 'Setting created successfully',
      data: setting,
      requestBody: req.body
    }));
  } catch (error) {
    console.error('Error creating setting:', error);
    res.status(500).json(createPostResponse({
      success: false,
      message: 'Error creating setting',
      data: {
        error: error.message
      },
      requestBody: req.body
    }));
  }
};

// Update setting
export const updateSetting = async (req, res) => {
  try {
    const { key } = req.params;
    const { value, category, description } = req.body;

    const updates = { updated_at: knex.fn.now() };

    if (value !== undefined) {
      updates.value = value;
    }
    if (category !== undefined) {
      updates.category = category;
    }
    if (description !== undefined) {
      updates.description = description;
    }

    if (Object.keys(updates).length === 1) {
      return res.status(400).json({
        success: false,
        message: 'No fields to update'
      });
    }

    const result = await knex('settings')
      .where('key', key)
      .update(updates)
      .returning('*');

    if (result.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Setting not found'
      });
    }

    res.json({
      success: true,
      message: 'Setting updated successfully',
      data: result[0]
    });
  } catch (error) {
    console.error('Error updating setting:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating setting',
      error: error.message
    });
  }
};

// Delete setting
export const deleteSetting = async (req, res) => {
  try {
    const { key } = req.params;

    const result = await knex('settings')
      .where('key', key)
      .del()
      .returning('*');

    if (result.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Setting not found'
      });
    }

    res.json({
      success: true,
      message: 'Setting deleted successfully',
      data: result[0]
    });
  } catch (error) {
    console.error('Error deleting setting:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting setting',
      error: error.message
    });
  }
};

// Bulk update settings
export const bulkUpdateSettings = async (req, res) => {
  try {
    const { settings } = req.body;

    if (!Array.isArray(settings) || settings.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid settings array'
      });
    }

    const updated = [];
    for (const setting of settings) {
      if (setting.key && setting.value !== undefined) {
        const result = await knex('settings')
          .where('key', setting.key)
          .update({
            value: setting.value,
            updated_at: knex.fn.now()
          })
          .returning('*');
        
        if (result.length > 0) {
          updated.push(result[0]);
        }
      }
    }

    res.json(createPostResponse({
      success: true,
      message: `${updated.length} settings updated successfully`,
      data: updated,
      requestBody: req.body
    }));
  } catch (error) {
    console.error('Error bulk updating settings:', error);
    res.status(500).json(createPostResponse({
      success: false,
      message: 'Error bulk updating settings',
      data: {
        error: error.message
      },
      requestBody: req.body
    }));
  }
};
