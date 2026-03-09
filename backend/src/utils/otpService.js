import crypto from 'crypto';

// Store OTP temporarily (in production, use Redis or database)
// OTPs are stored without expiry time - they remain valid until:
// 1. Successful verification, or
// 2. 5 incorrect attempts
const otpStore = new Map();

/**
 * Generate a random 6-digit OTP using crypto
 * @returns {string} - 6-digit OTP
 */
export const generateOTP = () => {
  // Generate random bytes and convert to number
  const randomBytes = crypto.randomBytes(3);
  const randomNumber = parseInt(randomBytes.toString('hex'), 16);
  
  // Ensure it's a 6-digit number
  const otp = (randomNumber % 900000 + 100000).toString();
  
  return otp;
};

/**
 * Store OTP without expiration time
 * OTP remains valid until 5 incorrect attempts or successful verification
 * @param {string} email - User email
 * @param {string} otp - Generated OTP
 * @param {number} expiryMinutes - Deprecated parameter, kept for backward compatibility
 */
export const storeOTP = (email, otp, expiryMinutes = null) => {
  otpStore.set(email, {
    otp,
    attempts: 0
  });
};

/**
 * Verify OTP
 * No time expiry - OTP remains valid until 5 incorrect attempts or successful verification
 * @param {string} email - User email
 * @param {string} otp - OTP to verify
 * @returns {Object} - Verification result
 */
export const verifyOTP = (email, otp) => {
  const storedData = otpStore.get(email);
  
  if (!storedData) {
    return {
      success: false,
      message: 'No OTP found. Please request a new one.'
    };
  }
  
  // Check attempts (no time limit, only attempt limit)
  if (storedData.attempts >= 5) {
    otpStore.delete(email);
    return {
      success: false,
      message: 'Too many failed attempts. Please request a new OTP.'
    };
  }
  
  // Verify OTP
  if (storedData.otp === otp) {
    otpStore.delete(email);
    return {
      success: true,
      message: 'OTP verified successfully.'
    };
  }
  
  // Increment attempts
  storedData.attempts++;
  otpStore.set(email, storedData);
  
  return {
    success: false,
    message: `Invalid OTP. ${5 - storedData.attempts} attempts remaining.`
  };
};

/**
 * Clear OTP for user
 * @param {string} email - User email
 */
export const clearOTP = (email) => {
  otpStore.delete(email);
};

/**
 * Generate a secure random secret for 2FA
 * @returns {string} - Base32 encoded secret
 */
export const generate2FASecret = () => {
  // Generate 20 random bytes
  const secret = crypto.randomBytes(20).toString('base64');
  return secret;
};
