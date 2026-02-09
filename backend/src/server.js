// Express framework for building the REST API server
import express from 'express';
// CORS middleware for handling cross-origin requests
import cors from 'cors';
// dotenv for loading environment variables from .env file
import dotenv from 'dotenv';
// HTTP server creation for Socket.io integration
import { createServer } from 'http';
// Route handlers for different API endpoints
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
// PostgreSQL connection pool for database operations
import pool from './config/database.js';
// Encryption key management utilities
import { initializeKeyManagement } from './utils/keyManagement.js';
// Socket.io service for real-time communication
import { initializeSocketIO } from './services/socketService.js';

// Load environment variables from .env file into process.env
dotenv.config();

// Auto-run migrations on startup to ensure database schema is up-to-date
// This function creates necessary tables and columns if they don't exist
const runMigrations = async () => {
  // Get a database client from the connection pool
  const client = await pool.connect();
  
  try {
    console.log('[INFO] Running automatic database migrations...');

    // Create encryption_keys table to store RSA key pairs for document encryption
    // This table manages the lifecycle of encryption keys (active, rotated, revoked)
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

    // Check which encryption-related columns already exist in the documents table
    // This prevents errors from trying to add columns that are already there
    const columnCheck = await client.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'documents' 
        AND column_name IN ('is_encrypted', 'encryption_key_id', 'encrypted_key', 'encryption_iv', 'encryption_auth_tag', 'encryption_algorithm')
    `);
    
    // Extract column names from the query result into an array
    const existingColumns = columnCheck.rows.map(row => row.column_name);
    
    // Add is_encrypted column to track whether a document is encrypted
    if (!existingColumns.includes('is_encrypted')) {
      await client.query(`ALTER TABLE documents ADD COLUMN is_encrypted BOOLEAN DEFAULT false`);
      console.log('[SUCCESS] Added is_encrypted column');
    }
    
    // Add encryption_key_id to reference which key was used to encrypt the document
    if (!existingColumns.includes('encryption_key_id')) {
      await client.query(`ALTER TABLE documents ADD COLUMN encryption_key_id VARCHAR(255) REFERENCES encryption_keys(key_id)`);
      console.log('[SUCCESS] Added encryption_key_id column');
    }
    
    // Add encrypted_key to store the encrypted symmetric key (hybrid encryption)
    if (!existingColumns.includes('encrypted_key')) {
      await client.query(`ALTER TABLE documents ADD COLUMN encrypted_key TEXT`);
      console.log('[SUCCESS] Added encrypted_key column');
    }
    
    // Add encryption_iv to store the initialization vector for AES encryption
    if (!existingColumns.includes('encryption_iv')) {
      await client.query(`ALTER TABLE documents ADD COLUMN encryption_iv TEXT`);
      console.log('[SUCCESS] Added encryption_iv column');
    }
    
    // Add encryption_auth_tag for authenticated encryption (GCM mode)
    if (!existingColumns.includes('encryption_auth_tag')) {
      await client.query(`ALTER TABLE documents ADD COLUMN encryption_auth_tag TEXT`);
      console.log('[SUCCESS] Added encryption_auth_tag column');
    }
    
    // Add encryption_algorithm to track which algorithm was used (e.g., AES-256-GCM)
    if (!existingColumns.includes('encryption_algorithm')) {
      await client.query(`ALTER TABLE documents ADD COLUMN encryption_algorithm VARCHAR(50)`);
      console.log('[SUCCESS] Added encryption_algorithm column');
    }
    
    // Add file_hash to verify document integrity and detect tampering
    if (!existingColumns.includes('file_hash')) {
      await client.query(`ALTER TABLE documents ADD COLUMN file_hash VARCHAR(64)`);
      console.log('[SUCCESS] Added file_hash column');
    }

    // Create database indexes to improve query performance on frequently accessed columns
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_documents_encryption_key 
      ON documents(encryption_key_id)
    `);
    
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_encryption_keys_key_id 
      ON encryption_keys(key_id)
    `);
    
    // Create chat-related tables for real-time messaging between riders and drivers
    console.log('[INFO] Creating chat tables...');
    
    // Conversations table stores chat sessions between riders and drivers for specific rides
    // Each conversation links a rider, driver, and optionally a ride
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

    // Messages table stores individual chat messages within conversations
    // Tracks sender, receiver, read status, and timestamp for each message
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

    // Create indexes on chat tables to optimize query performance
    // These improve the speed of lookups by conversation, sender, rider, and driver
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
    // Log detailed error information if migrations fail
    console.error('[ERROR] Migration failed:', error.message);
    console.error('[ERROR] Stack trace:', error.stack);
    console.error('\n[IMPORTANT] Database migrations failed! Please ensure:');
    console.error('  1. PostgreSQL is running');
    console.error('  2. Database exists (run: CREATE DATABASE ecoride_db;)');
    console.error('  3. Database credentials in .env are correct');
    console.error('  4. Or run manually: npm run init-db\n');
  } finally {
    // Always release the database client back to the pool
    client.release();
  }
};

// Log environment configuration for debugging purposes
// Helps verify that .env file is loaded correctly
console.log('[INFO] Environment Variables Loaded:');
console.log('  PORT:', process.env.PORT);
console.log('  NODE_ENV:', process.env.NODE_ENV);
// Don't log the actual JWT secret, just confirm it's set
console.log('  JWT_SECRET:', process.env.JWT_SECRET ? '[SUCCESS] Set' : '[ERROR] Not set');
console.log('  DB_HOST:', process.env.DB_HOST);
console.log('  DB_NAME:', process.env.DB_NAME);

// Validate that critical environment variables are configured
// JWT_SECRET is required for authentication, so the server shouldn't start without it
if (!process.env.JWT_SECRET) {
  console.error('[ERROR] FATAL ERROR: JWT_SECRET is not configured in .env file');
  console.error('Please set JWT_SECRET in your .env file before starting the server');
  // Exit with error code 1 to indicate failure
  process.exit(1);
}

// Create Express application instance
const app = express();
// Get port from environment or use default 5000
const PORT = process.env.PORT || 5000;

// Create HTTP server to enable Socket.io for real-time features
const httpServer = createServer(app);

// Middleware setup for the Express application

// CORS (Cross-Origin Resource Sharing) configuration
// Allows the frontend applications to communicate with the backend API
const corsOptions = {
  // Dynamic origin validation function
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, Postman, curl, etc.)
    if (!origin) return callback(null, true);
    
    // Whitelist of allowed origins for security
    const allowedOrigins = [
      'http://localhost:5173',  // Admin dashboard development server
      /^http:\/\/localhost:[3-9]\d{3}$/,  // Any localhost port from 3000-9999
      /^http:\/\/127\.0\.0\.1:[3-9]\d{3}$/,  // Same for 127.0.0.1
    ];
    
    // Check if the request origin matches any allowed pattern
    const isAllowed = allowedOrigins.some(pattern => {
      if (typeof pattern === 'string') {
        // Exact string match
        return origin === pattern;
      } else if (pattern instanceof RegExp) {
        // Regular expression match
        return pattern.test(origin);
      }
      return false;
    });
    
    // Determine if we're in development mode
    const isDevelopment = process.env.NODE_ENV === 'development';
    if (isAllowed) {
      // Origin is in whitelist, allow the request
      callback(null, true);
    } else if (isDevelopment) {
      // In development, allow all origins but log a warning for security awareness
      console.warn(`[WARNING]  CORS: Allowing origin ${origin} in development mode`);
      callback(null, true);
    } else {
      // In production, reject origins not in whitelist
      callback(new Error('Not allowed by CORS'));
    }
  },
  // Allow credentials (cookies, authorization headers) to be sent with requests
  credentials: true
};

// Apply CORS middleware with the configured options
app.use(cors(corsOptions));
// Parse incoming JSON request bodies
app.use(express.json());
// Parse URL-encoded request bodies (form submissions)
app.use(express.urlencoded({ extended: true }));

// Static file serving configuration
// Serve uploaded files (profile photos, documents) from the uploads directory
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import path from 'path';

// Convert file URL to path (required for ES modules)
const __filename = fileURLToPath(import.meta.url);
// Get directory name from file path
const __dirname = dirname(__filename);

// Make uploads directory accessible via HTTP requests
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Request logging middleware - logs all incoming requests for debugging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  // Continue to next middleware
  next();
});

// Health check endpoint - verifies server and database are working
app.get('/health', async (req, res) => {
  try {
    // Test database connection by executing a simple query
    const result = await pool.query('SELECT NOW()');
    // Return success status with database timestamp
    res.json({
      status: 'OK',
      timestamp: result.rows[0].now,
      uptime: process.uptime(),
      database: 'Connected'
    });
  } catch (error) {
    // Return error status if database connection fails
    res.status(500).json({
      status: 'ERROR',
      message: 'Database connection failed',
      error: error.message
    });
  }
});

// Public security analysis endpoint for demonstrating security features
// No authentication required - intended for demo purposes
import { analyzeBase64Security, generateSecurityReport, getSecuritySummary } from './utils/securityAnalysis.js';
app.get('/api/security-demo', (req, res) => {
  try {
    // Generate security analysis of the system
    const analysis = analyzeBase64Security();
    // Get summarized security metrics
    const summary = getSecuritySummary();
    
    // Print detailed security report to server console
    console.log(generateSecurityReport());
    
    // Return analysis results to client
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

// API Routes Registration
// Mount route handlers at their respective paths
app.use('/api/auth', authRoutes);              // Authentication (login, signup, 2FA)
app.use('/api/documents', documentRoutes);    // Document upload and verification
app.use('/api/users', userRoutes);            // User profile management
app.use('/api/rides', rideRoutes);            // Ride booking and management
app.use('/api/emergency', emergencyRoutes);   // Emergency SOS features
app.use('/api/analytics', analyticsRoutes);   // Driver analytics and statistics
app.use('/api/monitoring', monitoringRoutes); // System monitoring for admin
app.use('/api/notifications', notificationRoutes); // Push notifications
app.use('/api/settings', settingsRoutes);     // User settings and preferences
app.use('/api/reports', reportsRoutes);       // Reporting and analytics
app.use('/api/chat', chatRoutes);             // Real-time chat messaging

// Root endpoint - API documentation and available endpoints
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

// 404 handler - returns error for undefined routes
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Global error handling middleware - catches all unhandled errors
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error',
    // Only expose detailed error info in development mode
    error: process.env.NODE_ENV === 'development' ? err : {}
  });
});

// Start the HTTP server and initialize all services
httpServer.listen(PORT, async () => {
  // Display startup banner with server configuration
  console.log(`
╔═══════════════════════════════════════════╗
║   🚀 EcoRide Backend API Server          ║
║   📡 Port: ${PORT}
║   🌍 Environment: ${process.env.NODE_ENV || 'development'}
║   🔗 CORS Origin: ${process.env.CORS_ORIGIN || 'http://localhost:5173'}
║   🔌 WebSocket: Enabled
╚═══════════════════════════════════════════╝
  `);
  
  try {
    // Step 1: Run database migrations to ensure schema is up-to-date
    await runMigrations();
    
    // Step 2: Initialize encryption key management system
    await initializeKeyManagement();
    
    // Step 3: Initialize Socket.io for real-time notifications and chat
    initializeSocketIO(httpServer);
    console.log('[SUCCESS] Real-time notifications enabled via WebSocket');
  } catch (error) {
    console.error('[WARNING]  Error during initialization:', error.message);
    // Identify if error is from WebSocket initialization
    if (error.stack && error.stack.includes('socketService.js')) {
      console.error('[ERROR] WebSocket functionality unavailable - server running in degraded mode');
    }
  }
});

// Graceful shutdown handler for SIGTERM signal
// Properly closes database connections before exiting
process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing server gracefully...');
  // Close database connection pool
  pool.end(() => {
    console.log('Database pool closed');
    process.exit(0);
  });
});

// Graceful shutdown handler for SIGINT signal (Ctrl+C)
// Properly closes database connections before exiting
process.on('SIGINT', () => {
  console.log('SIGINT received, closing server gracefully...');
  // Close database connection pool
  pool.end(() => {
    console.log('Database pool closed');
    process.exit(0);
  });
});

// Export the Express app for testing purposes
export default app;
