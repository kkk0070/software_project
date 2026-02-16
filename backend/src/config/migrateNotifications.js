import pkg from 'pg';
const { Client } = pkg;
import dotenv from 'dotenv';

dotenv.config();

const migrationClient = new Client({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'carpool_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

async function migrateNotifications() {
  try {
    await migrationClient.connect();
    console.log('[INFO] Connected to database for notifications migration');

    // Add conversation_id and sender_id columns to notifications table
    console.log('[INFO] Adding conversation_id and sender_id to notifications table...');
    
    // Check if columns already exist
    const checkColumns = await migrationClient.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'notifications' 
      AND column_name IN ('conversation_id', 'sender_id')
    `);

    if (checkColumns.rows.length === 0) {
      await migrationClient.query(`
        ALTER TABLE notifications
        ADD COLUMN IF NOT EXISTS conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
        ADD COLUMN IF NOT EXISTS sender_id INTEGER REFERENCES users(id) ON DELETE SET NULL
      `);
      console.log('[SUCCESS] Added conversation_id and sender_id columns to notifications table');
    } else {
      console.log('[INFO] Columns already exist, skipping migration');
    }

    console.log('[SUCCESS] Notifications migration completed successfully');
  } catch (error) {
    console.error('[ERROR] Notifications migration failed:', error);
    throw error;
  } finally {
    await migrationClient.end();
  }
}

// Run migration if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  migrateNotifications()
    .then(() => {
      console.log('[SUCCESS] Migration script completed');
      process.exit(0);
    })
    .catch((error) => {
      console.error('[ERROR] Migration script failed:', error);
      process.exit(1);
    });
}

export { migrateNotifications };
