# API Response Format Documentation

## Overview

This document explains the standardized response format for all API endpoints in the EcoRide backend API.

## Response Format Changes

### POST Endpoints - Enhanced Response Format

All POST endpoints now include the **request body** in their responses (with sensitive data filtered out). This helps with:
- **Debugging**: See what data was sent vs what was processed
- **Transparency**: Understand exactly what the API received
- **Education**: Learn how the API processes requests

### Standard POST Response Structure

```json
{
  "success": true,
  "message": "Descriptive message about the operation",
  "requestBody": {
    "field1": "value1",
    "field2": "value2",
    "password": "[FILTERED]"
  },
  "data": {
    "id": 1,
    "field1": "value1",
    "created_at": "2024-02-09T..."
  },
  "meta": {
    "optional": "metadata"
  }
}
```

### GET Response Structure

GET endpoints maintain their current structure:

```json
{
  "success": true,
  "data": {
    // Response data
  },
  "count": 10  // Optional: for list endpoints
}
```

## Sensitive Data Filtering

The following fields are automatically **filtered** from request body echoes:

- `password`
- `currentPassword`, `newPassword`, `confirmPassword`
- `old_password`, `new_password`, `confirm_password`
- `secret`
- `token`
- `api_key`, `apiKey`
- `private_key`, `privateKey`
- `credit_card`, `creditCard`
- `cvv`
- `ssn`, `social_security`

Filtered fields show as: `"[FILTERED]"`

## Example: POST /api/auth/signup

### Request:
```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "secret123",
    "role": "Rider"
  }'
```

### Response:
```json
{
  "success": true,
  "message": "User registered successfully",
  "requestBody": {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "[FILTERED]",
    "role": "Rider"
  },
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "Rider",
      "status": "Active",
      "created_at": "2024-02-09T19:30:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

## Example: POST /api/rides

### Request:
```bash
curl -X POST http://localhost:5000/api/rides \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "rider_id": 1,
    "driver_id": 2,
    "pickup_location": "123 Main St",
    "dropoff_location": "456 Oak Ave",
    "pickup_lat": 40.7128,
    "pickup_lng": -74.0060,
    "dropoff_lat": 40.7589,
    "dropoff_lng": -73.9851,
    "ride_type": "solo",
    "fare": 25.50,
    "distance": 5.2
  }'
