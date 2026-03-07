import express from 'express';
import {
    getWalletBalance,
    addFunds,
    addPaymentMethod,
    getPaymentMethods
} from '../../controllers/shared/paymentController.js';
import { authenticateToken } from '../../middleware/authMiddleware.js';

const router = express.Router();

// Wallet Routes
router.get('/wallet', authenticateToken, getWalletBalance);
router.post('/wallet/add-funds', authenticateToken, addFunds);

// Payment Method Routes
router.get('/methods', authenticateToken, getPaymentMethods);
router.post('/methods', authenticateToken, addPaymentMethod);

export default router;
