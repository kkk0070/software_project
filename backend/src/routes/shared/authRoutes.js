import express from 'express';
import {
  signup,
  login,
  verifyLoginOTP,
  getProfile,
  updateProfile,
  completeProfileSetup,
  request2FAOTP,
  enable2FA,
  disable2FA,
  get2FAStatus,
  uploadProfilePhoto,
  uploadPhoto
} from '../../controllers/shared/authController.js';
import { authenticateToken } from '../../middleware/authMiddleware.js';
import { otpRateLimiter, twoFactorRateLimiter, uploadRateLimiter } from '../../middleware/rateLimiter.js';

const router = express.Router();

// Public routes
router.post('/signup', signup);
router.post('/login', login);
router.post('/verify-login-otp', otpRateLimiter, verifyLoginOTP);

// Protected routes (require authentication)
router.get('/profile', authenticateToken, getProfile);
router.put('/profile', authenticateToken, updateProfile);
router.post('/complete-setup', authenticateToken, completeProfileSetup);
router.post('/upload-photo', uploadRateLimiter, authenticateToken, uploadProfilePhoto.single('photo'), uploadPhoto);

// 2FA routes (require authentication)
// Note: Rate limiting removed from setup endpoints to allow users to enable 2FA without restrictions
// Users are already authenticated when accessing these endpoints
router.get('/2fa/status', authenticateToken, get2FAStatus);
router.post('/2fa/request-otp', authenticateToken, request2FAOTP);
router.post('/2fa/enable', authenticateToken, enable2FA);
router.post('/2fa/disable', authenticateToken, twoFactorRateLimiter, disable2FA);

export default router;
