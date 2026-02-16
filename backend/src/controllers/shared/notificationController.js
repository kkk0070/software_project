import { knex } from '../../config/database.js';
import { sendNotificationToUser, broadcastNotificationToUsers } from '../../services/socketService.js';
import { createPostResponse } from '../../utils/responseHelper.js';

// Get all notifications with filters
export const getAllNotifications = async (req, res) => {
  try {
    const { user_id, type, category, read, limit = 50 } = req.query;
    
    let queryBuilder = knex('notifications as n')
      .select('n.*', 'u.name as user_name', 'u.email as user_email')
      .innerJoin('users as u', 'n.user_id', 'u.id');

    if (user_id) {
      queryBuilder = queryBuilder.where('n.user_id', user_id);
    }

    if (type && type !== 'all') {
      queryBuilder = queryBuilder.where('n.type', type);
    }

    if (category && category !== 'all') {
      queryBuilder = queryBuilder.where('n.category', category);
    }

    if (read !== undefined && read !== 'all') {
      queryBuilder = queryBuilder.where('n.read', read === 'true');
    }

    const result = await queryBuilder.orderBy('n.created_at', 'desc').limit(limit);
    
    res.json({
      success: true,
      data: result,
      count: result.length
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching notifications',
      error: error.message
    });
  }
};

// Create new notification
export const createNotification = async (req, res) => {
  try {
    const { user_id, title, message, type, category } = req.body;

    if (!user_id || !title || !message) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: user_id, title, message'
      });
    }

    const [notification] = await knex('notifications')
      .insert({
        user_id,
        title,
        message,
        type: type || 'Info',
        category: category || 'General'
      })
      .returning('*');

    // Send real-time notification via WebSocket
    try {
      sendNotificationToUser(user_id, {
        id: notification.id,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        category: notification.category,
        created_at: notification.created_at
      });
    } catch (socketError) {
      console.error('Error sending WebSocket notification:', socketError);
      // Continue even if WebSocket fails
    }

    res.status(201).json(createPostResponse({
      success: true,
      message: 'Notification created successfully',
      data: notification,
      requestBody: req.body
    }));
  } catch (error) {
    console.error('Error creating notification:', error);
    res.status(500).json(createPostResponse({
      success: false,
      message: 'Error creating notification',
      data: {
        error: error.message
      },
      requestBody: req.body
    }));
  }
};

// Broadcast notification to multiple users
export const broadcastNotification = async (req, res) => {
  try {
    const { title, message, type, category, user_filters } = req.body;

    if (!title || !message) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: title, message'
      });
    }

    // Build user query based on filters
    let userQuery = knex('users').select('id');

    if (user_filters) {
      if (user_filters.role && user_filters.role !== 'all') {
        userQuery = userQuery.where('role', user_filters.role);
      }
      if (user_filters.status && user_filters.status !== 'all') {
        userQuery = userQuery.where('status', user_filters.status);
      }
    }

    const users = await userQuery;

    // Create notification for each user
    const notifications = [];
    const userIds = [];
    for (const user of users) {
      const [notification] = await knex('notifications')
        .insert({
          user_id: user.id,
          title,
          message,
          type: type || 'Info',
          category: category || 'General'
        })
        .returning('*');
      
      notifications.push(notification);
      userIds.push(user.id);
    }

    // Broadcast real-time notification via WebSocket
    try {
      broadcastNotificationToUsers(userIds, {
        title,
        message,
        type: type || 'Info',
        category: category || 'General',
        created_at: new Date()
      });
    } catch (socketError) {
      console.error('Error broadcasting WebSocket notification:', socketError);
      // Continue even if WebSocket fails
    }

    res.status(201).json(createPostResponse({
      success: true,
      message: `Notification broadcast to ${notifications.length} users`,
      data: {
        count: notifications.length,
        sample: notifications[0]
      },
      requestBody: req.body
    }));
  } catch (error) {
    console.error('Error broadcasting notification:', error);
    res.status(500).json(createPostResponse({
      success: false,
      message: 'Error broadcasting notification',
      data: {
        error: error.message
      },
      requestBody: req.body
    }));
  }
};

// Mark notification as read
export const markAsRead = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await knex('notifications')
      .where('id', id)
      .update({ read: true })
      .returning('*');

    if (result.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    res.json({
      success: true,
      message: 'Notification marked as read',
      data: result[0]
    });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({
      success: false,
      message: 'Error marking notification as read',
      error: error.message
    });
  }
};

// Delete notification
export const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await knex('notifications')
      .where('id', id)
      .del()
      .returning('*');

    if (result.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    res.json({
      success: true,
      message: 'Notification deleted successfully',
      data: result[0]
    });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting notification',
      error: error.message
    });
  }
};

// Get notification statistics
export const getNotificationStats = async (req, res) => {
  try {
    const stats = await knex('notifications')
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '30 days'"))
      .select(
        knex.raw('COUNT(*) as total_notifications'),
        knex.raw("COUNT(*) FILTER (WHERE read = true) as read_notifications"),
        knex.raw("COUNT(*) FILTER (WHERE read = false) as unread_notifications"),
        knex.raw("COUNT(*) FILTER (WHERE type = 'Info') as info_count"),
        knex.raw("COUNT(*) FILTER (WHERE type = 'Warning') as warning_count"),
        knex.raw("COUNT(*) FILTER (WHERE type = 'Error') as error_count"),
        knex.raw("COUNT(*) FILTER (WHERE type = 'Success') as success_count")
      )
      .first();

    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Error fetching notification stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching notification statistics',
      error: error.message
    });
  }
};

// Delete all notifications for a user
export const deleteAllNotifications = async (req, res) => {
  try {
    const { user_id } = req.query;

    if (!user_id) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    const result = await knex('notifications')
      .where('user_id', user_id)
      .del()
      .returning('*');

    res.json({
      success: true,
      message: `Deleted ${result.length} notification(s)`,
      data: {
        count: result.length
      }
    });
  } catch (error) {
    console.error('Error deleting all notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting notifications',
      error: error.message
    });
  }
};
