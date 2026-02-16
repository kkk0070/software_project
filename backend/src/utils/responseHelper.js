/**
 * Response Helper Utilities
 * 
 * This module provides utilities for formatting API responses,
 * including the ability to safely include request body data in responses
 * while filtering out sensitive information.
 */

/**
 * List of sensitive field names that should never be included in responses
 * These fields will be filtered out from the request body echo
 */
const SENSITIVE_FIELDS = [
  'password',
  'currentPassword',
  'newPassword',
  'confirmPassword',
  'old_password',
  'new_password',
  'confirm_password',
  'secret',
  'token',
  'api_key',
  'apiKey',
  'private_key',
  'privateKey',
  'credit_card',
  'creditCard',
  'cvv',
  'ssn',
  'social_security'
];

/**
 * Filters sensitive data from an object
 * Creates a deep copy to avoid modifying the original object
 * 
 * @param {Object} data - The data object to filter
 * @returns {Object} - A new object with sensitive fields removed or masked
 */
export const filterSensitiveData = (data) => {
  if (!data || typeof data !== 'object') {
    return data;
  }

  // Create a deep copy to avoid modifying the original
  const filtered = Array.isArray(data) ? [...data] : { ...data };

  // Recursively filter sensitive fields
  for (const key in filtered) {
    if (filtered.hasOwnProperty(key)) {
      // Check if the field name matches any sensitive field
      const isSensitive = SENSITIVE_FIELDS.some(sensitiveField => 
        key.toLowerCase().includes(sensitiveField.toLowerCase())
      );

      if (isSensitive) {
        // Replace sensitive data with a masked value
        filtered[key] = '[FILTERED]';
      } else if (typeof filtered[key] === 'object' && filtered[key] !== null) {
        // Recursively filter nested objects
        filtered[key] = filterSensitiveData(filtered[key]);
      }
    }
  }

  return filtered;
};

/**
 * Creates a standardized response object that includes both the request body
 * and the response data, with sensitive fields filtered out
 * 
 * @param {Object} options - Response configuration
 * @param {boolean} options.success - Whether the operation was successful
 * @param {string} options.message - Response message
 * @param {Object} options.data - The response data (created/updated resource)
 * @param {Object} options.requestBody - The original request body
 * @param {Object} options.meta - Optional metadata (count, pagination, etc.)
 * @returns {Object} - Formatted response object
 */
export const createPostResponse = ({ success, message, data, requestBody, meta = {} }) => {
  const response = {
    success,
    message
  };

  // Include filtered request body if provided
  if (requestBody) {
    response.requestBody = filterSensitiveData(requestBody);
  }

  // Include response data
  if (data !== undefined) {
    response.data = data;
  }

  // Include any additional metadata
  if (Object.keys(meta).length > 0) {
    response.meta = meta;
  }

  return response;
};

/**
 * Formats an error response with optional request body inclusion
 * 
 * @param {Object} options - Error response configuration
 * @param {boolean} options.success - Always false for errors
 * @param {string} options.message - Error message
 * @param {string} options.error - Detailed error information
 * @param {Object} options.requestBody - Optional request body for debugging
 * @returns {Object} - Formatted error response
 */
export const createErrorResponse = ({ message, error, requestBody = null }) => {
  const response = {
    success: false,
    message,
    error
  };

  // Optionally include filtered request body for debugging
  // Only include in development/staging, not in production
  if (requestBody && process.env.NODE_ENV !== 'production') {
    response.requestBody = filterSensitiveData(requestBody);
  }

  return response;
};

/**
 * Express middleware to automatically attach response helpers to res object
 * This makes the helpers available in all route handlers
 */
export const responseHelperMiddleware = (req, res, next) => {
  // Attach helper function to response object
  res.sendPostResponse = ({ success, message, data, meta }) => {
    const response = createPostResponse({
      success,
      message,
      data,
      requestBody: req.body,
      meta
    });
    res.json(response);
  };

  // Attach error helper to response object
  res.sendErrorResponse = ({ statusCode = 500, message, error }) => {
    const response = createErrorResponse({
      message,
      error,
      requestBody: process.env.NODE_ENV !== 'production' ? req.body : null
    });
    res.status(statusCode).json(response);
  };

  next();
};
