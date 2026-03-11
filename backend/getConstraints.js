import pool from './src/config/database.js';

async function check() {
    try {
        const res = await pool.query(`SELECT pg_get_constraintdef(c.oid) as def FROM pg_constraint c WHERE conname = 'drivers_vehicle_type_check'`);
        console.log("DRIVER CONSTRAINT: ", res.rows[0].def);
        
        const roleRes = await pool.query(`SELECT pg_get_constraintdef(c.oid) as def FROM pg_constraint c WHERE conname = 'users_role_check'`);
        if (roleRes.rows.length) console.log("ROLE: ", roleRes.rows[0].def);
    } catch(e) {}
    process.exit(0);
}
check();
