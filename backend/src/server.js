import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import bcrypt from 'bcrypt';

import userRoutes from './routes/driver/userRoutes.js';
import rideRoutes from './routes/rider/rideRoutes.js';
import emergencyRoutes from './routes/shared/emergencyRoutes.js';
import authRoutes from './routes/shared/authRoutes.js';
import documentRoutes from './routes/driver/documentRoutes.js';
import analyticsRoutes from './routes/driver/analyticsRoutes.js';
import monitoringRoutes from './routes/shared/monitoringRoutes.js';
import notificationRoutes from './routes/shared/notificationRoutes.js';
import settingsRoutes from './routes/shared/settingsRoutes.js';
import reportsRoutes from './routes/shared/reportsRoutes.js';
import chatRoutes from './routes/shared/chatRoutes.js';
import pool from './config/database.js';
import { initializeKeyManagement } from './utils/keyManagement.js';
import { initializeSocketIO } from './services/socketService.js';

// Load environment variables
dotenv.config();

// Auto-run migrations on startup
const runMigrations = async () => {
  const client = await pool.connect();

  try {
    // Users table
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        phone VARCHAR(50),
        location VARCHAR(255),
        profile_photo TEXT,
        role VARCHAR(50) DEFAULT 'Rider' CHECK (role IN ('Rider', 'Driver', 'Admin')),
        status VARCHAR(50) DEFAULT 'Active' CHECK (status IN ('Active', 'Suspended', 'Pending')),
        verified BOOLEAN DEFAULT false,
        profile_setup_complete BOOLEAN DEFAULT false,
        rating DECIMAL(3,2) DEFAULT 0.0,
        total_rides INTEGER DEFAULT 0,
        two_factor_enabled BOOLEAN DEFAULT false,
        two_factor_secret VARCHAR(255),
        joined_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Users table ready');

    // Drivers table
    await client.query(`
      CREATE TABLE IF NOT EXISTS drivers (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        vehicle_type VARCHAR(50) CHECK (vehicle_type IN ('Electric Vehicle', 'Hybrid', 'Gas')),
        vehicle_model VARCHAR(255),
        license_plate VARCHAR(50),
        license_number VARCHAR(100),
        vehicle_year INTEGER,
        available BOOLEAN DEFAULT true,
        earnings DECIMAL(10,2) DEFAULT 0.00,
        verification_status VARCHAR(50) DEFAULT 'Pending' CHECK (verification_status IN ('Pending', 'Verified', 'Rejected')),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id)
      );
    `);
    console.log('[SUCCESS] Drivers table ready');

    // Rides table
    await client.query(`
      CREATE TABLE IF NOT EXISTS rides (
        id SERIAL PRIMARY KEY,
        rider_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
        driver_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
        pickup_location VARCHAR(255) NOT NULL,
        dropoff_location VARCHAR(255) NOT NULL,
        pickup_lat DECIMAL(10, 8),
        pickup_lng DECIMAL(11, 8),
        dropoff_lat DECIMAL(10, 8),
        dropoff_lng DECIMAL(11, 8),
        ride_type VARCHAR(50) DEFAULT 'Solo' CHECK (ride_type IN ('Solo', 'Pool', 'EV')),
        status VARCHAR(50) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Active', 'Completed', 'Cancelled')),
        fare DECIMAL(10,2),
        distance DECIMAL(10,2),
        duration INTEGER,
        carbon_saved DECIMAL(10,3),
        rating DECIMAL(3,2),
        scheduled_time TIMESTAMP,
        started_at TIMESTAMP,
        completed_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Rides table ready');

    // Emergency incidents table
    await client.query(`
      CREATE TABLE IF NOT EXISTS emergency_incidents (
        id SERIAL PRIMARY KEY,
        ride_id INTEGER REFERENCES rides(id) ON DELETE CASCADE,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        incident_type VARCHAR(100) NOT NULL,
        description TEXT,
        location VARCHAR(255),
        latitude DECIMAL(10, 8),
        longitude DECIMAL(11, 8),
        status VARCHAR(50) DEFAULT 'Open' CHECK (status IN ('Open', 'In Progress', 'Resolved')),
        priority VARCHAR(50) DEFAULT 'Medium' CHECK (priority IN ('Low', 'Medium', 'High', 'Critical')),
        resolved_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Emergency incidents table ready');

    // Carbon savings table
    await client.query(`
      CREATE TABLE IF NOT EXISTS carbon_savings (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        ride_id INTEGER REFERENCES rides(id) ON DELETE CASCADE,
        co2_saved DECIMAL(10,3),
        trees_equivalent DECIMAL(10,2),
        recorded_date DATE DEFAULT CURRENT_DATE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Carbon savings table ready');

    // System logs table
    await client.query(`
      CREATE TABLE IF NOT EXISTS system_logs (
        id SERIAL PRIMARY KEY,
        log_type VARCHAR(50) NOT NULL CHECK (log_type IN ('Error', 'Warning', 'Info', 'Security')),
        message TEXT NOT NULL,
        details JSONB,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] System logs table ready');

    // Settings table
    await client.query(`
      CREATE TABLE IF NOT EXISTS settings (
        id SERIAL PRIMARY KEY,
        key VARCHAR(100) UNIQUE NOT NULL,
        value TEXT NOT NULL,
        category VARCHAR(50),
        description TEXT,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Settings table ready');

    // Seed admin if not exists
    const adminCheck = await client.query(`SELECT id FROM users WHERE email = 'admin@ecoride.com'`);
    if (adminCheck.rows.length === 0) {
      const adminPasswordHash = await bcrypt.hash('admin123', 10);
      await client.query(`
        INSERT INTO users (name, email, password, role, status, verified, location)
        VALUES ('Admin User', 'admin@ecoride.com', $1, 'Admin', 'Active', true, 'Headquarters')
      `, [adminPasswordHash]);
      console.log('[SUCCESS] Admin user seeded: admin@ecoride.com / admin123');
    }

    // Existing migrations for encryption and chat...
    // Encryption keys table
    await client.query(`
      CREATE TABLE IF NOT EXISTS encryption_keys (
        id SERIAL PRIMARY KEY,
        key_id VARCHAR(255) UNIQUE NOT NULL,
        key_name VARCHAR(255) NOT NULL,
        public_key TEXT NOT NULL,
        private_key TEXT NOT NULL,
        key_type VARCHAR(50) DEFAULT 'RSA-2048',
        status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'rotated', 'revoked')),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        rotated_at TIMESTAMP,
        revoked_at TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Encryption keys table ready');

    // Add encryption columns to documents table if they don't exist
    const columnCheck = await client.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'documents' 
        AND column_name IN ('is_encrypted', 'encryption_key_id', 'encrypted_key', 'encryption_iv', 'encryption_auth_tag', 'encryption_algorithm', 'file_hash')
    `);

    const existingColumns = columnCheck.rows.map(row => row.column_name);

    if (!existingColumns.includes('is_encrypted')) {
      await client.query(`ALTER TABLE documents ADD COLUMN is_encrypted BOOLEAN DEFAULT false`);
      console.log('[SUCCESS] Added is_encrypted column');
    }

    if (!existingColumns.includes('encryption_key_id')) {
      await client.query(`ALTER TABLE documents ADD COLUMN encryption_key_id VARCHAR(255) REFERENCES encryption_keys(key_id)`);
      console.log('[SUCCESS] Added encryption_key_id column');
    }

    if (!existingColumns.includes('encrypted_key')) {
      await client.query(`ALTER TABLE documents ADD COLUMN encrypted_key TEXT`);
      console.log('[SUCCESS] Added encrypted_key column');
    }

    if (!existingColumns.includes('encryption_iv')) {
      await client.query(`ALTER TABLE documents ADD COLUMN encryption_iv TEXT`);
      console.log('[SUCCESS] Added encryption_iv column');
    }

    if (!existingColumns.includes('encryption_auth_tag')) {
      await client.query(`ALTER TABLE documents ADD COLUMN encryption_auth_tag TEXT`);
      console.log('[SUCCESS] Added encryption_auth_tag column');
    }

    if (!existingColumns.includes('encryption_algorithm')) {
      await client.query(`ALTER TABLE documents ADD COLUMN encryption_algorithm VARCHAR(50)`);
      console.log('[SUCCESS] Added encryption_algorithm column');
    }

    if (!existingColumns.includes('file_hash')) {
      await client.query(`ALTER TABLE documents ADD COLUMN file_hash VARCHAR(64)`);
      console.log('[SUCCESS] Added file_hash column');
    }

    // Create indexes
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_documents_encryption_key 
      ON documents(encryption_key_id)
    `);

    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_encryption_keys_key_id 
      ON encryption_keys(key_id)
    `);

    // Create chat tables
    console.log('[INFO] Creating chat tables...');

    await client.query(`
      CREATE TABLE IF NOT EXISTS conversations (
        id SERIAL PRIMARY KEY,
        rider_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        driver_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        ride_id INTEGER REFERENCES rides(id) ON DELETE SET NULL,
        last_message TEXT,
        last_message_time TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(rider_id, driver_id)
      );
    `);
    console.log('[SUCCESS] Conversations table created');

    await client.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
        sender_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        receiver_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        message TEXT NOT NULL,
        is_read BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Messages table created');

    // Create chat indexes
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_messages_conversation 
      ON messages(conversation_id);
    `);

    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_messages_sender 
      ON messages(sender_id);
    `);

    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_conversations_rider 
      ON conversations(rider_id);
    `);

    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_conversations_driver 
      ON conversations(driver_id);
    `);
    console.log('[SUCCESS] Chat indexes created');

    console.log('[SUCCESS] Database migrations completed\n');
  } catch (error) {
    console.error('[ERROR] Migration failed:', error.message);
    console.error('[ERROR] Stack trace:', error.stack);
    console.error('\n[IMPORTANT] Database migrations failed! Please ensure:');
    console.error('  1. PostgreSQL is running');
    console.error('  2. Database exists (run: CREATE DATABASE ecoride_db;)');
    console.error('  3. Database credentials in .env are correct');
    console.error('  4. Or run manually: npm run init-db\n');
  } finally {
    client.release();
  }
};

// Debug: Log environment variables
console.log('📋 Environment Variables Loaded:');
console.log('  PORT:', process.env.PORT);
console.log('  NODE_ENV:', process.env.NODE_ENV);
console.log('  JWT_SECRET:', process.env.JWT_SECRET ? '[SUCCESS] Set' : '[ERROR] Not set');
console.log('  DB_HOST:', process.env.DB_HOST);
console.log('  DB_NAME:', process.env.DB_NAME);

// Validate critical environment variables
if (!process.env.JWT_SECRET) {
  console.error('[ERROR] FATAL ERROR: JWT_SECRET is not configured in .env file');
  console.error('Please set JWT_SECRET in your .env file before starting the server');
  process.exit(1);
}

const app = express();
const PORT = process.env.PORT || 5000;

// Create HTTP server for Socket.io
const httpServer = createServer(app);

// Middleware
// CORS configuration to support multiple origins including Flutter Web
const corsOptions = {
  origin: true, // Allow all origins during debugging
  credentials: true
};

app.use(cors(corsOptions));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logger for debugging
app.use((req, res, next) => {
  console.log(`[EcoRide] ${req.method} ${req.url}`);
  next();
});

// Serve static files for uploaded photos
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({
      status: 'OK',
      timestamp: result.rows[0].now,
      uptime: process.uptime(),
      database: 'Connected'
    });
  } catch (error) {
    res.status(500).json({
      status: 'ERROR',
      message: 'Database connection failed',
      error: error.message
    });
  }
});

// Public security analysis endpoint (no auth required for demo)
import { analyzeBase64Security, generateSecurityReport, getSecuritySummary } from './utils/securityAnalysis.js';
app.get('/api/security-demo', (req, res) => {
  try {
    const analysis = analyzeBase64Security();
    const summary = getSecuritySummary();

    // Log to terminal
    console.log(generateSecurityReport());

    res.json({
      success: true,
      data: {
        analysis,
        summary
      },
      message: 'Security analysis logged to terminal'
    });
  } catch (error) {
    console.error('Error generating security analysis:', error);
    res.status(500).json({
      success: false,
      message: 'Error generating security analysis',
      error: error.message
    });
  }
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/documents', documentRoutes);
app.use('/api/users', userRoutes);
app.use('/api/rides', rideRoutes);
app.use('/api/emergency', emergencyRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/monitoring', monitoringRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/settings', settingsRoutes);
app.use('/api/reports', reportsRoutes);
app.use('/api/chat', chatRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'EcoRide Backend API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      auth: '/api/auth',
      documents: '/api/documents',
      users: '/api/users',
      rides: '/api/rides',
      emergency: '/api/emergency',
      analytics: '/api/analytics',
      monitoring: '/api/monitoring',
      notifications: '/api/notifications',
      settings: '/api/settings',
      reports: '/api/reports',
      chat: '/api/chat'
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err : {}
  });
});

// Start server
httpServer.listen(PORT, async () => {
  // Define API_BASE_URL here for logging purposes, assuming it's derived from the server's own address
  // In a real scenario, VITE_API_URL would be a frontend environment variable.
  // For server-side logging, we'll use the server's own address.
  const API_BASE_URL = `http://localhost:${PORT}`;
  console.log(`
╔═══════════════════════════════════════════╗
║   🚀 EcoRide Backend API Server          ║
║   📡 Port: ${PORT}
║   🌍 Environment: ${process.env.NODE_ENV || 'development'}
║   🔗 CORS Origin: ${process.env.CORS_ORIGIN || 'http://localhost:5173'}
║   API_BASE_URL: ${API_BASE_URL}
║   🔌 WebSocket: Enabled
╚═══════════════════════════════════════════╝
  `);
  console.log('[EcoRide] API_BASE_URL:', API_BASE_URL); // Added this line as per instruction

  try {
    // Run migrations first
    await runMigrations();

    // Then initialize encryption key management
    await initializeKeyManagement();

    // Initialize Socket.io for real-time notifications
    initializeSocketIO(httpServer);
    console.log('[SUCCESS] Real-time notifications enabled via WebSocket');
  } catch (error) {
    console.error('[WARNING]  Error during initialization:', error.message);
    // Check if error is related to WebSocket initialization
    if (error.stack && error.stack.includes('socketService.js')) {
      console.error('[ERROR] WebSocket functionality unavailable - server running in degraded mode');
    }
  }
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing server gracefully...');
  pool.end(() => {
    console.log('Database pool closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, closing server gracefully...');
  pool.end(() => {
    console.log('Database pool closed');
    process.exit(0);
  });
});

export default app;
