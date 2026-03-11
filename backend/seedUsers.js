import pool from './src/config/database.js';
import bcrypt from 'bcrypt';

const seed = async () => {
    try {
        const passwordHash = await bcrypt.hash('password123', 10);
        
        const users = [
            { name: 'Alice Smith', email: 'alice@example.com', phone: '1111112222', role: 'Rider' },
            { name: 'Bob Johnson', email: 'bob@example.com', phone: '2222223333', role: 'Driver', vehicle_model: 'Toyota Prius', license_plate: 'ABC-123', vehicle_type: 'Electric Vehicle' },
            { name: 'Charlie Brown', email: 'charlie@example.com', phone: '3333334444', role: 'Rider' },
            { name: 'Diana Prince', email: 'diana@example.com', phone: '4444445555', role: 'Driver', vehicle_model: 'Tesla Model 3', license_plate: 'DEF-456', vehicle_type: 'Electric Vehicle' },
            { name: 'Eve Adams', email: 'eve@example.com', phone: '5555556666', role: 'Rider' }
        ];

        for (const user of users) {
             const check = await pool.query('SELECT id FROM users WHERE email = $1', [user.email]);
             if (check.rows.length === 0) {
                 const res = await pool.query(`INSERT INTO users (name, email, password, phone, role) VALUES ($1, $2, $3, $4, $5) RETURNING id`, [user.name, user.email, passwordHash, user.phone, user.role]);
                 console.log(`Created user ${user.name} with ID ${res.rows[0].id} (Role: ${user.role})`);
                 
                 if (user.role === 'Driver') {
                     const did = await pool.query(`INSERT INTO drivers (user_id, vehicle_model, license_plate, vehicle_type) VALUES ($1, $2, $3, $4) RETURNING id`, [res.rows[0].id, user.vehicle_model, user.license_plate, user.vehicle_type]);
                     console.log(`Created driver details for ${user.name}`);
                 }
             } else {
                 console.log(`User ${user.name} already exists. Attempting driver details if applicable...`);
                 
                 if (user.role === 'Driver') {
                     const didCheck = await pool.query(`SELECT id FROM drivers WHERE user_id = $1`, [check.rows[0].id]);
                     if(didCheck.rows.length === 0) {
                         const did = await pool.query(`INSERT INTO drivers (user_id, vehicle_model, license_plate, vehicle_type) VALUES ($1, $2, $3, $4) RETURNING id`, [check.rows[0].id, user.vehicle_model, user.license_plate, user.vehicle_type]);
                         console.log(`Created driver details for ${user.name}`);
                     }
                 }
             }
        }
        
        // Let's create a carpool if possible
        const bob = await pool.query("SELECT id FROM users WHERE email = 'bob@example.com'");
        const alice = await pool.query("SELECT id FROM users WHERE email = 'alice@example.com'");
        
        if (bob.rows.length > 0 && alice.rows.length > 0) {
            const bobId = bob.rows[0].id;
            const aliceId = alice.rows[0].id;
            
            // create carpool
            const carpoolCheck = await pool.query("SELECT id FROM carpools WHERE creator_id = $1", [bobId]);
            if (carpoolCheck.rows.length === 0) {
                const cp = await pool.query(`INSERT INTO carpools (creator_id, pickup_location, dropoff_location, fare, max_participants, vehicle_type, status, scheduled_time) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW() + INTERVAL '1 day') RETURNING id`, [bobId, "Koramangala", "Indiranagar", 150, 4, "Electric Vehicle", "Open"]);
                console.log(`Created carpool ${cp.rows[0].id} by Bob`);
                
                // participant
                await pool.query(`INSERT INTO carpool_participants (carpool_id, user_id, otp) VALUES ($1, $2, $3)`, [cp.rows[0].id, aliceId, '1234']);
                console.log("Alice joined the carpool");
                
                // create ride
                await pool.query(`INSERT INTO rides (rider_id, driver_id, pickup_location, dropoff_location, fare, status, distance, scheduled_time) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())`, [aliceId, bobId, 'MG Road', 'Whitefield', 450, 'Completed', 15.0]);
                console.log("Created completed ride between Alice and Bob");
            } else {
                console.log("Bob's carpool already exists.");
            }
        }
        
    } catch (e) {
        console.error(e);
    } finally {
        process.exit();
    }
}
seed();