```

### Response:
```json
{
  "success": true,
  "message": "Ride created successfully and driver notified",
  "requestBody": {
    "rider_id": 1,
    "driver_id": 2,
    "pickup_location": "123 Main St",
    "dropoff_location": "456 Oak Ave",
    "pickup_lat": 40.7128,
    "pickup_lng": -74.006,
    "dropoff_lat": 40.7589,
    "dropoff_lng": -73.9851,
    "ride_type": "solo",
    "fare": 25.5,
    "distance": 5.2
  },
  "data": {
    "id": 15,
    "rider_id": 1,
    "driver_id": 2,
    "pickup_location": "123 Main St",
    "dropoff_location": "456 Oak Ave",
    "status": "Pending",
    "fare": 25.5,
    "distance": 5.2,
    "created_at": "2024-02-09T19:30:00.000Z"
  }
}
```

## Complete List of POST Endpoints

### Authentication Endpoints
1. `POST /api/auth/signup` - Register new user
2. `POST /api/auth/login` - Login user
3. `POST /api/auth/verify-login-otp` - Verify OTP for 2FA login
4. `POST /api/auth/complete-setup` - Complete profile setup
5. `POST /api/auth/upload-photo` - Upload profile photo
6. `POST /api/auth/2fa/request-otp` - Request OTP for 2FA
7. `POST /api/auth/2fa/enable` - Enable 2FA
8. `POST /api/auth/2fa/disable` - Disable 2FA

### Ride Endpoints
9. `POST /api/rides` - Create new ride

### Chat Endpoints
10. `POST /api/chat/conversations` - Get or create conversation
11. `POST /api/chat/messages` - Send message

### Emergency Endpoints
12. `POST /api/emergency` - Create emergency incident

### Notification Endpoints
13. `POST /api/notifications` - Create notification
14. `POST /api/notifications/broadcast` - Broadcast notification

### Report Endpoints
15. `POST /api/reports/generate` - Generate report

### Settings Endpoints
16. `POST /api/settings` - Create setting
17. `POST /api/settings/bulk-update` - Bulk update settings

### Document Endpoints
18. `POST /api/documents/upload` - Upload document
19. `POST /api/documents/encryption/demo` - Demonstrate encryption

### User Endpoints
20. `POST /api/users` - Create user

## Complete List of GET Endpoints

### Authentication Endpoints
- `GET /api/auth/profile` - Get current user profile (requires auth)
- `GET /api/auth/2fa/status` - Get 2FA status (requires auth)

### Ride Endpoints
- `GET /api/rides` - Get all rides (with filters)
- `GET /api/rides/stats` - Get ride statistics
- `GET /api/rides/:id` - Get specific ride

### User Endpoints
- `GET /api/users` - Get all users
- `GET /api/users/stats` - Get user statistics
- `GET /api/users/:id` - Get specific user

### Document Endpoints
- `GET /api/documents` - Get user documents
- `GET /api/documents/:id/download` - Download document
- `GET /api/documents/admin/drivers` - Get drivers with pending documents
- `GET /api/documents/admin/user/:userId` - Get user documents (admin)
- `GET /api/documents/admin/view/:id` - View document (admin)
- `GET /api/documents/admin/view-encoded/:id` - View encoded document
- `GET /api/documents/admin/download/:id` - Download document (admin)
- `GET /api/documents/admin/security-analysis` - Security analysis
- `GET /api/documents/admin/all-documents-encoded` - All documents with encoding
- `GET /api/documents/encryption/public-key` - Get public key
- `GET /api/documents/encryption/info` - Get encryption info

### Analytics Endpoints
- `GET /api/analytics/overview` - Overview statistics
- `GET /api/analytics/demand-heatmap` - Demand heatmap
- `GET /api/analytics/route-analytics` - Route analytics
- `GET /api/analytics/sustainability` - Sustainability metrics
- `GET /api/analytics/ai-optimization` - AI optimization

### Monitoring Endpoints
- `GET /api/monitoring/live-rides` - Live ride monitoring
- `GET /api/monitoring/safety` - Safety monitoring
- `GET /api/monitoring/system` - System monitoring
- `GET /api/monitoring/gps-logs` - GPS logs

### Chat Endpoints
- `GET /api/chat/conversations` - Get conversations
- `GET /api/chat/conversations/:conversationId/messages` - Get messages
- `GET /api/chat/unread-count` - Get unread count

### Notification Endpoints
- `GET /api/notifications` - Get all notifications
- `GET /api/notifications/stats` - Notification statistics
- `GET /api/notifications/websocket/status` - WebSocket status
- `GET /api/notifications/websocket/user/:userId` - User WebSocket info

### Report Endpoints
- `GET /api/reports/recent` - Recent reports
- `GET /api/reports/scheduled` - Scheduled reports
- `GET /api/reports/stats` - Report statistics

### Settings Endpoints
- `GET /api/settings` - Get all settings
- `GET /api/settings/:key` - Get setting by key

### Emergency Endpoints
- `GET /api/emergency` - Get all incidents

### System Endpoints
- `GET /` - API information
- `GET /health` - Health check

## Testing GET Endpoints

All GET endpoints follow standard REST patterns:

```bash
# Test root endpoint
curl http://localhost:5000/

# Test health endpoint
curl http://localhost:5000/health

# Test authenticated endpoint (requires token)
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:5000/api/auth/profile

# Test list endpoint with filters
curl "http://localhost:5000/api/rides?status=Pending&ride_type=solo"

# Test specific resource
curl http://localhost:5000/api/rides/15
```

## Error Responses

### Database Connection Error
When the database is not available, endpoints return:
```json
{
  "success": false,
  "message": "Error fetching [resource]",
  "error": ""
}
```

### Authentication Error
When token is missing or invalid:
```json
{
  "success": false,
  "message": "Access token is required"
}
```

### Validation Error
When request data is invalid:
```json
{
  "success": false,
  "message": "Name, email, and password are required",
  "requestBody": {
    "email": "john@example.com",
    "password": "[FILTERED]"
  }
}
```

## Database Setup Required

Many GET endpoints will return errors if the PostgreSQL database is not set up. To fix:

1. **Install PostgreSQL**:
   ```bash
   # On Ubuntu/Debian
   sudo apt-get install postgresql postgresql-contrib
   
   # On macOS
   brew install postgresql
   ```

2. **Create Database**:
   ```bash
   # Start PostgreSQL service
   sudo service postgresql start
   
   # Create database
   sudo -u postgres createdb ecoride_db
   
   # Create user (if needed)
   sudo -u postgres psql -c "CREATE USER postgres WITH PASSWORD 'your_password';"
   sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ecoride_db TO postgres;"
   ```

3. **Initialize Database**:
   ```bash
   cd backend
   npm run init-db
   ```

4. **Start Server**:
   ```bash
   npm start
   ```

## Summary

- ✅ **POST endpoints** now include request body in responses (with sensitive data filtered)
- ✅ **GET endpoints** work as expected and return appropriate errors when database is not connected
- ✅ **All 21 POST endpoints** updated with new response format
- ✅ **All 40+ GET endpoints** remain functional
- ✅ **Root endpoint** (`http://localhost:5000`) always works and shows API info
- ✅ **Health endpoint** (`http://localhost:5000/health`) shows server and database status

## Next Steps

1. Set up PostgreSQL database
2. Run database migrations
3. Test endpoints with actual data
4. Use Postman collection for comprehensive testing
