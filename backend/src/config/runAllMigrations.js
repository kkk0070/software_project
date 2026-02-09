/**
 * Run all database migrations in sequence
 */

import pool from './database.js';

const runMigrateDatabase = async () => {
  // Since migrateDatabase.js doesn't export, we'll execute it directly
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

  } catch (error) {
    console.error('[ERROR] Error during migration:', error);
    throw error;
  } finally {
    client.release();
  }
};

const run2FAMigration = async () => {
  const { default: add2FAFields } = await import('./migrate2FA.js');
  return add2FAFields();
};

const runEncryptionMigration = async () => {
  const { default: migrateEncryption } = await import('./migrateEncryption.js');
  return migrateEncryption();
};

const runChatMigration = async () => {
  const { default: migrateChatTables } = await import('./migrateChat.js');
  return migrateChatTables();
};

const runProfilePhotoMigration = async () => {
  const { default: migrateProfilePhoto } = await import('./migrateProfilePhoto.js');
  return migrateProfilePhoto();
};

const runAllMigrations = async () => {
  try {
    console.log('[INFO] Starting all database migrations...\n');

    // Step 1: Run main database migration
    console.log('📍 Step 1: Main database migration');
    await runMigrateDatabase();
    console.log('[SUCCESS] Main database migration completed\n');

    // Step 2: Run 2FA migration
    console.log('📍 Step 2: 2FA migration');
    try {
      await run2FAMigration();
      console.log('[SUCCESS] 2FA migration completed\n');
    } catch (e) {
      console.log('[INFO]  2FA migration completed or skipped\n');
    }

    // Step 3: Run encryption migration
    console.log('📍 Step 3: Encryption migration');
    try {
      await runEncryptionMigration();
      console.log('[SUCCESS] Encryption migration completed\n');
    } catch (e) {
      console.log('[INFO]  Encryption migration completed or skipped\n');
    }

    // Step 4: Run chat migration
    console.log('📍 Step 4: Chat migration');
    try {
      await runChatMigration();
      console.log('[SUCCESS] Chat migration completed\n');
    } catch (e) {
      console.log('[INFO]  Chat migration completed or skipped\n');
    }

    // Step 5: Run profile photo migration
    console.log('📍 Step 5: Profile photo migration');
    try {
      await runProfilePhotoMigration();
      console.log('[SUCCESS] Profile photo migration completed\n');
    } catch (e) {
      console.log('[INFO]  Profile photo migration completed or skipped\n');
    }

    console.log('[COMPLETE] All migrations completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('[ERROR] Migration failed:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
};

// Run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  runAllMigrations();
}

export default runAllMigrations;
