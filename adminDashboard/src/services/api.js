/**
 * API Service for EcoRide Admin Dashboard
 * Centralized API client for all backend communication
 * Provides methods to interact with users, rides, monitoring, and analytics endpoints
 */

// Get base API URL from environment variable or use localhost default
// VITE_API_URL should be set in .env file for production deployment
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000';

/**
 * Helper function to handle API responses consistently
 * Parses JSON response and throws errors for failed requests
 * @param {Response} response - Fetch API response object
 * @returns {Promise<Object>} Parsed JSON data
 * @throws {Error} If response status indicates failure
 */
const handleResponse = async (response) => {
  // Parse response body as JSON
  const data = await response.json();
  
  // Check if HTTP status indicates error (4xx or 5xx)
  if (!response.ok) {
    // Throw error with message from server or generic message
    throw new Error(data.message || 'API request failed');
  }
  
  // Return parsed data for successful requests
  return data;
};

/**
 * User API methods
 * Handles all user-related operations (CRUD, search, statistics)
 */
export const userAPI = {
  /**
   * Get all users with optional filters
   * Supports filtering by role (rider/driver), status, verification, and search
   * @param {Object} params - Query parameters (role, status, verified, search)
   * @returns {Promise} User list with pagination info
   */
  getAll: async (params = {}) => {
    // Build query string from parameters, filtering out null/empty values
    const queryString = new URLSearchParams(
      Object.entries(params).filter(([_, v]) => v != null && v !== '')
    ).toString();
    // Construct full URL with query string if parameters exist
    const url = `${API_BASE_URL}/api/users${queryString ? `?${queryString}` : ''}`;
    // Fetch data from API
    const response = await fetch(url);
    return handleResponse(response);
  },

  /**
   * Get user statistics
   * @returns {Promise} User statistics
   */
  getStats: async () => {
    const response = await fetch(`${API_BASE_URL}/api/users/stats`);
    return handleResponse(response);
  },

  /**
   * Get user by ID
   * @param {number} id - User ID
   * @returns {Promise} User details
   */
  getById: async (id) => {
    const response = await fetch(`${API_BASE_URL}/api/users/${id}`);
    return handleResponse(response);
  },

  /**
   * Create new user
   * @param {Object} data - User data
   * @returns {Promise} Created user
   */
  create: async (data) => {
    const response = await fetch(`${API_BASE_URL}/api/users`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return handleResponse(response);
  },

  /**
   * Update user
   * @param {number} id - User ID
   * @param {Object} data - Updated user data
   * @returns {Promise} Updated user
   */
  update: async (id, data) => {
    const response = await fetch(`${API_BASE_URL}/api/users/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return handleResponse(response);
  },

  /**
   * Delete user
   * @param {number} id - User ID
   * @returns {Promise} Deletion result
   */
  delete: async (id) => {
    const response = await fetch(`${API_BASE_URL}/api/users/${id}`, {
      method: 'DELETE'
    });
    return handleResponse(response);
  }
};

/**
 * Ride API methods
 */
export const rideAPI = {
  /**
   * Get all rides with optional filters
   * @param {Object} params - Query parameters (status, ride_type, from_date, to_date)
   * @returns {Promise} Ride list
   */
  getAll: async (params = {}) => {
    const queryString = new URLSearchParams(
      Object.entries(params).filter(([_, v]) => v != null && v !== '')
    ).toString();
    const url = `${API_BASE_URL}/api/rides${queryString ? `?${queryString}` : ''}`;
    const response = await fetch(url);
    return handleResponse(response);
  },

  /**
   * Get ride statistics
   * @returns {Promise} Ride statistics
   */
  getStats: async () => {
    const response = await fetch(`${API_BASE_URL}/api/rides/stats`);
    return handleResponse(response);
  },

  /**
   * Get ride by ID
   * @param {number} id - Ride ID
   * @returns {Promise} Ride details
   */
  getById: async (id) => {
    const response = await fetch(`${API_BASE_URL}/api/rides/${id}`);
    return handleResponse(response);
  },

  /**
   * Create new ride
   * @param {Object} data - Ride data
   * @returns {Promise} Created ride
   */
  create: async (data) => {
    const response = await fetch(`${API_BASE_URL}/api/rides`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return handleResponse(response);
  },

  /**
   * Update ride
   * @param {number} id - Ride ID
   * @param {Object} data - Updated ride data
   * @returns {Promise} Updated ride
   */
  update: async (id, data) => {
    const response = await fetch(`${API_BASE_URL}/api/rides/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return handleResponse(response);
  },

  /**
   * Delete ride
   * @param {number} id - Ride ID
   * @returns {Promise} Deletion result
   */
  delete: async (id) => {
    const response = await fetch(`${API_BASE_URL}/api/rides/${id}`, {
      method: 'DELETE'
    });
    return handleResponse(response);
  }
};

/**
 * Emergency Incident API methods
 */
export const emergencyAPI = {
  /**
   * Get all incidents with optional filters
   * @param {Object} params - Query parameters (status, priority)
   * @returns {Promise} Incident list
   */
  getAll: async (params = {}) => {
    const queryString = new URLSearchParams(
      Object.entries(params).filter(([_, v]) => v != null && v !== '')
    ).toString();
    const url = `${API_BASE_URL}/api/emergency${queryString ? `?${queryString}` : ''}`;
    const response = await fetch(url);
    return handleResponse(response);
  },

  /**
   * Create new incident
   * @param {Object} data - Incident data
   * @returns {Promise} Created incident
   */
  create: async (data) => {
    const response = await fetch(`${API_BASE_URL}/api/emergency`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return handleResponse(response);
  },

  /**
   * Update incident
   * @param {number} id - Incident ID
   * @param {Object} data - Updated incident data
   * @returns {Promise} Updated incident
   */
  update: async (id, data) => {
    const response = await fetch(`${API_BASE_URL}/api/emergency/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return handleResponse(response);
  },

  /**
   * Delete incident
   * @param {number} id - Incident ID
   * @returns {Promise} Deletion result
   */
  delete: async (id) => {
    const response = await fetch(`${API_BASE_URL}/api/emergency/${id}`, {
      method: 'DELETE'
    });
    return handleResponse(response);
  }
};

/**
 * Health check
 */
export const healthCheck = async () => {
  const response = await fetch(`${API_BASE_URL}/health`);
  return handleResponse(response);
};

/**
 * Analytics API methods
 */
export const analyticsAPI = {
  getOverviewStats: async () => {
    const response = await fetch(`${API_BASE_URL}/api/analytics/overview`);
    return handleResponse(response);
  },
  getDemandHeatmap: async () => {
    const response = await fetch(`${API_BASE_URL}/api/analytics/demand-heatmap`);
    return handleResponse(response);
  },
  getRouteAnalytics: async () => {
    const response = await fetch(`${API_BASE_URL}/api/analytics/route-analytics`);
    return handleResponse(response);
  },
  getSustainability: async () => {
    const response = await fetch(`${API_BASE_URL}/api/analytics/sustainability`);
    return handleResponse(response);
  },
  getAIOptimization: async () => {
    const response = await fetch(`${API_BASE_URL}/api/analytics/ai-optimization`);
    return handleResponse(response);
  }
};

/**
 * Monitoring API methods
 */
export const monitoringAPI = {
  getLiveRides: async () => {
    const response = await fetch(`${API_BASE_URL}/api/monitoring/live-rides`);
    return handleResponse(response);
  },
  getSafety: async () => {
    const response = await fetch(`${API_BASE_URL}/api/monitoring/safety`);
    return handleResponse(response);
  },
  getSystem: async () => {
    const response = await fetch(`${API_BASE_URL}/api/monitoring/system`);
    return handleResponse(response);
  },
  getGPSLogs: async () => {
    const response = await fetch(`${API_BASE_URL}/api/monitoring/gps-logs`);
    return handleResponse(response);
  }
};

/**
 * Notification API methods
 */
export const notificationAPI = {
  getAll: async (params = {}) => {
    const queryString = new URLSearchParams(
      Object.entries(params).filter(([_, v]) => v != null && v !== '')
    ).toString();
    const url = `${API_BASE_URL}/api/notifications${queryString ? `?${queryString}` : ''}`;
    const response = await fetch(url);
    return handleResponse(response);
  },
  getStats: async () => {
    const response = await fetch(`${API_BASE_URL}/api/notifications/stats`);
    return handleResponse(response);
  },
  create: async (data) => {
    const response = await fetch(`${API_BASE_URL}/api/notifications`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return handleResponse(response);
  },
  broadcast: async (data) => {
    const response = await fetch(`${API_BASE_URL}/api/notifications/broadcast`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return handleResponse(response);
  },
  markAsRead: async (id) => {
    const response = await fetch(`${API_BASE_URL}/api/notifications/${id}/read`, {
      method: 'PUT'
    });
    return handleResponse(response);
  },
  delete: async (id) => {
    const response = await fetch(`${API_BASE_URL}/api/notifications/${id}`, {
      method: 'DELETE'
    });
    return handleResponse(response);
  }
};

/**
 * Settings API methods
 */
export const settingsAPI = {
  getAll: async (params = {}) => {
    const queryString = new URLSearchParams(
      Object.entries(params).filter(([_, v]) => v != null && v !== '')
    ).toString();
    const url = `${API_BASE_URL}/api/settings${queryString ? `?${queryString}` : ''}`;
    const response = await fetch(url);
    return handleResponse(response);
  },
  getByKey: async (key) => {
    const response = await fetch(`${API_BASE_URL}/api/settings/${key}`);
    return handleResponse(response);
  },
  create: async (data) => {
    const response = await fetch(`${API_BASE_URL}/api/settings`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return handleResponse(response);
  },
  update: async (key, data) => {
    const response = await fetch(`${API_BASE_URL}/api/settings/${key}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return handleResponse(response);
  },
  delete: async (key) => {
    const response = await fetch(`${API_BASE_URL}/api/settings/${key}`, {
      method: 'DELETE'
    });
    return handleResponse(response);
  },
  bulkUpdate: async (settings) => {
    const response = await fetch(`${API_BASE_URL}/api/settings/bulk-update`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ settings })
    });
    return handleResponse(response);
  }
};

/**
 * Reports API methods
 */
export const reportsAPI = {
  getRecent: async (type = null) => {
    const url = `${API_BASE_URL}/api/reports/recent${type ? `?type=${type}` : ''}`;
    const response = await fetch(url);
    return handleResponse(response);
  },
  getScheduled: async () => {
    const response = await fetch(`${API_BASE_URL}/api/reports/scheduled`);
    return handleResponse(response);
  },
  getStats: async () => {
    const response = await fetch(`${API_BASE_URL}/api/reports/stats`);
    return handleResponse(response);
  },
  generate: async (data) => {
    const response = await fetch(`${API_BASE_URL}/api/reports/generate`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return handleResponse(response);
  },
  updateScheduled: async (id, data) => {
    const response = await fetch(`${API_BASE_URL}/api/reports/scheduled/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return handleResponse(response);
  },
  delete: async (id) => {
    const response = await fetch(`${API_BASE_URL}/api/reports/${id}`, {
      method: 'DELETE'
    });
    return handleResponse(response);
  }
};

/**
 * Get auth token from localStorage
 */
const getAuthToken = () => {
  return localStorage.getItem('token') || localStorage.getItem('authToken') || '';
};

/**
 * Create axios-like API wrapper with auth token
 */
const createApiWrapper = () => {
  const request = async (url, options = {}) => {
    const token = getAuthToken();
    const headers = {
      ...options.headers
    };
    
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    
    if (options.body && typeof options.body === 'object' && !(options.body instanceof FormData)) {
      headers['Content-Type'] = 'application/json';
      options.body = JSON.stringify(options.body);
    }
    
    const fullUrl = url.startsWith('http') ? url : `${API_BASE_URL}/api${url}`;
    const response = await fetch(fullUrl, { ...options, headers });
    
    // Handle blob responses (file downloads)
    if (options.responseType === 'blob') {
      if (!response.ok) {
        throw new Error('Download failed');
      }
      return { data: await response.blob() };
    }
    
    return handleResponse(response);
  };

  return {
    get: (url, options = {}) => request(url, { ...options, method: 'GET' }),
    post: (url, data, options = {}) => request(url, { ...options, method: 'POST', body: data }),
    put: (url, data, options = {}) => request(url, { ...options, method: 'PUT', body: data }),
    delete: (url, options = {}) => request(url, { ...options, method: 'DELETE' }),
    patch: (url, data, options = {}) => request(url, { ...options, method: 'PATCH', body: data })
  };
};

// Create the API wrapper instance
const apiWrapper = createApiWrapper();

export default {
  ...apiWrapper,
  users: userAPI,
  rides: rideAPI,
  emergency: emergencyAPI,
  analytics: analyticsAPI,
  monitoring: monitoringAPI,
  notifications: notificationAPI,
  settings: settingsAPI,
  reports: reportsAPI,
  healthCheck
};
