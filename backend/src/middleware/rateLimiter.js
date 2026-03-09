/**
 * Simple in-memory rate limiter middleware
 * In production, use a proper rate limiting library like express-rate-limit
 * or implement with Redis for distributed systems
 */

const requestCounts = new Map();
const RATE_LIMIT_WINDOW = 15 * 60 * 1000; // 15 minutes
const MAX_REQUESTS = 5; // Max 5 requests per window

// Cleanup old entries every 15 minutes
setInterval(() => {
  const now = Date.now();
  for (const [key, data] of requestCounts.entries()) {
    if (now - data.firstRequest > RATE_LIMIT_WINDOW) {
      requestCounts.delete(key);
    }
  }
}, RATE_LIMIT_WINDOW);

/**
 * Rate limit middleware
 * Limits requests based on IP address
 */
export const rateLimiter = (maxRequests = MAX_REQUESTS, windowMs = RATE_LIMIT_WINDOW) => {
  return (req, res, next) => {
    const identifier = req.ip || req.connection.remoteAddress;
    const now = Date.now();
    
    if (!requestCounts.has(identifier)) {
      // First request from this IP
      requestCounts.set(identifier, {
        count: 1,
        firstRequest: now
      });
      return next();
    }
    
    const data = requestCounts.get(identifier);
    const timeElapsed = now - data.firstRequest;
    
    if (timeElapsed > windowMs) {
      // Window expired, reset counter
      requestCounts.set(identifier, {
        count: 1,
        firstRequest: now
      });
      return next();
    }
    
    if (data.count >= maxRequests) {
      // Rate limit exceeded
      const resetTime = Math.ceil((windowMs - timeElapsed) / 1000 / 60);
      return res.status(429).json({
        success: false,
        message: `Too many requests. Please try again in ${resetTime} minutes.`,
        retryAfter: resetTime
      });
    }
    
    // Increment counter
    data.count++;
    requestCounts.set(identifier, data);
    next();
  };
};

/**
 * Stricter rate limiter for OTP requests
 * Max 3 OTP requests per 15 minutes
 */
export const otpRateLimiter = rateLimiter(3, 15 * 60 * 1000);

/**
 * Standard rate limiter for 2FA operations
 * Max 10 requests per 15 minutes
 */
export const twoFactorRateLimiter = rateLimiter(10, 15 * 60 * 1000);

/**
 * Rate limiter for file uploads
 * Max 10 uploads per 15 minutes to prevent abuse
 */
export const uploadRateLimiter = rateLimiter(10, 15 * 60 * 1000);
