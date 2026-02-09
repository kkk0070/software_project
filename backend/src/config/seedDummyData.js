import pool from './database.js';
import bcrypt from 'bcrypt';

const seedDummyData = async () => {
  const client = await pool.connect();
  
  try {
    console.log('🌱 Starting dummy data seeding...\n');

    // Get existing users for reference
    const usersResult = await client.query('SELECT id, role FROM users ORDER BY id');
    const users = usersResult.rows;
    
    if (users.length === 0) {
      console.log('[WARNING]  No users found. Please run init-db first.');
      return;
    }

    const riders = users.filter(u => u.role === 'Rider');
    const drivers = users.filter(u => u.role === 'Driver');

    // Seed Rides
    console.log('🚗 Seeding rides...');
    const rideCount = await client.query('SELECT COUNT(*) FROM rides');
    if (parseInt(rideCount.rows[0].count) === 0) {
      const locations = [
        { name: 'Downtown', lat: 40.7128, lng: -74.0060 },
        { name: 'Uptown', lat: 40.7589, lng: -73.9851 },
        { name: 'Brooklyn', lat: 40.6782, lng: -73.9442 },
        { name: 'Queens', lat: 40.7282, lng: -73.7949 },
        { name: 'Bronx', lat: 40.8448, lng: -73.8648 }
      ];

      const rideTypes = ['Solo', 'Pool', 'EV'];
      const statuses = ['Completed', 'Active', 'Pending', 'Cancelled'];

      // Increase number of rides to 100 for better data
      for (let i = 0; i < 100; i++) {
        const pickup = locations[Math.floor(Math.random() * locations.length)];
        const dropoff = locations[Math.floor(Math.random() * locations.length)];
        const rider = riders[Math.floor(Math.random() * riders.length)];
        const driver = drivers[Math.floor(Math.random() * drivers.length)];
        const rideType = rideTypes[Math.floor(Math.random() * rideTypes.length)];
        const status = statuses[Math.floor(Math.random() * statuses.length)];
        const distance = (Math.random() * 20 + 1).toFixed(2);
        const fare = (distance * 1.5 + 5).toFixed(2);
        const carbonSaved = (distance * 0.21).toFixed(3);
        const duration = Math.floor(distance * 3 + 10);
        const daysAgo = Math.floor(Math.random() * 30);

        const createdAt = new Date();
        createdAt.setDate(createdAt.getDate() - daysAgo);
        const startedAt = new Date(createdAt);
        startedAt.setMinutes(startedAt.getMinutes() + 5);
        const completedAt = new Date(startedAt);
        completedAt.setMinutes(completedAt.getMinutes() + duration);

        await client.query(`
          INSERT INTO rides (
            rider_id, driver_id, pickup_location, dropoff_location,
            pickup_lat, pickup_lng, dropoff_lat, dropoff_lng,
            ride_type, status, fare, distance, duration, carbon_saved,
            rating, created_at, started_at, completed_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
        `, [
          rider.id, driver.id, pickup.name, dropoff.name,
          pickup.lat, pickup.lng, dropoff.lat, dropoff.lng,
          rideType, status, fare, distance, duration, carbonSaved,
          (Math.random() * 2 + 3).toFixed(1),
          createdAt, startedAt, completedAt
        ]);
      }
      console.log('[SUCCESS] Seeded 100 rides');
    }

    // Seed Emergency Incidents
    console.log('🚨 Seeding emergency incidents...');
    const incidentCount = await client.query('SELECT COUNT(*) FROM emergency_incidents');
    if (parseInt(incidentCount.rows[0].count) === 0) {
      const incidentTypes = ['SOS Alert', 'Accident', 'Medical Emergency', 'Vehicle Breakdown', 'Safety Concern'];
      const priorities = ['Low', 'Medium', 'High', 'Critical'];
      const statuses = ['Open', 'In Progress', 'Resolved'];
      
      const rides = await client.query('SELECT id, rider_id FROM rides LIMIT 25');
      
      for (let i = 0; i < 25; i++) {
        const ride = rides.rows[i];
        const incidentType = incidentTypes[Math.floor(Math.random() * incidentTypes.length)];
        const priority = priorities[Math.floor(Math.random() * priorities.length)];
        const status = statuses[Math.floor(Math.random() * statuses.length)];
        const daysAgo = Math.floor(Math.random() * 15);

        const createdAt = new Date();
        createdAt.setDate(createdAt.getDate() - daysAgo);
        const resolvedAt = status === 'Resolved' ? new Date(createdAt.getTime() + 86400000) : null; // +1 day if resolved

        await client.query(`
          INSERT INTO emergency_incidents (
            ride_id, user_id, incident_type, description, location,
            latitude, longitude, status, priority, created_at, resolved_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        `, [
          ride.id, ride.rider_id, incidentType,
          `${incidentType} during ride #${ride.id}`,
          'Downtown Area',
          40.7128 + (Math.random() - 0.5) * 0.1,
          -74.0060 + (Math.random() - 0.5) * 0.1,
          status, priority, createdAt, resolvedAt
        ]);
      }
      console.log('[SUCCESS] Seeded 25 emergency incidents');
    }

    // Seed Notifications
    console.log('📬 Seeding notifications...');
    const notificationCount = await client.query('SELECT COUNT(*) FROM notifications');
    if (parseInt(notificationCount.rows[0].count) === 0) {
      const notificationTypes = ['Info', 'Warning', 'Success', 'Error'];
      const categories = ['Ride', 'System', 'Promotion', 'Safety', 'Update'];
      const titles = [
        'New Promotion Available',
        'Ride Completed',
        'System Maintenance',
        'Safety Alert',
        'New Feature Released',
        'Payment Successful',
        'Driver Assigned',
        'Ride Cancelled'
      ];

      for (const user of users.slice(0, 20)) {
        for (let i = 0; i < 5; i++) {
          const title = titles[Math.floor(Math.random() * titles.length)];
          const type = notificationTypes[Math.floor(Math.random() * notificationTypes.length)];
          const category = categories[Math.floor(Math.random() * categories.length)];
          const hoursAgo = Math.floor(Math.random() * 72);
          const createdAt = new Date();
          createdAt.setHours(createdAt.getHours() - hoursAgo);

          await client.query(`
            INSERT INTO notifications (
              user_id, title, message, type, category, read, created_at
            ) VALUES ($1, $2, $3, $4, $5, $6, $7)
          `, [
            user.id, title,
            `Details about ${title.toLowerCase()} for user ${user.id}`,
            type, category, Math.random() > 0.3, createdAt
          ]);
        }
      }
      console.log('[SUCCESS] Seeded 100 notifications');
    }

    // Seed System Logs
    console.log('📊 Seeding system logs...');
    const logCount = await client.query('SELECT COUNT(*) FROM system_logs');
    if (parseInt(logCount.rows[0].count) === 0) {
      const logTypes = ['Error', 'Warning', 'Info', 'Security'];
      const messages = [
        'Database connection established',
        'API rate limit exceeded',
        'Unauthorized access attempt',
        'Payment processing failed',
        'User authentication successful',
        'Server memory usage high',
        'Backup completed successfully',
        'Failed login attempt detected'
      ];

      for (let i = 0; i < 100; i++) {
        const logType = logTypes[Math.floor(Math.random() * logTypes.length)];
        const message = messages[Math.floor(Math.random() * messages.length)];
        const hoursAgo = Math.floor(Math.random() * 168); // Last week
        const createdAt = new Date();
        createdAt.setHours(createdAt.getHours() - hoursAgo);

        await client.query(`
          INSERT INTO system_logs (log_type, message, details, created_at)
          VALUES ($1, $2, $3, $4)
        `, [
          logType, message,
          JSON.stringify({ 
            source: 'system',
            code: Math.floor(Math.random() * 500 + 100),
            severity: logType
          }),
          createdAt
        ]);
      }
      console.log('[SUCCESS] Seeded 100 system logs');
    }

    // Seed Carbon Savings
    console.log('🌱 Seeding carbon savings...');
    const carbonCount = await client.query('SELECT COUNT(*) FROM carbon_savings');
    if (parseInt(carbonCount.rows[0].count) === 0) {
      const completedRides = await client.query(`
        SELECT id, rider_id, carbon_saved, created_at 
        FROM rides 
        WHERE status = 'Completed' AND carbon_saved IS NOT NULL
      `);

      for (const ride of completedRides.rows) {
        const treesEquivalent = (parseFloat(ride.carbon_saved) / 21).toFixed(2);
        
        await client.query(`
          INSERT INTO carbon_savings (
            user_id, ride_id, co2_saved, trees_equivalent, recorded_date
          ) VALUES ($1, $2, $3, $4, $5)
        `, [
          ride.rider_id, ride.id, ride.carbon_saved, treesEquivalent,
          ride.created_at
        ]);
      }
      console.log(`[SUCCESS] Seeded carbon savings for ${completedRides.rows.length} rides`);
    }

    // Seed Settings
    console.log('[INFO]  Seeding additional settings...');
    const settingsToAdd = [
      { key: 'surge_pricing_enabled', value: 'true', category: 'pricing', description: 'Enable surge pricing during peak hours' },
      { key: 'max_pool_riders', value: '4', category: 'features', description: 'Maximum riders in a pool ride' },
      { key: 'driver_radius_km', value: '10', category: 'features', description: 'Driver search radius in kilometers' },
      { key: 'emergency_response_time', value: '5', category: 'safety', description: 'Target response time in minutes' },
      { key: 'carbon_tracking_enabled', value: 'true', category: 'sustainability', description: 'Track carbon savings' },
      { key: 'notification_email_enabled', value: 'true', category: 'notifications', description: 'Send email notifications' },
      { key: 'notification_push_enabled', value: 'true', category: 'notifications', description: 'Send push notifications' },
      { key: 'maintenance_mode', value: 'false', category: 'system', description: 'Enable maintenance mode' }
    ];

    for (const setting of settingsToAdd) {
      await client.query(`
        INSERT INTO settings (key, value, category, description)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (key) DO NOTHING
      `, [setting.key, setting.value, setting.category, setting.description]);
    }
    console.log('[SUCCESS] Seeded additional settings');

    console.log('\n[COMPLETE] Dummy data seeding completed successfully!');
    console.log('\n📊 Summary:');
    console.log('  - Rides: 100');
    console.log('  - Emergency Incidents: 25');
    console.log('  - Notifications: 100');
    console.log('  - System Logs: 100');
    console.log('  - Carbon Savings: Linked to completed rides');
    console.log('  - Settings: 8 additional configuration items');

  } catch (error) {
    console.error('[ERROR] Error seeding dummy data:', error);
    throw error;
  } finally {
    client.release();
  }
};

const runSeed = async () => {
  try {
    await seedDummyData();
    process.exit(0);
  } catch (error) {
    console.error('[ERROR] Seeding failed:', error);
    process.exit(1);
  }
};

runSeed();
