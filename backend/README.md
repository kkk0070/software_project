# EcoRide Backend API

A Node.js + Express + PostgreSQL backend server for the EcoRide Admin Dashboard with complete CRUD operations.

## 🚀 Features

- **RESTful API** with Express.js
- **PostgreSQL Database** for data persistence
- **CRUD Operations** for Users, Rides, and Emergency Incidents
- **Database Connection Pooling** for performance
- **CORS Support** for frontend integration
- **Environment Configuration** with dotenv
- **Health Check Endpoint** for monitoring
- **Graceful Shutdown** handling
- **Request Logging** for debugging

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v16 or higher) - [Download](https://nodejs.org/)
- **PostgreSQL** (v12 or higher) - [Download](https://www.postgresql.org/download/)
- **npm** or **yarn** (comes with Node.js)

## 🛠️ Installation

### 1. Navigate to Backend Directory

```bash
cd backend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Set Up PostgreSQL Database

#### Create Database

Open PostgreSQL terminal or use pgAdmin:

```sql
CREATE DATABASE ecoride_db;
```

Alternatively, use command line:

```bash
# On Linux/Mac
psql -U postgres -c "CREATE DATABASE ecoride_db;"

# On Windows (using psql from PostgreSQL installation)
psql -U postgres
postgres=# CREATE DATABASE ecoride_db;
postgres=# \q
```

### 4. Configure Environment Variables

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` file with your PostgreSQL credentials:

```env
# Server Configuration
PORT=5000
NODE_ENV=development

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ecoride_db
DB_USER=postgres
DB_PASSWORD=your_actual_password

# JWT Configuration (for future auth implementation)
JWT_SECRET=your_secure_random_secret_key
JWT_EXPIRE=24h

# CORS Configuration
CORS_ORIGIN=http://localhost:5173
```

**Important:** Replace `your_actual_password` with your PostgreSQL password.

### 5. Initialize Database Tables

Run the database initialization script to create tables and seed initial data:

```bash
npm run init-db
```

This will:
- Create all necessary tables (users, drivers, rides, emergency_incidents, etc.)
- Insert sample data for testing
- Create an admin user (email: admin@ecoride.com)

## 🚦 Running the Server

### Development Mode (with auto-restart)

```bash
npm run dev
```

### Production Mode

```bash
npm start
```

The server will start on `http://localhost:5000` (or the port specified in `.env`).

## 📡 API Endpoints

### Health Check

```
GET /health
```

Returns server status and database connection status.

### Users API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users` | Get all users (with optional filters) |
| GET | `/api/users/stats` | Get user statistics |
| GET | `/api/users/:id` | Get user by ID |
| POST | `/api/users` | Create new user |
| PUT | `/api/users/:id` | Update user |
| DELETE | `/api/users/:id` | Delete user |

**Query Parameters for GET /api/users:**
- `role` - Filter by role (Rider, Driver, Admin)
- `status` - Filter by status (Active, Suspended, Pending)
- `verified` - Filter by verification status (verified, unverified)
- `search` - Search by name or email

**Example Request:**

```bash
# Get all active drivers
curl http://localhost:5000/api/users?role=Driver&status=Active

# Get user by ID
curl http://localhost:5000/api/users/1

# Create new user
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "phone": "+1234567890",
    "location": "New York, NY",
    "role": "Rider"
  }'

# Update user
curl -X PUT http://localhost:5000/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "status": "Active",
    "verified": true
  }'

# Delete user
curl -X DELETE http://localhost:5000/api/users/1
```

### Rides API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/rides` | Get all rides (with optional filters) |
| GET | `/api/rides/stats` | Get ride statistics |
| GET | `/api/rides/:id` | Get ride by ID |
| POST | `/api/rides` | Create new ride |
| PUT | `/api/rides/:id` | Update ride |
| DELETE | `/api/rides/:id` | Delete ride |

**Query Parameters for GET /api/rides:**
- `status` - Filter by status (Pending, Active, Completed, Cancelled)
- `ride_type` - Filter by type (Solo, Pool, EV)
- `from_date` - Filter rides from date (ISO format)
- `to_date` - Filter rides to date (ISO format)

**Example Request:**

```bash
# Get all active rides
curl http://localhost:5000/api/rides?status=Active

# Create new ride
curl -X POST http://localhost:5000/api/rides \
  -H "Content-Type: application/json" \
  -d '{
    "rider_id": 1,
    "driver_id": 2,
    "pickup_location": "Times Square, NY",
    "dropoff_location": "Central Park, NY",
    "ride_type": "Solo",
    "fare": 25.50,
    "distance": 5.2
  }'
```

### Emergency Incidents API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/emergency` | Get all incidents (with optional filters) |
| POST | `/api/emergency` | Create new incident |
| PUT | `/api/emergency/:id` | Update incident |
| DELETE | `/api/emergency/:id` | Delete incident |

**Query Parameters for GET /api/emergency:**
- `status` - Filter by status (Open, In Progress, Resolved)
- `priority` - Filter by priority (Low, Medium, High, Critical)

**Example Request:**

```bash
# Get all open incidents
curl http://localhost:5000/api/emergency?status=Open

# Create new incident
curl -X POST http://localhost:5000/api/emergency \
  -H "Content-Type: application/json" \
  -d '{
    "ride_id": 1,
    "user_id": 1,
    "incident_type": "SOS Alert",
    "description": "Emergency assistance needed",
    "location": "Broadway, NY",
    "latitude": 40.7580,
    "longitude": -73.9855,
    "priority": "High"
  }'
```

## 🗄️ Database Schema

### Users Table
- `id` - Primary key
- `name` - User name
- `email` - Unique email
- `password` - Hashed password
- `phone` - Phone number
- `location` - User location
- `role` - Rider, Driver, or Admin
- `status` - Active, Suspended, or Pending
- `verified` - Verification status
- `rating` - User rating (0-5)
- `total_rides` - Total rides count
- `joined_date` - Registration date

### Drivers Table
- `id` - Primary key
- `user_id` - Foreign key to users
- `vehicle_type` - Electric Vehicle, Hybrid, or Gas
- `vehicle_model` - Vehicle model name
- `license_plate` - License plate number
- `license_number` - Driver license number
- `vehicle_year` - Vehicle year
- `available` - Driver availability status

### Rides Table
- `id` - Primary key
- `rider_id` - Foreign key to users
- `driver_id` - Foreign key to users
- `pickup_location` - Pickup address
- `dropoff_location` - Dropoff address
- `pickup_lat`, `pickup_lng` - Pickup coordinates
- `dropoff_lat`, `dropoff_lng` - Dropoff coordinates
- `ride_type` - Solo, Pool, or EV
- `status` - Pending, Active, Completed, or Cancelled
- `fare` - Ride fare
- `distance` - Distance in km
- `duration` - Duration in minutes
- `carbon_saved` - CO2 saved in kg
- `rating` - Ride rating
- `scheduled_time` - Scheduled ride time
- `started_at` - Ride start time
- `completed_at` - Ride completion time

### Emergency Incidents Table
- `id` - Primary key
- `ride_id` - Foreign key to rides
- `user_id` - Foreign key to users
- `incident_type` - Type of incident
- `description` - Incident description
- `location` - Incident location
- `latitude`, `longitude` - Incident coordinates
- `status` - Open, In Progress, or Resolved
- `priority` - Low, Medium, High, or Critical
- `resolved_at` - Resolution timestamp

## 🔌 Connecting to Admin Dashboard

### Update Admin Dashboard API Configuration

In your admin dashboard, create or update the API configuration file:

**File: `/admin/src/config/api.js`**

```javascript
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000';

export const api = {
  baseURL: API_BASE_URL,
  
  // User endpoints
  users: {
    getAll: (params) => fetch(`${API_BASE_URL}/api/users?${new URLSearchParams(params)}`),
    getById: (id) => fetch(`${API_BASE_URL}/api/users/${id}`),
    create: (data) => fetch(`${API_BASE_URL}/api/users`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    }),
    update: (id, data) => fetch(`${API_BASE_URL}/api/users/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    }),
    delete: (id) => fetch(`${API_BASE_URL}/api/users/${id}`, { method: 'DELETE' }),
    getStats: () => fetch(`${API_BASE_URL}/api/users/stats`)
  },
  
  // Ride endpoints
  rides: {
    getAll: (params) => fetch(`${API_BASE_URL}/api/rides?${new URLSearchParams(params)}`),
    getById: (id) => fetch(`${API_BASE_URL}/api/rides/${id}`),
    create: (data) => fetch(`${API_BASE_URL}/api/rides`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    }),
    update: (id, data) => fetch(`${API_BASE_URL}/api/rides/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    }),
    delete: (id) => fetch(`${API_BASE_URL}/api/rides/${id}`, { method: 'DELETE' }),
    getStats: () => fetch(`${API_BASE_URL}/api/rides/stats`)
  },
  
  // Emergency endpoints
  emergency: {
    getAll: (params) => fetch(`${API_BASE_URL}/api/emergency?${new URLSearchParams(params)}`),
    create: (data) => fetch(`${API_BASE_URL}/api/emergency`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    }),
    update: (id, data) => fetch(`${API_BASE_URL}/api/emergency/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    }),
    delete: (id) => fetch(`${API_BASE_URL}/api/emergency/${id}`, { method: 'DELETE' })
  }
};

