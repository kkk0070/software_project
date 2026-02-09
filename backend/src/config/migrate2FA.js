import pool from './database.js';

/**
 * Migration to add 2FA fields to users table
 */
const add2FAFields = async () => {
  const client = await pool.connect();
  
  try {
    console.log('[INFO] Adding 2FA fields to users table...');

    // Check if columns already exist
    const checkQuery = `
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'users' 
      AND column_name IN ('two_factor_enabled', 'two_factor_secret');
    `;
    
    const result = await client.query(checkQuery);
    
    if (result.rows.length === 0) {
      // Add 2FA columns
      await client.query(`
        ALTER TABLE users
        ADD COLUMN IF NOT EXISTS two_factor_enabled BOOLEAN DEFAULT false,
        ADD COLUMN IF NOT EXISTS two_factor_secret VARCHAR(255);
      `);
      console.log('[SUCCESS] 2FA fields added successfully');
    } else {
      console.log('[INFO]  2FA fields already exist');
    }
    
  } catch (error) {
    console.error('[ERROR] Error adding 2FA fields:', error);
    throw error;
  } finally {
    client.release();
  }
};

// Run migration if called directly
const scriptPath = process.argv[1];
if (scriptPath && scriptPath.includes('migrate2FA.js')) {
  add2FAFields()
    .then(() => {
      console.log('Migration completed successfully');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Migration failed:', error);
      process.exit(1);
    });
}

export default add2FAFields;
