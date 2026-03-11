import pg from 'pg';
const { Pool } = pg;

const pool = new Pool({
    connectionString: 'postgresql://neondb_owner:npg_ViesH8rm2ZWh@ep-steep-cloud-adibxku8-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require',
    ssl: { rejectUnauthorized: false }
});

const client = await pool.connect();
console.log('Connected to Neon database');

const tables = [
    `CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(50) DEFAULT 'Rider',
    profile_photo VARCHAR(500),
    is_verified BOOLEAN DEFAULT false,
    is_deactivated BOOLEAN DEFAULT false,
    otp VARCHAR(10),
    otp_expires TIMESTAMP,
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_secret VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )`,
    `CREATE TABLE IF NOT EXISTS drivers (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    license_number VARCHAR(100),
    vehicle_type VARCHAR(50),
    vehicle_model VARCHAR(100),
    vehicle_plate VARCHAR(50),
    vehicle_color VARCHAR(50),
    is_available BOOLEAN DEFAULT false,
    current_lat DECIMAL(10,8),
    current_lng DECIMAL(11,8),
    rating DECIMAL(3,2) DEFAULT 0,
    total_rides INTEGER DEFAULT 0,
    verification_status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )`,
    `CREATE TABLE IF NOT EXISTS rides (
    id SERIAL PRIMARY KEY,
    rider_id INTEGER REFERENCES users(id),
    driver_id INTEGER REFERENCES users(id),
    pickup_address TEXT,
    dropoff_address TEXT,
    pickup_lat DECIMAL(10,8),
    pickup_lng DECIMAL(11,8),
    dropoff_lat DECIMAL(10,8),
    dropoff_lng DECIMAL(11,8),
    status VARCHAR(50) DEFAULT 'Pending',
    fare DECIMAL(10,2),
    distance DECIMAL(10,2),
    duration INTEGER,
    payment_method VARCHAR(50) DEFAULT 'Cash',
    payment_status VARCHAR(50) DEFAULT 'Pending',
    rider_rating INTEGER,
    driver_rating INTEGER,
    rider_review TEXT,
    driver_review TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )`,
    `CREATE TABLE IF NOT EXISTS documents (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    document_type VARCHAR(100) NOT NULL,
    file_name VARCHAR(255),
    file_path TEXT,
    file_size INTEGER,
    description TEXT,
    status VARCHAR(50) DEFAULT 'Pending',
    verified_at TIMESTAMP,
    verified_by INTEGER,
    is_encrypted BOOLEAN DEFAULT false,
    encryption_key_id VARCHAR(255),
    encrypted_key TEXT,
    encryption_iv VARCHAR(255),
    encryption_auth_tag VARCHAR(255),
    encryption_algorithm VARCHAR(100),
    file_hash TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )`,
    `CREATE TABLE IF NOT EXISTS encryption_keys (
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
  )`,
    `CREATE TABLE IF NOT EXISTS conversations (
    id SERIAL PRIMARY KEY,
    ride_id INTEGER REFERENCES rides(id),
    rider_id INTEGER REFERENCES users(id),
    driver_id INTEGER REFERENCES users(id),
    last_message TEXT,
    last_message_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )`,
    `CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER REFERENCES conversations(id),
    sender_id INTEGER REFERENCES users(id),
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )`,
    `CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    body TEXT,
    type VARCHAR(50),
    data JSONB,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )`,
    `CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    ride_id INTEGER REFERENCES rides(id),
    user_id INTEGER REFERENCES users(id),
    amount DECIMAL(10,2),
    method VARCHAR(50),
    status VARCHAR(50) DEFAULT 'Pending',
    transaction_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )`,
];

let created = 0;
for (const sql of tables) {
    try {
        await client.query(sql);
        const match = sql.match(/CREATE TABLE IF NOT EXISTS (\w+)/);
        console.log(`✅ Table ready: ${match ? match[1] : 'unknown'}`);
        created++;
    } catch (err) {
        console.error(`❌ Error: ${err.message}`);
    }
}

client.release();
await pool.end();
console.log(`\nDone! ${created}/${tables.length} tables created/verified.`);
