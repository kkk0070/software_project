// JSON Web Token library for token verification
import jwt from 'jsonwebtoken';
import { knex } from '../config/database.js';

/**
 * Middleware to verify JWT authentication token
 * Extracts token from Authorization header and validates it
 * Adds decoded user info to request object if valid
 */
export const authenticateToken = (req, res, next) => {
  try {
    // Verify that JWT_SECRET environment variable is configured
    // Without this secret, tokens cannot be verified securely
    if (!process.env.JWT_SECRET) {
      console.error('FATAL: JWT_SECRET is not configured in environment variables');
      return res.status(500).json({
        success: false,
        message: 'Server configuration error'
      });
    }

    // Extract token from Authorization header
    // Expected format: "Bearer <token>"
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Get token after "Bearer "

    // Check if token is present in request
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access token is required'
      });
    }

    // Verify token signature and expiration using JWT_SECRET
    jwt.verify(token, process.env.JWT_SECRET, async (err, user) => {
      if (err) {
        // Token is invalid or expired
        return res.status(403).json({
          success: false,
          message: 'Invalid or expired token'
        });
      }

      // Check if session is still active (if sessionId is present in token)
      if (user.sessionId) {
        try {
          const session = await knex('device_sessions')
            .where({ id: user.sessionId, user_id: user.id })
            .first();

          if (!session) {
            return res.status(401).json({
              success: false,
              message: 'Session has been revoked'
            });
          }

          // Update last active timestamp for the session
          // We do this asynchronously to avoid delaying the response
          knex('device_sessions')
            .where({ id: user.sessionId })
            .update({ last_active: knex.fn.now() })
            .catch(err => console.error('[WARNING] Failed to update session last_active:', err.message));
        } catch (dbError) {
          console.error('Database error during session verification:', dbError);
          // If database is down, we allow the request if JWT is valid (graceful degradation)
        }
      }

      // Token is valid - attach decoded user info to request
      // This makes user data available to subsequent middleware/routes
      req.user = user;
      // Continue to next middleware or route handler
      next();
    });
  } catch (error) {
    // Handle unexpected errors during authentication
    console.error('Error in authentication middleware:', error);
    res.status(500).json({
      success: false,
      message: 'Error authenticating user',
      error: error.message
    });
  }
};

/**
 * Middleware factory to check if user has specific role(s)
 * Creates middleware that authorizes users based on their role
 * Must be used after authenticateToken middleware
 * @param {...string} allowedRoles - Roles that are allowed to access the route
 * @returns {Function} Express middleware function
 */
export const authorizeRole = (...allowedRoles) => {
  return (req, res, next) => {
    // Check if user was authenticated by previous middleware
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    // Check if user's role is in the list of allowed roles
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Insufficient permissions.'
      });
    }

    // User has required role - allow access
    next();
  };
};
