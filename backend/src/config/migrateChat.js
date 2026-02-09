import pool from './database.js';

const migrateChatTables = async () => {
  const client = await pool.connect();
  
  try {
    console.log('[INFO] Creating chat tables...');

    // Conversations table - stores chat conversations between users
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

    // Messages table - stores individual messages
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

    // Create indexes for better performance
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
    
    console.log('[SUCCESS] Indexes created');
    console.log('[SUCCESS] Chat migration completed successfully!');
  } catch (error) {
    console.error('[ERROR] Error creating chat tables:', error);
    throw error;
  } finally {
    client.release();
  }
};

// Run migration if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  migrateChatTables()
    .then(() => {
      console.log('[SUCCESS] Chat migration completed');
      process.exit(0);
    })
    .catch((error) => {
      console.error('[ERROR] Chat migration failed:', error);
      process.exit(1);
    });
}

export default migrateChatTables;