export default api;
```

### Update Admin Dashboard Environment

Create `.env` file in admin directory:

```env
VITE_API_URL=http://localhost:5000
```

## 🧪 Testing the API

### Using cURL

```bash
# Test health endpoint
curl http://localhost:5000/health

# Get all users
curl http://localhost:5000/api/users

# Get user statistics
curl http://localhost:5000/api/users/stats

# Get all rides
curl http://localhost:5000/api/rides

# Get ride statistics
curl http://localhost:5000/api/rides/stats
```

### Using Postman

1. Import the following collection URL (or create requests manually)
2. Set base URL: `http://localhost:5000`
3. Test all endpoints listed above

### Using Browser

Navigate to:
- `http://localhost:5000` - API info
- `http://localhost:5000/health` - Health check
- `http://localhost:5000/api/users` - Get all users
- `http://localhost:5000/api/rides` - Get all rides

### Sample Data

After running `npm run init-db`, the following sample users are created:

**Admin User:**
- Email: `admin@ecoride.com`
- Password: `admin123`
- Role: Admin

**Sample Riders & Drivers:**
- All use password: `password123`

For complete list of credentials, see [DEFAULT_LOGIN_CREDENTIALS.md](../DEFAULT_LOGIN_CREDENTIALS.md)

## 🐛 Troubleshooting

