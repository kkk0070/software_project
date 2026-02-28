import pool from './database.js';
import bcrypt from 'bcrypt';

const createTables = async () => {
  const client = await pool.connect();
  
  try {
    console.log('[INFO] Creating database tables...');

    // Users table
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        phone VARCHAR(50),
        location VARCHAR(255),
        profile_photo TEXT,
        role VARCHAR(50) DEFAULT 'Rider' CHECK (role IN ('Rider', 'Driver', 'Admin')),
        status VARCHAR(50) DEFAULT 'Active' CHECK (status IN ('Active', 'Suspended', 'Pending')),
        verified BOOLEAN DEFAULT false,
        profile_setup_complete BOOLEAN DEFAULT false,
        rating DECIMAL(3,2) DEFAULT 0.0,
        total_rides INTEGER DEFAULT 0,
        two_factor_enabled BOOLEAN DEFAULT false,
        two_factor_secret VARCHAR(255),
        joined_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Users table created');

    // Drivers table (additional driver-specific info)
    await client.query(`
      CREATE TABLE IF NOT EXISTS drivers (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        vehicle_type VARCHAR(50) CHECK (vehicle_type IN ('Electric Vehicle', 'Hybrid', 'Gas')),
        vehicle_model VARCHAR(255),
        license_plate VARCHAR(50),
        license_number VARCHAR(100),
        vehicle_year INTEGER,
        available BOOLEAN DEFAULT true,
        earnings DECIMAL(10,2) DEFAULT 0.00,
        verification_status VARCHAR(50) DEFAULT 'Pending' CHECK (verification_status IN ('Pending', 'Verified', 'Rejected')),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id)
      );
    `);
    console.log('[SUCCESS] Drivers table created');

    // Rides table
    await client.query(`
      CREATE TABLE IF NOT EXISTS rides (
        id SERIAL PRIMARY KEY,
        rider_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
        driver_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
        pickup_location VARCHAR(255) NOT NULL,
        dropoff_location VARCHAR(255) NOT NULL,
        pickup_lat DECIMAL(10, 8),
        pickup_lng DECIMAL(11, 8),
        dropoff_lat DECIMAL(10, 8),
        dropoff_lng DECIMAL(11, 8),
        ride_type VARCHAR(50) DEFAULT 'Economy' CHECK (ride_type IN ('Solo', 'Pool', 'EV', 'Economy', 'Comfort', 'Premium', 'Standard')),
        status VARCHAR(50) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Active', 'Completed', 'Cancelled')),
        fare DECIMAL(10,2),
        distance DECIMAL(10,2),
        duration INTEGER,
        carbon_saved DECIMAL(10,3),
        rating DECIMAL(3,2),
        scheduled_time TIMESTAMP,
        started_at TIMESTAMP,
        completed_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Rides table created');

    // Add lat/lng columns to rides if they were created before these columns existed
    await client.query(`
      ALTER TABLE rides
        ADD COLUMN IF NOT EXISTS pickup_lat DECIMAL(10, 8),
        ADD COLUMN IF NOT EXISTS pickup_lng DECIMAL(11, 8),
        ADD COLUMN IF NOT EXISTS dropoff_lat DECIMAL(10, 8),
        ADD COLUMN IF NOT EXISTS dropoff_lng DECIMAL(11, 8);
    `);
    console.log('[SUCCESS] Rides table lat/lng columns ensured');

    // Expand ride_type CHECK constraint to include app-facing values
    // (Economy, Comfort, Premium) in case the table was created with the old
    // narrower constraint that only allowed Solo, Pool, EV.
    await client.query(`
      ALTER TABLE rides DROP CONSTRAINT IF EXISTS rides_ride_type_check;
      ALTER TABLE rides
        ADD CONSTRAINT rides_ride_type_check
        CHECK (ride_type IN ('Solo', 'Pool', 'EV', 'Economy', 'Comfort', 'Premium', 'Standard'));
    `);
    console.log('[SUCCESS] Rides ride_type constraint updated');

    // Emergency incidents table
    await client.query(`
      CREATE TABLE IF NOT EXISTS emergency_incidents (
        id SERIAL PRIMARY KEY,
        ride_id INTEGER REFERENCES rides(id) ON DELETE CASCADE,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        incident_type VARCHAR(100) NOT NULL,
        description TEXT,
        location VARCHAR(255),
        latitude DECIMAL(10, 8),
        longitude DECIMAL(11, 8),
        status VARCHAR(50) DEFAULT 'Open' CHECK (status IN ('Open', 'In Progress', 'Resolved')),
        priority VARCHAR(50) DEFAULT 'Medium' CHECK (priority IN ('Low', 'Medium', 'High', 'Critical')),
        resolved_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Emergency incidents table created');

    // Carbon savings table
    await client.query(`
      CREATE TABLE IF NOT EXISTS carbon_savings (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        ride_id INTEGER REFERENCES rides(id) ON DELETE CASCADE,
        co2_saved DECIMAL(10,3),
        trees_equivalent DECIMAL(10,2),
        recorded_date DATE DEFAULT CURRENT_DATE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Carbon savings table created');

    // Notifications table
    await client.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        type VARCHAR(50) DEFAULT 'Info' CHECK (type IN ('Info', 'Warning', 'Success', 'Error')),
        category VARCHAR(50),
        read BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Notifications table created');

    // System logs table
    await client.query(`
      CREATE TABLE IF NOT EXISTS system_logs (
        id SERIAL PRIMARY KEY,
        log_type VARCHAR(50) NOT NULL CHECK (log_type IN ('Error', 'Warning', 'Info', 'Security')),
        message TEXT NOT NULL,
        details JSONB,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] System logs table created');

    // Settings table
    await client.query(`
      CREATE TABLE IF NOT EXISTS settings (
        id SERIAL PRIMARY KEY,
        key VARCHAR(100) UNIQUE NOT NULL,
        value TEXT NOT NULL,
        category VARCHAR(50),
        description TEXT,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Settings table created');

    // Documents table
    await client.query(`
      CREATE TABLE IF NOT EXISTS documents (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        document_type VARCHAR(100) DEFAULT 'Other',
        file_name VARCHAR(255) NOT NULL,
        file_path TEXT NOT NULL,
        file_size INTEGER,
        description TEXT,
        status VARCHAR(50) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected')),
        verified_at TIMESTAMP,
        verified_by INTEGER REFERENCES users(id),
        uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('[SUCCESS] Documents table created');

    console.log('[COMPLETE] All tables created successfully!');
  } catch (error) {
    console.error('[ERROR] Error creating tables:', error);
    throw error;
  } finally {
    client.release();
  }
};

const seedInitialData = async () => {
  const client = await pool.connect();
  
  try {
    console.log('🌱 Seeding initial data...');

    // Check if admin user already exists
    const adminCheck = await client.query(`SELECT id FROM users WHERE email = 'admin@ecoride.com'`);
    
    if (adminCheck.rows.length === 0) {
      console.log('[ENCRYPTING] Creating default login credentials...\n');
      
      // Generate password hashes
      const adminPasswordHash = await bcrypt.hash('admin123', 10);
      const defaultPasswordHash = await bcrypt.hash('password123', 10);
      
      // Insert admin user (password: admin123)
      await client.query(`
        INSERT INTO users (name, email, password, role, status, verified, location)
        VALUES ('Admin User', 'admin@ecoride.com', $1, 'Admin', 'Active', true, 'Headquarters')
      `, [adminPasswordHash]);
      console.log('[SUCCESS] Admin user created');
      console.log('   📧 Email: admin@ecoride.com');
      console.log('   [KEY] Password: admin123\n');

      // Insert sample riders
      await client.query(`
        INSERT INTO users (name, email, password, phone, location, role, status, verified, rating, total_rides)
        VALUES 
          ('John Doe', 'john@example.com', $1, '+1234567890', 'New York, NY', 'Rider', 'Active', true, 4.8, 45),
          ('Mike Johnson', 'mike@example.com', $1, '+1234567892', 'Chicago, IL', 'Rider', 'Suspended', false, 3.5, 12),
          ('Tom Brown', 'tom@example.com', $1, '+1234567894', 'Phoenix, AZ', 'Rider', 'Active', true, 4.7, 78)
      `, [defaultPasswordHash]);
      console.log('[SUCCESS] Sample riders created (password: password123)');

      // Insert sample drivers
      const driverUsers = await client.query(`
        INSERT INTO users (name, email, password, phone, location, role, status, verified, profile_setup_complete, rating, total_rides)
        VALUES 
          ('Jane Smith', 'jane@example.com', $1, '+1234567891', 'Los Angeles, CA', 'Driver', 'Active', true, true, 4.9, 234),
          ('Sarah Williams', 'sarah@example.com', $1, '+1234567893', 'Houston, TX', 'Driver', 'Pending', false, false, 0, 0),
          ('Emily Davis', 'emily@example.com', $1, '+1234567895', 'Philadelphia, PA', 'Driver', 'Active', true, true, 4.6, 156),
          ('Robert Wilson', 'robert@example.com', $1, '+1234567896', 'San Antonio, TX', 'Driver', 'Active', true, false, 4.4, 89)
        RETURNING id, email
      `, [defaultPasswordHash]);
      console.log('[SUCCESS] Sample drivers created (password: password123)');

      // Insert driver-specific information
      const drivers = driverUsers.rows;
      const driverData = [
        { email: 'jane@example.com', vehicle_type: 'Electric Vehicle', vehicle_model: 'Tesla Model 3', license_plate: 'ABC-1234', verification_status: 'Verified' },
        { email: 'sarah@example.com', vehicle_type: 'Hybrid', vehicle_model: 'Toyota Prius', license_plate: 'XYZ-5678', verification_status: 'Pending' },
        { email: 'emily@example.com', vehicle_type: 'Gas', vehicle_model: 'Honda Civic', license_plate: 'DEF-9012', verification_status: 'Verified' },
        { email: 'robert@example.com', vehicle_type: 'Electric Vehicle', vehicle_model: 'Nissan Leaf', license_plate: 'GHI-3456', verification_status: 'Pending' }
      ];

      for (const driver of drivers) {
        const driverInfo = driverData.find(d => d.email === driver.email);
        if (driverInfo) {
          await client.query(`
            INSERT INTO drivers (user_id, vehicle_type, vehicle_model, license_plate, vehicle_year, available, verification_status)
            VALUES ($1, $2, $3, $4, 2022, true, $5)
          `, [driver.id, driverInfo.vehicle_type, driverInfo.vehicle_model, driverInfo.license_plate, driverInfo.verification_status]);
        }
      }
      console.log('[SUCCESS] Driver details added');

      // Insert sample settings
      await client.query(`
        INSERT INTO settings (key, value, category, description)
        VALUES 
          ('base_fare', '5.00', 'pricing', 'Base fare for rides'),
          ('per_km_rate', '1.50', 'pricing', 'Rate per kilometer'),
          ('pool_discount', '0.30', 'pricing', 'Discount percentage for pooled rides'),
          ('ev_priority', 'true', 'features', 'Enable EV priority'),
          ('ride_pooling_enabled', 'true', 'features', 'Enable ride pooling'),
          ('platform_language', 'English', 'localization', 'Default platform language')
        ON CONFLICT (key) DO NOTHING
      `);
      console.log('[SUCCESS] Default settings created');
      
      // Display login credentials summary
      console.log('\n' + '='.repeat(60));
      console.log('[INFO] DEFAULT LOGIN CREDENTIALS');
      console.log('='.repeat(60));
      console.log('\n[ENCRYPTING] Admin Account:');
      console.log('   Email: admin@ecoride.com');
      console.log('   Password: admin123');
      console.log('\n👥 Sample Users (All riders and drivers):');
      console.log('   Password: password123');
      console.log('\n📄 Full details: See DEFAULT_LOGIN_CREDENTIALS.md');
      console.log('='.repeat(60) + '\n');
    } else {
      console.log('[INFO]  Initial data already exists, skipping seed');
    }

    console.log('[COMPLETE] Database initialization completed!');
  } catch (error) {
    console.error('[ERROR] Error seeding data:', error);
    throw error;
  } finally {
    client.release();
  }
};

const initDatabase = async () => {
  try {
    await createTables();
    await seedInitialData();
    process.exit(0);
  } catch (error) {
    console.error('[ERROR] Database initialization failed:', error);
    process.exit(1);
  }
};

initDatabase();
