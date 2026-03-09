import pool from './src/config/database.js';
import bcrypt from 'bcrypt';

const resetAdminPassword = async () => {
    try {
        console.log('🔄 Resetting Admin Password...');

        const email = 'admin@ecoride.com';
        const password = 'admin123';
        const hashedPassword = await bcrypt.hash(password, 10);

        const client = await pool.connect();

        // Check if user exists
        const check = await client.query('SELECT id FROM users WHERE email = $1', [email]);

        if (check.rows.length === 0) {
            console.log('❌ Admin user not found! Creating one...');
            await client.query(`
        INSERT INTO users (name, email, password, role, status, verified, location)
        VALUES ('Admin User', $1, $2, 'Admin', 'Active', true, 'Headquarters')
      `, [email, hashedPassword]);
        } else {
            console.log('✅ Admin user found. Updating password...');
            await client.query('UPDATE users SET password = $1 WHERE email = $2', [hashedPassword, email]);
        }

        console.log('\n✅ Password Reset Successful!');
        console.log('📧 Email: admin@ecoride.com');
        console.log('🔑 Password: admin123');

        client.release();
        process.exit(0);
    } catch (error) {
        console.error('❌ Error resetting password:', error);
        process.exit(1);
    }
};

resetAdminPassword();
