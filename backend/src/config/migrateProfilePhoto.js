import pool from './database.js';

const migrateProfilePhoto = async () => {
  const client = await pool.connect();
  
  try {
    console.log('\n[INFO] Starting profile photo migration...');

    // Check if profile_photo column already exists
    const columnCheck = await client.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'users' 
      AND column_name = 'profile_photo'
    `);

    if (columnCheck.rows.length > 0) {
      console.log('[INFO] Column profile_photo already exists in users table');
      return;
    }

    // Add profile_photo column
    await client.query(`
      ALTER TABLE users 
      ADD COLUMN profile_photo TEXT
    `);

    console.log('[SUCCESS] Added profile_photo column to users table');

  } catch (error) {
    console.error('[ERROR] Migration failed:', error.message);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
};

// Run migration if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  migrateProfilePhoto()
    .then(() => {
      console.log('[SUCCESS] Profile photo migration completed');
      process.exit(0);
    })
    .catch((error) => {
      console.error('[ERROR] Migration failed:', error);
      process.exit(1);
    });
}

export default migrateProfilePhoto;
