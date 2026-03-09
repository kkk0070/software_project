import express from 'express';
import {
  getConversations,
  getOrCreateConversation,
  getMessages,
  sendMessage,
  markAsRead,
  getUnreadCount
} from '../../controllers/shared/chatController.js';

const router = express.Router();

// Get all conversations for a user
router.get('/conversations', getConversations);

// Get or create a conversation
router.post('/conversations', getOrCreateConversation);

// Get messages for a conversation
router.get('/conversations/:conversationId/messages', getMessages);

// Send a message
router.post('/messages', sendMessage);

// Mark messages as read
router.put('/conversations/:conversationId/read', markAsRead);

// Get unread message count
router.get('/unread-count', getUnreadCount);

export default router;
