import pool from './database.js';

const migrateDatabase = async () => {
  const client = await pool.connect();
  
  try {
    console.log('[INFO] Running database migrations...');

    // Add profile_setup_complete column to users table if it doesn't exist
    await client.query(`
      DO $$ 
      BEGIN 
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name='users' AND column_name='profile_setup_complete'
        ) THEN
          ALTER TABLE users ADD COLUMN profile_setup_complete BOOLEAN DEFAULT false;
          RAISE NOTICE 'Added profile_setup_complete column to users table';
        END IF;
      END $$;
    `);
    console.log('[SUCCESS] Users table migration completed');

    // Add earnings and verification_status columns to drivers table if they don't exist
    await client.query(`
      DO $$ 
      BEGIN 
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name='drivers' AND column_name='earnings'
        ) THEN
          ALTER TABLE drivers ADD COLUMN earnings DECIMAL(10,2) DEFAULT 0.00;
          RAISE NOTICE 'Added earnings column to drivers table';
        END IF;
        
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name='drivers' AND column_name='verification_status'
        ) THEN
          ALTER TABLE drivers ADD COLUMN verification_status VARCHAR(50) DEFAULT 'Pending' CHECK (verification_status IN ('Pending', 'Verified', 'Rejected'));
          RAISE NOTICE 'Added verification_status column to drivers table';
        END IF;
      END $$;
    `);
    console.log('[SUCCESS] Drivers table migration completed');

    // Add status, verified_at, and verified_by columns to documents table if they don't exist
    await client.query(`
      DO $$ 
      BEGIN 
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name='documents' AND column_name='status'
        ) THEN
          ALTER TABLE documents ADD COLUMN status VARCHAR(50) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected'));
          RAISE NOTICE 'Added status column to documents table';
        END IF;
        
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name='documents' AND column_name='verified_at'
        ) THEN
          ALTER TABLE documents ADD COLUMN verified_at TIMESTAMP;
          RAISE NOTICE 'Added verified_at column to documents table';
        END IF;
        
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name='documents' AND column_name='verified_by'
        ) THEN
          ALTER TABLE documents ADD COLUMN verified_by INTEGER REFERENCES users(id);
          RAISE NOTICE 'Added verified_by column to documents table';
        END IF;
      END $$;
    `);
    console.log('[SUCCESS] Documents table migration completed');

    console.log('[COMPLETE] All migrations completed successfully!');
  } catch (error) {
    console.error('[ERROR] Error during migration:', error);
    throw error;
  } finally {
    client.release();
  }
};

const runMigration = async () => {
  try {
    await migrateDatabase();
    process.exit(0);
  } catch (error) {
    console.error('[ERROR] Migration failed:', error);
    process.exit(1);
  }
};

runMigration();
