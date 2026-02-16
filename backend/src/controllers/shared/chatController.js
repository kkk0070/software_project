import { knex } from '../../config/database.js';
import { createPostResponse } from '../../utils/responseHelper.js';
import { sendNotificationToUser } from '../../services/socketService.js';

// Constants
const MESSAGE_PREVIEW_LENGTH = 50;

// Get all conversations for a user
export const getConversations = async (req, res) => {
  try {
    const userId = req.user?.id || req.query.userId;
    
    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    const result = await knex('conversations as c')
      .select(
        'c.*',
        knex.raw(`
          CASE 
            WHEN c.rider_id = ? THEN u_driver.name
            ELSE u_rider.name
          END as other_user_name
        `, [userId]),
        knex.raw(`
          CASE 
            WHEN c.rider_id = ? THEN u_driver.id
            ELSE u_rider.id
          END as other_user_id
        `, [userId]),
        knex.raw(`
          CASE 
            WHEN c.rider_id = ? THEN u_driver.role
            ELSE u_rider.role
          END as other_user_role
        `, [userId]),
        knex.raw(`
          (SELECT COUNT(*) FROM messages 
           WHERE conversation_id = c.id 
           AND receiver_id = ? 
           AND is_read = false) as unread_count
        `, [userId])
      )
      .leftJoin('users as u_rider', 'c.rider_id', 'u_rider.id')
      .leftJoin('users as u_driver', 'c.driver_id', 'u_driver.id')
      .where(function() {
        this.where('c.rider_id', userId).orWhere('c.driver_id', userId);
      })
      .orderByRaw('c.last_message_time DESC NULLS LAST, c.created_at DESC');

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error fetching conversations:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching conversations',
      error: error.message
    });
  }
};

// Get or create a conversation between two users
export const getOrCreateConversation = async (req, res) => {
  try {
    const { riderId, driverId, rideId } = req.body;
    
    if (!riderId || !driverId) {
      return res.status(400).json({
        success: false,
        message: 'Rider ID and Driver ID are required'
      });
    }

    // Check if conversation already exists
    let conversation = await knex('conversations')
      .where({ rider_id: riderId, driver_id: driverId })
      .first();

    if (conversation) {
      return res.json(createPostResponse({
        success: true,
        message: 'Conversation already exists',
        data: conversation,
        requestBody: req.body
      }));
    }

    // Create new conversation
    [conversation] = await knex('conversations')
      .insert({
        rider_id: riderId,
        driver_id: driverId,
        ride_id: rideId || null
      })
      .returning('*');

    res.status(201).json(createPostResponse({
      success: true,
      message: 'Conversation created successfully',
      data: conversation,
      requestBody: req.body
    }));
  } catch (error) {
    console.error('Error creating conversation:', error);
    res.status(500).json(createPostResponse({
      success: false,
      message: 'Error creating conversation',
      data: {
        error: error.message
      },
      requestBody: req.body
    }));
  }
};

// Get messages for a conversation
export const getMessages = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    const messages = await knex('messages as m')
      .select(
        'm.*',
        'u_sender.name as sender_name',
        'u_sender.role as sender_role'
      )
      .join('users as u_sender', 'm.sender_id', 'u_sender.id')
      .where('m.conversation_id', conversationId)
      .orderBy('m.created_at', 'desc')
      .limit(limit)
      .offset(offset);

    res.json({
      success: true,
      data: messages.reverse() // Reverse to show oldest first
    });
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching messages',
      error: error.message
    });
  }
};

// Send a message
export const sendMessage = async (req, res) => {
  try {
    const { conversationId, senderId, receiverId, message } = req.body;

    if (!conversationId || !senderId || !receiverId || !message) {
      return res.status(400).json({
        success: false,
        message: 'Conversation ID, sender ID, receiver ID, and message are required'
      });
    }

    // Get sender and receiver information
    const [sender, receiver] = await Promise.all([
      knex('users').where('id', senderId).first(),
      knex('users').where('id', receiverId).first()
    ]);

    // Insert message
    const [newMessage] = await knex('messages')
      .insert({
        conversation_id: conversationId,
        sender_id: senderId,
        receiver_id: receiverId,
        message
      })
      .returning('*');

    // Update conversation last_message
    await knex('conversations')
      .where('id', conversationId)
      .update({
        last_message: message,
        last_message_time: knex.fn.now(),
        updated_at: knex.fn.now()
      });

    // Create notification for the receiver if they are a driver
    if (receiver && receiver.role === 'Driver') {
      try {
        const senderName = sender ? sender.name : 'User';
        const notificationTitle = 'New Message';
        const notificationMessage = `${senderName}: ${message.substring(0, MESSAGE_PREVIEW_LENGTH)}${message.length > MESSAGE_PREVIEW_LENGTH ? '...' : ''}`;
        
        // Insert notification into database
        const [notification] = await knex('notifications')
          .insert({
            user_id: receiverId,
            title: notificationTitle,
            message: notificationMessage,
            type: 'Info',
            category: 'Message',
            conversation_id: conversationId,
            sender_id: senderId
          })
          .returning('*');

        // Send real-time notification via WebSocket
        try {
          sendNotificationToUser(receiverId, {
            id: notification.id,
            title: notificationTitle,
            message: notificationMessage,
            type: 'Info',
            category: 'Message',
            conversation_id: conversationId,
            sender_id: senderId,
            created_at: notification.created_at
          });
        } catch (socketError) {
          console.error('Error sending WebSocket notification:', socketError);
          // Continue even if WebSocket fails
        }
      } catch (notificationError) {
        console.error('Error creating notification:', notificationError);
        // Continue even if notification creation fails
      }
    }

    res.status(201).json(createPostResponse({
      success: true,
      message: 'Message sent successfully',
      data: newMessage,
      requestBody: req.body
    }));
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json(createPostResponse({
      success: false,
      message: 'Error sending message',
      data: {
        error: error.message
      },
      requestBody: req.body
    }));
  }
};

// Mark messages as read
export const markAsRead = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const userId = req.user?.id || req.body.userId;

    await knex('messages')
      .where('conversation_id', conversationId)
      .where('receiver_id', userId)
      .where('is_read', false)
      .update({ is_read: true });

    res.json({
      success: true,
      message: 'Messages marked as read'
    });
  } catch (error) {
    console.error('Error marking messages as read:', error);
    res.status(500).json({
      success: false,
      message: 'Error marking messages as read',
      error: error.message
    });
  }
};

// Get unread message count
export const getUnreadCount = async (req, res) => {
  try {
    const userId = req.user?.id || req.query.userId;

    const result = await knex('messages')
      .where('receiver_id', userId)
      .where('is_read', false)
      .count('* as unread_count')
      .first();

    res.json({
      success: true,
      data: { unread_count: parseInt(result.unread_count) }
    });
  } catch (error) {
    console.error('Error fetching unread count:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching unread count',
      error: error.message
    });
  }
};
