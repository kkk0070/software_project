import { Server } from 'socket.io';

let io = null;
const userSockets = new Map(); // Map user IDs to socket IDs

/**
 * Initialize Socket.io server
 * @param {Object} httpServer - HTTP server instance
 */
export const initializeSocketIO = (httpServer) => {
  io = new Server(httpServer, {
    cors: {
      origin: function (origin, callback) {
        // Allow requests with no origin (like mobile apps)
        if (!origin) return callback(null, true);
        
        const allowedOrigins = [
          'http://localhost:5173',
          /^http:\/\/localhost:\d+$/,  // All localhost ports
          /^http:\/\/127\.0\.0\.1:\d+$/,  // All 127.0.0.1 ports
        ];
        
        const isAllowed = allowedOrigins.some(pattern => {
          if (typeof pattern === 'string') {
            return origin === pattern;
          } else if (pattern instanceof RegExp) {
            return pattern.test(origin);
          }
          return false;
        });
        
        if (isAllowed || process.env.NODE_ENV === 'development') {
          callback(null, true);
        } else {
          callback(new Error('Not allowed by CORS'));
        }
      },
      credentials: true
    }
  });

  io.on('connection', (socket) => {
    console.log(`[WebSocket] Client connected: ${socket.id}`);

    // Handle user registration - associate socket with user ID
    socket.on('register', (userId) => {
      if (userId) {
        userSockets.set(userId.toString(), socket.id);
        socket.userId = userId;
        console.log(`[WebSocket] User ${userId} registered with socket ${socket.id}`);
      }
    });

    // Handle disconnect
    socket.on('disconnect', () => {
      if (socket.userId) {
        userSockets.delete(socket.userId.toString());
        console.log(`[WebSocket] User ${socket.userId} disconnected`);
        delete socket.userId; // Clean up socket property
      } else {
        console.log(`[WebSocket] Client disconnected: ${socket.id}`);
      }
    });

    // Handle notification acknowledgment
    socket.on('notification:acknowledge', (data) => {
      console.log(`[WebSocket] Notification acknowledged:`, data);
    });
  });

  console.log('[WebSocket] Socket.io initialized');
  return io;
};

/**
 * Get Socket.io instance
 */
export const getIO = () => {
  if (!io) {
    throw new Error('Socket.io not initialized');
  }
  return io;
};

/**
 * Send notification to a specific user
 * @param {Number|String} userId - User ID
 * @param {Object} notification - Notification data
 */
export const sendNotificationToUser = (userId, notification) => {
  if (!io) {
    console.error('[WebSocket] Socket.io not initialized');
    return false;
  }

  const socketId = userSockets.get(userId.toString());
  if (socketId) {
    io.to(socketId).emit('notification', notification);
    console.log(`[WebSocket] Notification sent to user ${userId}:`, notification.title);
    return true;
  } else {
    console.log(`[WebSocket] User ${userId} not connected, notification stored in database only`);
    return false;
  }
};

/**
 * Broadcast notification to multiple users
 * @param {Array} userIds - Array of user IDs
 * @param {Object} notification - Notification data
 */
export const broadcastNotificationToUsers = (userIds, notification) => {
  if (!io) {
    console.error('[WebSocket] Socket.io not initialized');
    return;
  }

  let sentCount = 0;
  userIds.forEach(userId => {
    const sent = sendNotificationToUser(userId, notification);
    if (sent) sentCount++;
  });

  console.log(`[WebSocket] Broadcast notification sent to ${sentCount}/${userIds.length} users`);
};

/**
 * Broadcast notification to all connected clients
 * @param {Object} notification - Notification data
 */
export const broadcastNotificationToAll = (notification) => {
  if (!io) {
    console.error('[WebSocket] Socket.io not initialized');
    return;
  }

  io.emit('notification', notification);
  console.log(`[WebSocket] Notification broadcast to all users:`, notification.title);
};

/**
 * Get list of connected user IDs
 */
export const getConnectedUsers = () => {
  return Array.from(userSockets.keys());
};

/**
 * Check if user is connected
 * @param {Number|String} userId - User ID
 */
export const isUserConnected = (userId) => {
  return userSockets.has(userId.toString());
};
