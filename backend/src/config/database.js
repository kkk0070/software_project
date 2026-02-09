// Knex.js - SQL query builder and schema migration tool
import knexLib from 'knex';
// Knex configuration file with database connection settings
import knexConfig from './knexfile.js';
// PostgreSQL client library for Node.js
import pg from 'pg';
// Load environment variables from .env file
import dotenv from 'dotenv';

// Load environment variables into process.env
dotenv.config();

// Destructure Pool class from pg package for connection pooling
const { Pool } = pg;

// Initialize Knex instance with database configuration
// Knex provides query builder and migration capabilities
const knex = knexLib(knexConfig);

// Legacy PostgreSQL connection pool for backward compatibility
// Used by migration scripts and older code that doesn't use Knex
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',        // Database server hostname
  port: process.env.DB_PORT || 5432,               // PostgreSQL default port
  database: process.env.DB_NAME || 'ecoride_db',   // Database name
  user: process.env.DB_USER || 'postgres',         // Database user
  password: process.env.DB_PASSWORD,               // Database password from env
  max: 20,                                         // Maximum pool size (concurrent connections)
  idleTimeoutMillis: 30000,                        // Close idle clients after 30 seconds
  connectionTimeoutMillis: 2000,                   // Timeout if connection takes > 2 seconds
});

// Test database connection on startup using Knex
knex.raw('SELECT 1')
  .then(() => {
    // Connection successful - log to console
    console.log('[SUCCESS] Connected to PostgreSQL database via Knex');
  })
  .catch((err) => {
    // Connection failed - log error details
    console.error('[ERROR] Knex connection error:', err);
  });

// Legacy query helper function for executing raw SQL queries
// Provides query logging and error handling
// Used by migration scripts for backward compatibility
export const query = async (text, params) => {
  // Record query start time for performance tracking
  const start = Date.now();
  try {
    // Execute the query with parameterized values (prevents SQL injection)
    const res = await pool.query(text, params);
    // Calculate query execution time
    const duration = Date.now() - start;
    // Log query details for debugging and monitoring
    console.log('Executed query', { text, duration, rows: res.rowCount });
    return res;
  } catch (error) {
    // Log and re-throw errors for handling by caller
    console.error('Database query error:', error);
    throw error;
  }
};

// Export Knex instance as named export (preferred for new code)
export { knex };
// Export legacy pool as default export (for backward compatibility)
export default pool;
