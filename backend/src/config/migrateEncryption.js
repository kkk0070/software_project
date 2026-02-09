/**
 * Database Migration: Add Encryption Support
 * Creates encryption_keys table and adds encryption metadata to documents table
 */

import pool from './database.js';

const migrateEncryption = async () => {
  const client = await pool.connect();
  
  try {
    console.log('[INFO] Starting encryption migration...');
    console.log('');
    
    // Check if documents table exists first
    const tableCheck = await client.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'documents'
      );
    `);
    
    if (!tableCheck.rows[0].exists) {
      console.error('[ERROR] Error: "documents" table does not exist!');
      console.error('');
      console.error('The documents table must exist before running this migration.');
      console.error('Please run the base database initialization first:');
      console.error('');
      console.error('  npm run init-db');
      console.error('');
      console.error('Then run this migration again.');
      throw new Error('documents table does not exist');
    }
    
    // Create encryption_keys table
    console.log('📝 Creating encryption_keys table...');
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
    console.log('[SUCCESS] encryption_keys table created');
    
    // Add encryption-related columns to documents table if they don't exist
    console.log('📝 Adding encryption columns to documents table...');
    
    // Check if columns exist first
    const columnCheck = await client.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'documents' 
        AND column_name IN ('is_encrypted', 'encryption_key_id', 'encrypted_key', 'encryption_iv', 'encryption_auth_tag', 'encryption_algorithm')
    `);
    
    const existingColumns = columnCheck.rows.map(row => row.column_name);
    
    if (!existingColumns.includes('is_encrypted')) {
      await client.query(`
        ALTER TABLE documents 
        ADD COLUMN is_encrypted BOOLEAN DEFAULT false
      `);
      console.log('[SUCCESS] Added is_encrypted column');
    }
    
    if (!existingColumns.includes('encryption_key_id')) {
      await client.query(`
        ALTER TABLE documents 
        ADD COLUMN encryption_key_id VARCHAR(255) REFERENCES encryption_keys(key_id)
      `);
      console.log('[SUCCESS] Added encryption_key_id column');
    }
    
    if (!existingColumns.includes('encrypted_key')) {
      await client.query(`
        ALTER TABLE documents 
        ADD COLUMN encrypted_key TEXT
      `);
      console.log('[SUCCESS] Added encrypted_key column');
    }
    
    if (!existingColumns.includes('encryption_iv')) {
      await client.query(`
        ALTER TABLE documents 
        ADD COLUMN encryption_iv TEXT
      `);
      console.log('[SUCCESS] Added encryption_iv column');
    }
    
    if (!existingColumns.includes('encryption_auth_tag')) {
      await client.query(`
        ALTER TABLE documents 
        ADD COLUMN encryption_auth_tag TEXT
      `);
      console.log('[SUCCESS] Added encryption_auth_tag column');
    }
    
    if (!existingColumns.includes('encryption_algorithm')) {
      await client.query(`
        ALTER TABLE documents 
        ADD COLUMN encryption_algorithm VARCHAR(50)
      `);
      console.log('[SUCCESS] Added encryption_algorithm column');
    }
    
    if (!existingColumns.includes('file_hash')) {
      await client.query(`
        ALTER TABLE documents 
        ADD COLUMN file_hash VARCHAR(64)
      `);
      console.log('[SUCCESS] Added file_hash column');
    }
    
    // Create index on encryption_key_id for faster lookups
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_documents_encryption_key 
      ON documents(encryption_key_id)
    `);
    console.log('[SUCCESS] Created index on encryption_key_id');
    
    // Create index on key_id in encryption_keys
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_encryption_keys_key_id 
      ON encryption_keys(key_id)
    `);
    console.log('[SUCCESS] Created index on key_id');
    
    console.log('[COMPLETE] Encryption migration completed successfully!');
    console.log('\n[INFO]  Next steps:');
    console.log('   1. Generate master key pair by starting the server');
    console.log('   2. New document uploads will be encrypted automatically');
    console.log('   3. Existing documents remain unencrypted unless re-uploaded');
    
  } catch (error) {
    console.error('[ERROR] Error during encryption migration:', error.message);
    console.error('');
    
    // Provide specific guidance based on error type
    if (error.code === 'ECONNREFUSED') {
      console.error('Database connection refused. Please check:');
      console.error('  1. PostgreSQL is running');
      console.error('  2. Database connection settings in .env file');
      console.error('  3. Database exists: createdb -U postgres ecoride_db');
    } else if (error.code === '3D000') {
      console.error('Database does not exist. Create it with:');
      console.error('  createdb -U postgres ecoride_db');
    } else if (error.code === '28P01') {
      console.error('Authentication failed. Please check:');
      console.error('  1. DB_USER in .env file');
      console.error('  2. DB_PASSWORD in .env file');
    } else if (error.code === '42P01') {
      console.error('Table does not exist. Run base initialization first:');
      console.error('  npm run init-db');
    } else if (error.message === 'documents table does not exist') {
      // Already handled above with detailed message
    } else {
      console.error('Unexpected error. Please check the error message above.');
      console.error('');
      console.error('Common issues:');
      console.error('  1. Run: npm install (to install dependencies)');
      console.error('  2. Create .env file: cp .env.example .env');
      console.error('  3. Run: npm run init-db (to create base tables)');
      console.error('  4. Ensure PostgreSQL is running');
    }
    console.error('');
    throw error;
  } finally {
    client.release();
  }
};

// Run migration if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  migrateEncryption()
    .then(() => {
      console.log('[SUCCESS] Migration completed');
      process.exit(0);
    })
    .catch((error) => {
      console.error('[ERROR] Migration failed:', error);
      process.exit(1);
    });
}

export default migrateEncryption;
