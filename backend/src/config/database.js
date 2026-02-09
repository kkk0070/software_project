import knexLib from 'knex';
import knexConfig from './knexfile.js';
import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;

// Initialize Knex with configuration
const knex = knexLib(knexConfig);

// Keep legacy pool for backwards compatibility (migrations and other scripts)
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'ecoride_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test Knex connection
knex.raw('SELECT 1')
  .then(() => {
    console.log('[SUCCESS] Connected to PostgreSQL database via Knex');
  })
  .catch((err) => {
    console.error('[ERROR] Knex connection error:', err);
  });

// Legacy query helper function (for backward compatibility with migrations)
export const query = async (text, params) => {
  const start = Date.now();
  try {
    const res = await pool.query(text, params);
    const duration = Date.now() - start;
    console.log('Executed query', { text, duration, rows: res.rowCount });
    return res;
  } catch (error) {
    console.error('Database query error:', error);
    throw error;
  }
};

// Export both Knex and legacy pool
export { knex };
export default pool;
