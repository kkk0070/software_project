import pool from './database.js';

const migrate = async () => {
    const client = await pool.connect();
    try {
        console.log('[MIGRATE] Creating carpool tables...');
        await client.query(`
            CREATE TABLE IF NOT EXISTS carpools (
                id SERIAL PRIMARY KEY,
                creator_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                pickup_location VARCHAR(255) NOT NULL,
                dropoff_location VARCHAR(255) NOT NULL,
                fare DECIMAL(10, 2) NOT NULL,
                scheduled_time TIMESTAMP NOT NULL,
                max_participants INTEGER DEFAULT 4,
                vehicle_type VARCHAR(50),
                status VARCHAR(50) DEFAULT 'Open',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);
        console.log('[SUCCESS] Carpools table ready');

        await client.query(`
            CREATE TABLE IF NOT EXISTS carpool_participants (
                id SERIAL PRIMARY KEY,
                carpool_id INTEGER REFERENCES carpools(id) ON DELETE CASCADE,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                otp VARCHAR(10),
                joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(carpool_id, user_id)
            );
        `);
        console.log('[SUCCESS] Carpool participants table ready');
    } catch (e) {
        console.error('[ERROR] Migrate Carpools:', e.message);
        throw e;
    } finally {
        client.release();
    }
};

export default migrate;
