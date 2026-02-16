import express from 'express';
import {
  getAllNotifications,
  createNotification,
  broadcastNotification,
  markAsRead,
  deleteNotification,
  deleteAllNotifications,
  getNotificationStats
} from '../../controllers/shared/notificationController.js';
import { getConnectedUsers, isUserConnected } from '../../services/socketService.js';

const router = express.Router();

// WebSocket status endpoint
router.get('/websocket/status', (req, res) => {
  try {
    const connectedUsers = getConnectedUsers();
    res.json({
      success: true,
      data: {
        websocket_enabled: true,
        connected_users: connectedUsers.length,
        user_ids: connectedUsers
      }
    });
  } catch (error) {
    res.json({
      success: false,
      websocket_enabled: false,
      message: error.message
    });
  }
});

// Check if specific user is connected
router.get('/websocket/user/:userId', (req, res) => {
  try {
    const { userId } = req.params;
    const connected = isUserConnected(userId);
    res.json({
      success: true,
      data: {
        user_id: userId,
        connected
      }
    });
  } catch (error) {
    res.json({
      success: false,
      message: error.message
    });
  }
});

// Notification routes
router.get('/', getAllNotifications);
router.get('/stats', getNotificationStats);
router.post('/', createNotification);
router.post('/broadcast', broadcastNotification);
router.put('/:id/read', markAsRead);
router.delete('/all', deleteAllNotifications);
router.delete('/:id', deleteNotification);

export default router;
