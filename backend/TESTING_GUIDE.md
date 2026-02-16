# Testing the Enhanced POST Response Format

This guide demonstrates how to test the new POST response format that includes request body in responses.

## Prerequisites

1. **Start the backend server**:
   ```bash
   cd backend
   npm install
   npm start
   ```

2. **Server should be running on**: `http://localhost:5000`

## Test 1: Root Endpoint (GET)

This endpoint always works, even without database:

```bash
curl http://localhost:5000/
```

**Expected Response**:
```json
{
  "message": "EcoRide Backend API",
  "version": "1.0.0",
  "endpoints": {
    "health": "/health",
    "auth": "/api/auth",
    "documents": "/api/documents",
    ...
  }
}
```

## Test 2: Health Check (GET)

```bash
curl http://localhost:5000/health
```

**Expected Response** (without database):
```json
{
  "status": "ERROR",
  "message": "Database connection failed",
  "error": ""
}
```

**Expected Response** (with database):
```json
{
  "status": "OK",
  "timestamp": "2024-02-09T19:30:00.000Z",
  "uptime": 123.45,
  "database": "Connected"
}
```

## Test 3: User Signup (POST) - NEW FORMAT!

```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "Rider"
  }'
```

**Expected Response** (NEW FORMAT with requestBody):
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
      "verified": false,
      "profile_setup_complete": false,
      "rating": 0,
      "total_rides": 0,
      "created_at": "2024-02-09T19:30:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Notice:
- ✅ **requestBody** is included showing what you sent
- ✅ **password** is automatically filtered as `[FILTERED]`
- ✅ **data** contains the created user and auth token

## Test 4: User Login (POST) - NEW FORMAT!

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

**Expected Response** (NEW FORMAT):
```json
{
  "success": true,
  "message": "Login successful",
  "requestBody": {
    "email": "john@example.com",
    "password": "[FILTERED]"
  },
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "Rider",
      ...
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

## Test 5: Create Ride (POST) - NEW FORMAT!

First, get your token from the login response, then:

```bash
curl -X POST http://localhost:5000/api/rides \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "rider_id": 1,
    "driver_id": 2,
    "pickup_location": "123 Main St, New York, NY",
    "dropoff_location": "456 Park Ave, New York, NY",
    "pickup_lat": 40.7128,
    "pickup_lng": -74.0060,
    "dropoff_lat": 40.7589,
    "dropoff_lng": -73.9851,
    "ride_type": "solo",
    "fare": 25.50,
    "distance": 5.2
  }'
```

**Expected Response** (NEW FORMAT):
```json
{
  "success": true,
  "message": "Ride created successfully and driver notified",
  "requestBody": {
    "rider_id": 1,
    "driver_id": 2,
    "pickup_location": "123 Main St, New York, NY",
    "dropoff_location": "456 Park Ave, New York, NY",
    "pickup_lat": 40.7128,
    "pickup_lng": -74.006,
    "dropoff_lat": 40.7589,
    "dropoff_lng": -73.9851,
    "ride_type": "solo",
    "fare": 25.5,
    "distance": 5.2
  },
  "data": {
    "id": 1,
    "rider_id": 1,
    "driver_id": 2,
    "pickup_location": "123 Main St, New York, NY",
    "dropoff_location": "456 Park Ave, New York, NY",
    "status": "Pending",
    "fare": 25.5,
    "distance": 5.2,
    "ride_type": "solo",
    "created_at": "2024-02-09T19:35:00.000Z"
  }
}
```

### Notice:
- ✅ **requestBody** shows exactly what you sent
- ✅ **data** shows the created ride with server-added fields (id, status, created_at)
- ✅ Compare input vs output easily!

## Test 6: Upload Profile Photo (POST) - NEW FORMAT with Meta!

```bash
curl -X POST http://localhost:5000/api/auth/upload-photo \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -F "photo=@/path/to/photo.jpg"
```

**Expected Response** (NEW FORMAT with meta):
```json
{
  "success": true,
  "message": "Profile photo uploaded successfully",
  "requestBody": {},
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "profile_photo": "/uploads/profile-photos/profile-1707509400000-123456789.jpg",
    ...
  },
  "meta": {
    "filename": "profile-1707509400000-123456789.jpg",
    "size": 245678,
    "mimetype": "image/jpeg"
  }
}
```

### Notice:
- ✅ **meta** includes file upload details
- ✅ Useful for debugging file uploads

## Test 7: Error Response - NEW FORMAT!

Try signup with an existing email:

```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Doe",
    "email": "john@example.com",
    "password": "password456",
    "role": "Rider"
  }'
```

**Expected Response** (Error with requestBody):
```json
{
  "success": false,
  "message": "Email already registered",
  "requestBody": {
    "name": "Jane Doe",
    "email": "john@example.com",
    "password": "[FILTERED]",
    "role": "Rider"
  }
}
```

### Notice:
- ✅ Even errors include requestBody
- ✅ Helps debugging by seeing what was sent
- ✅ Password still filtered for security

## Summary of Changes

### Before (Old Format):
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": { ... },
    "token": "..."
  }
}
```

### After (New Format):
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
    "user": { ... },
    "token": "..."
  }
}
```

## Benefits

1. **🐛 Better Debugging**: See exactly what was sent vs what was received
2. **📚 Educational**: Learn how the API processes your data
3. **🔍 Transparency**: Understand data flow clearly
4. **🔒 Secure**: Sensitive fields automatically filtered
5. **✅ Consistent**: All POST endpoints follow same pattern

## All POST Endpoints Updated

✅ 21 POST endpoints now use this format:
- Authentication (8 endpoints)
- Rides (1 endpoint)
- Chat (2 endpoints)
- Emergency (1 endpoint)
- Notifications (2 endpoints)
- Reports (1 endpoint)
- Settings (2 endpoints)
- Documents (2 endpoints)
- Users (1 endpoint)

## GET Endpoints

GET endpoints work as before - no changes:
```bash
curl http://localhost:5000/api/rides
curl http://localhost:5000/api/users
curl http://localhost:5000/api/emergency
```

## Database Setup

If GET/POST endpoints return database errors, set up PostgreSQL:

```bash
# Install PostgreSQL
sudo apt-get install postgresql postgresql-contrib

# Start service
sudo service postgresql start

# Create database
sudo -u postgres createdb ecoride_db

# Initialize schema
cd backend
npm run init-db

# Restart server
npm start
```

## Testing with Postman

Import the Postman collection (`postman_collection.json`) to test all endpoints easily with pre-configured requests!

---

**Happy Testing! 🚀**
