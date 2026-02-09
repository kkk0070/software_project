import pool from './database.js';
import { pathToFileURL } from 'url';

/**
 * Check if chat tables exist and create them if they don't
 * This script can be run standalone to fix the "conversations does not exist" error
 */

const checkAndFixChatTables = async () => {
  const client = await pool.connect();
  
  try {
    console.log('\n' + '='.repeat(60));
    console.log('🔍 Checking Chat Tables Status...');
    console.log('='.repeat(60) + '\n');

    // Check if conversations table exists
    const conversationsCheck = await client.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'conversations'
      );
    `);
    
    const conversationsExists = conversationsCheck.rows[0].exists;
    
    // Check if messages table exists
    const messagesCheck = await client.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'messages'
      );
    `);
    
    const messagesExists = messagesCheck.rows[0].exists;

    console.log(`[INFO] Table Status:`);
    console.log(`   conversations: ${conversationsExists ? '[OK] EXISTS' : '[MISSING] MISSING'}`);
    console.log(`   messages: ${messagesExists ? '[OK] EXISTS' : '[MISSING] MISSING'}\n`);

    if (conversationsExists && messagesExists) {
      console.log('[SUCCESS] All chat tables exist! No action needed.\n');
      console.log('='.repeat(60) + '\n');
      return;
    }

    console.log('🔧 Creating missing chat tables...\n');

    // Create conversations table if it doesn't exist
    if (!conversationsExists) {
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
    }

    // Create messages table if it doesn't exist
    if (!messagesExists) {
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
    }

    // Create indexes for better performance
    console.log('\n🔧 Creating indexes...');
    
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
    
    console.log('[SUCCESS] Indexes created\n');
    console.log('='.repeat(60));
    console.log('[SUCCESS] SUCCESS! Chat tables have been created.');
    console.log('='.repeat(60) + '\n');
    console.log('You can now:');
    console.log('  1. Restart your backend server');
    console.log('  2. Test the chat functionality');
    console.log('  3. Create conversations between riders and drivers\n');

  } catch (error) {
    console.error('\n' + '='.repeat(60));
    console.error('[ERROR] ERROR: Failed to create chat tables');
    console.error('='.repeat(60) + '\n');
    console.error('Error message:', error.message);
    console.error('\nCommon issues:');
    console.error('  1. Database not running: Start PostgreSQL');
    console.error('  2. Database does not exist: Run "CREATE DATABASE ecoride_db;"');
    console.error('  3. Missing .env file: Copy .env.example to .env and configure');
    console.error('  4. Wrong credentials: Check DB_USER and DB_PASSWORD in .env');
    console.error('  5. Base tables missing: Run "npm run init-db" first\n');
    throw error;
  } finally {
    client.release();
  }
};

// Run if executed directly
if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  checkAndFixChatTables()
    .then(() => {
      console.log('Done!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Failed:', error.message);
      process.exit(1);
    });
}

export default checkAndFixChatTables;