### Database Connection Failed

**Problem:** Error connecting to PostgreSQL

**Solutions:**
1. Verify PostgreSQL is running: `pg_isready`
2. Check credentials in `.env` file
3. Ensure database exists: `psql -U postgres -l`
4. Check PostgreSQL service: 
   - Linux: `sudo systemctl status postgresql`
   - Mac: `brew services list`
   - Windows: Check Services app

### Port Already in Use

**Problem:** Port 5000 is already in use

**Solution:** Change the PORT in `.env` file to a different port (e.g., 5001, 8000)

### CORS Errors

**Problem:** Browser blocks requests from admin dashboard

**Solution:** Update `CORS_ORIGIN` in `.env` to match your frontend URL

### Cannot Find Module Errors

**Problem:** Module not found errors

**Solution:** Run `npm install` again to ensure all dependencies are installed

## 📦 Project Structure

```
backend/
├── src/
│   ├── config/
│   │   ├── database.js          # Database connection
│   │   └── initDatabase.js      # Database initialization
│   ├── controllers/
│   │   ├── userController.js    # User CRUD operations
│   │   ├── rideController.js    # Ride CRUD operations
│   │   └── emergencyController.js # Emergency CRUD operations
│   ├── routes/
│   │   ├── userRoutes.js        # User API routes
│   │   ├── rideRoutes.js        # Ride API routes
│   │   └── emergencyRoutes.js   # Emergency API routes
│   └── server.js                # Main server file
├── .env.example                 # Environment variables template
├── .gitignore                   # Git ignore file
├── package.json                 # Dependencies and scripts
└── README.md                    # This file
```

