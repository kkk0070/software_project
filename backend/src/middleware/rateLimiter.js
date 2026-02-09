/**
 * Simple in-memory rate limiter middleware
 * Prevents abuse by limiting number of requests per IP address
 * 
 * IMPORTANT: In production environments, use:
 * - A proper rate limiting library like express-rate-limit
 * - Redis-based rate limiting for distributed/multi-server deployments
 * 
 * This in-memory implementation is suitable for:
 * - Single-server deployments
 * - Development/testing environments
 * - Low-traffic applications
 */

// Map to store request counts per IP address
// Key: IP address, Value: { count, firstRequest timestamp }
const requestCounts = new Map();

// Rate limiting window duration in milliseconds
const RATE_LIMIT_WINDOW = 15 * 60 * 1000; // 15 minutes

// Maximum number of requests allowed per window
const MAX_REQUESTS = 5;

// Background cleanup task to remove expired entries
// Runs every 15 minutes to prevent memory leaks
setInterval(() => {
  const now = Date.now();
  // Iterate through all stored request data
  for (const [key, data] of requestCounts.entries()) {
    // Remove entries older than the rate limit window
    if (now - data.firstRequest > RATE_LIMIT_WINDOW) {
      requestCounts.delete(key);
    }
  }
}, RATE_LIMIT_WINDOW);

/**
 * Rate limiter middleware factory
 * Creates a rate limiting middleware with custom limits
 * @param {number} maxRequests - Maximum requests allowed (default: 5)
 * @param {number} windowMs - Time window in milliseconds (default: 15 minutes)
 * @returns {Function} Express middleware function
 */
export const rateLimiter = (maxRequests = MAX_REQUESTS, windowMs = RATE_LIMIT_WINDOW) => {
  return (req, res, next) => {
    // Identify client by IP address
    const identifier = req.ip || req.connection.remoteAddress;
    const now = Date.now();
    
    // First request from this IP - initialize counter
    if (!requestCounts.has(identifier)) {
      requestCounts.set(identifier, {
        count: 1,
        firstRequest: now
      });
      // Allow request to proceed
      return next();
    }
    
    // Get existing request data for this IP
    const data = requestCounts.get(identifier);
    // Calculate time elapsed since first request in window
    const timeElapsed = now - data.firstRequest;
    
    // Check if time window has expired
    if (timeElapsed > windowMs) {
      // Window expired - reset counter and start new window
      requestCounts.set(identifier, {
        count: 1,
        firstRequest: now
      });
      return next();
    }
    
    // Check if rate limit has been exceeded
    if (data.count >= maxRequests) {
      // Calculate remaining time until rate limit resets
      const resetTime = Math.ceil((windowMs - timeElapsed) / 1000 / 60);
      // Return 429 Too Many Requests error
      return res.status(429).json({
        success: false,
        message: `Too many requests. Please try again in ${resetTime} minutes.`,
        retryAfter: resetTime
      });
    }
    
    // Within rate limit - increment counter and allow request
    data.count++;
    requestCounts.set(identifier, data);
    next();
  };
};

/**
 * Stricter rate limiter specifically for OTP requests
 * More restrictive to prevent brute force attacks on OTP codes
 * Maximum 3 OTP requests per 15 minutes
 */
export const otpRateLimiter = rateLimiter(3, 15 * 60 * 1000);

/**
 * Standard rate limiter for 2FA operations
 * Allows more requests than OTP but still restrictive
 * Maximum 10 requests per 15 minutes
 */
export const twoFactorRateLimiter = rateLimiter(10, 15 * 60 * 1000);

/**
 * Rate limiter for file upload endpoints
 * Prevents abuse of file storage and bandwidth
 * Maximum 10 uploads per 15 minutes
 */
export const uploadRateLimiter = rateLimiter(10, 15 * 60 * 1000);