## 🔐 Security Notes

1. **Password Storage:** ✅ Passwords are hashed using bcrypt before storage
   - All new users created via API have their passwords automatically hashed
   - Sample users in database initialization use pre-hashed passwords for testing
2. **JWT Authentication:** Add JWT-based authentication for protected routes (prepared but not implemented)
3. **Input Validation:** Add express-validator middleware for request validation (dependency included)
4. **Rate Limiting:** Implement rate limiting to prevent abuse
5. **Environment Variables:** Never commit `.env` file to version control
6. **SQL Injection:** Use parameterized queries (already implemented)

## 📈 Future Enhancements

- [ ] JWT authentication and authorization
- [x] Password hashing with bcrypt (implemented)
- [ ] Input validation middleware
- [ ] Rate limiting
- [ ] API documentation with Swagger
- [x] Unit and integration tests (implemented with Jest)
- [ ] Logging with Winston
- [ ] Caching with Redis
- [ ] Real-time updates with Socket.io
- [ ] File upload for driver documents

## 🧪 Testing

The backend includes comprehensive Jest-based testing for utilities and integration workflows.

### Running Tests

Tests work cross-platform (Windows, macOS, Linux) using `cross-env`:

```bash
# Run all tests
npm test

# Run tests in watch mode (re-runs on file changes)
npm run test:watch

# Run tests with coverage report
npm run test:coverage
```

### Test Structure

```
backend/tests/
├── unit/
│   └── utils/
│       ├── otpService.test.js       # OTP generation and verification tests
│       ├── emailService.test.js     # Email service tests
│       ├── encodingUtils.test.js    # Base64 encoding/decoding tests
│       └── encryptionUtils.test.js  # AES/RSA encryption tests
└── integration/
    └── backend-integration.test.js  # End-to-end workflow tests
```

### Test Coverage

The test suite includes **65 tests** covering:

#### Unit Tests
- **OTP Service (11 tests)**
  - OTP generation (6-digit random codes)
  - OTP storage and verification
  - Failed attempt tracking (5 attempts max)
  - 2FA secret generation

- **Email Service (5 tests)**
  - Email configuration validation
  - OTP email sending
  - 2FA status notifications

- **Encoding Utils (20 tests)**
  - Base64 encoding/decoding
  - File buffer handling
  - Unicode and special character support
  - Encoding overhead calculation

- **Encryption Utils (19 tests)**
  - AES-256-GCM encryption/decryption
  - RSA key pair generation
  - Secure key and IV generation
  - Error handling for invalid keys
  - Large data encryption

#### Integration Tests (10 tests)
- Complete OTP lifecycle workflows
- Multi-layer encryption workflows
- Encoding + Encryption pipelines
- Error handling scenarios
- Performance tests for large data

### Test Results

```bash
Test Suites: 5 passed, 5 total
Tests:       65 passed, 65 total
Coverage:    ~66% overall
  - otpService.js:     96% coverage
  - encodingUtils.js:  70% coverage
  - encryptionUtils.js: 58% coverage
  - emailService.js:   62% coverage
```

### Writing New Tests

Create test files in `tests/unit/` or `tests/integration/`:

```javascript
import { myFunction } from '../../../src/utils/myUtil.js';

describe('My Utility', () => {
  test('should do something', () => {
    const result = myFunction();
    expect(result).toBeDefined();
  });
});
```

### Test Configuration

- **Jest Config:** `jest.config.js`
- **Babel Config:** `babel.config.js` (for ES modules support)
- **Setup File:** `tests/setup.js` (test environment configuration)

## 🤝 Contributing

This is a university project for the EcoRide platform.

## 📄 License

MIT License - See LICENSE file for details

## 👥 Support

For issues or questions:
1. Check the troubleshooting section
2. Review PostgreSQL and Node.js documentation
3. Contact the development team

---

**EcoRide Backend API** - Powering Sustainable Transportation 🌱🚗
