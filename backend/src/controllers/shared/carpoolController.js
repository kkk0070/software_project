import pool from '../../config/database.js';

/**
 * Get all available carpools
 */
export const getAvailableCarpools = async (req, res) => {
    try {
        const result = await pool.query(`
      SELECT c.*, u.name as creator_name,
      (SELECT count(*) FROM carpool_participants WHERE carpool_id = c.id) as current_participants
      FROM carpools c
      JOIN users u ON c.creator_id = u.id
      WHERE c.status = 'Open'
      ORDER BY c.scheduled_time ASC
    `);

        // Map to the format frontend expects
        const formattedData = result.rows.map(row => {
            const currentCount = parseInt(row.current_participants || 0);
            const isFull = currentCount >= row.max_participants;

            return {
                id: row.id,
                creator: row.creator_name,
                creator_id: row.creator_id,
                driver: row.creator_name,
                driverId: row.creator_id,
                from: row.pickup_location,
                to: row.dropoff_location,
                pickup: row.pickup_location,
                dropoff: row.dropoff_location,
                fare: parseFloat(row.fare),
                price: `₹${parseFloat(row.fare).toFixed(0)}`,
                time: new Date(row.scheduled_time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
                date: new Date(row.scheduled_time).toLocaleDateString([], { month: 'short', day: '2-digit' }) + ', ' + new Date(row.scheduled_time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
                participants_count: currentCount,
                max_participants: row.max_participants,
                seats: row.max_participants - currentCount,
                status: isFull ? 'Full' : row.status,
                vehicleType: row.vehicle_type || 'EV',
                rating: 4.8,
                carbonSaved: '2.4 kg CO₂'
            };
        });

        res.json({ success: true, data: formattedData });
    } catch (error) {
        console.error('[ERROR] getAvailableCarpools:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

/**
 * Get detailed carpool info including participants
 */
export const getCarpoolDetails = async (req, res) => {
    const { id } = req.params;

    try {
        const carpoolResult = await pool.query(`
      SELECT c.*, u.name as creator_name, u.profile_photo as creator_photo
      FROM carpools c
      JOIN users u ON c.creator_id = u.id
      WHERE c.id = $1
    `, [id]);

        if (carpoolResult.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'Carpool not found' });
        }

        const carpool = carpoolResult.rows[0];

        // Fetch participants
        const participantsResult = await pool.query(`
      SELECT u.id, u.name, u.profile_photo, cp.otp, cp.joined_at
      FROM carpool_participants cp
      JOIN users u ON cp.user_id = u.id
      WHERE cp.carpool_id = $1
    `, [id]);

        const participants = participantsResult.rows.map(p => ({
            id: p.id,
            name: p.name,
            photo: p.profile_photo,
            otp: p.otp,
            role: 'Participant'
        }));

        const currentCount = participants.length;
        const isFull = currentCount >= carpool.max_participants;

        const formattedData = {
            id: carpool.id,
            creator: carpool.creator_name,
            creator_id: carpool.creator_id,
            creator_photo: carpool.creator_photo,
            from: carpool.pickup_location,
            to: carpool.dropoff_location,
            fare: parseFloat(carpool.fare),
            time: new Date(carpool.scheduled_time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
            max_participants: carpool.max_participants,
            participants_count: currentCount,
            seats: carpool.max_participants - currentCount,
            status: isFull ? 'Full' : carpool.status,
            vehicleType: carpool.vehicle_type || 'EV',
            participants: participants
        };

        res.json({ success: true, data: formattedData });
    } catch (error) {
        console.error('[ERROR] getCarpoolDetails:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

/**
 * Create a new carpool
 */
export const createCarpool = async (req, res) => {
    // Robust destructuring with fallbacks
    const body = req.body || {};
    const pickup = body.pickup || body.from || 'Unknown';
    const dropoff = body.dropoff || body.to || 'Unknown';
    const fare = parseFloat(body.fare || 0);
    const max_participants = parseInt(body.max_participants || 4);
    const vehicleType = body.vehicleType || 'EV';
    const creator_id = parseInt(body.creator_id);

    try {
        if (!creator_id) {
            return res.status(400).json({ success: false, message: 'Invalid or missing creator_id' });
        }

        const scheduledTime = new Date(); // Use current time as fallback

        console.log('[INFO] Attempting to insert carpool:', {
            creator_id, pickup, dropoff, fare, scheduledTime, max_participants, vehicleType
        });

        const result = await pool.query(`
            INSERT INTO carpools (creator_id, pickup_location, dropoff_location, fare, scheduled_time, max_participants, vehicle_type)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING *
        `, [creator_id, pickup, dropoff, fare, scheduledTime, max_participants, vehicleType]);

        res.status(201).json({ success: true, data: result.rows[0] });
    } catch (error) {
        console.error('[ERROR] createCarpool FULL DETAILS:', {
            errorMessage: error.message,
            errorCode: error.code,
            errorDetail: error.detail,
            body: req.body
        });
        res.status(500).json({
            success: false,
            message: 'Database error: ' + error.message,
            detail: error.detail
        });
    }
};

/**
 * Accept/Join a carpool
 */
export const acceptCarpool = async (req, res) => {
    const { carpoolId, userId } = req.body;
    const cid = parseInt(carpoolId);
    const uid = parseInt(userId);

    try {
        if (!cid || !uid) {
            return res.status(400).json({ success: false, message: 'Invalid carpoolId or userId' });
        }

        // Check if already full
        const carpool = await pool.query('SELECT * FROM carpools WHERE id = $1', [cid]);
        if (carpool.rows.length === 0) return res.status(404).json({ success: false, message: 'Carpool not found' });

        const participants = await pool.query('SELECT count(*) FROM carpool_participants WHERE carpool_id = $1', [cid]);
        if (parseInt(participants.rows[0].count) >= carpool.rows[0].max_participants) {
            return res.status(400).json({ success: false, message: 'Carpool is full' });
        }

        const otp = Math.floor(1000 + Math.random() * 9000).toString();

        await pool.query(`
            INSERT INTO carpool_participants (carpool_id, user_id, otp)
            VALUES ($1, $2, $3)
        `, [cid, uid, otp]);

        res.json({ success: true, message: 'Joined carpool', otp });
    } catch (error) {
        console.error('[ERROR] acceptCarpool FULL DETAILS:', {
            errorMessage: error.message,
            errorCode: error.code,
            body: req.body
        });
        res.status(500).json({
            success: false,
            message: 'Database error: ' + error.message,
            detail: error.detail
        });
    }
};

/**
 * Get history for a user
 */
export const getCarpoolHistory = async (req, res) => {
    const uid = parseInt(req.query.userId);

    try {
        if (!uid) {
            return res.status(400).json({ success: false, message: 'Invalid or missing userId' });
        }

        const created = await pool.query(`
            SELECT c.*, u.name as creator_name, 'Owner' as role
            FROM carpools c
            JOIN users u ON c.creator_id = u.id
            WHERE c.creator_id = $1
        `, [uid]);

        const joined = await pool.query(`
            SELECT c.*, u.name as creator_name, cp.otp, 'Accepted' as role
            FROM carpool_participants cp
            JOIN carpools c ON cp.carpool_id = c.id
            JOIN users u ON c.creator_id = u.id
            WHERE cp.user_id = $1
        `, [uid]);

        const combined = [...created.rows, ...joined.rows].map(row => ({
            id: row.id,
            creator: row.creator_name,
            from: row.pickup_location,
            to: row.dropoff_location,
            fare: parseFloat(row.fare || 0),
            status: row.status,
            is_creator: row.role === 'Owner',
            user_otp: row.otp || 'N/A'
        }));

        res.json({ success: true, data: combined });
    } catch (error) {
        console.error('[ERROR] getCarpoolHistory FULL DETAILS:', {
            errorMessage: error.message,
            errorCode: error.code,
            query: req.query
        });
        res.status(500).json({
            success: false,
            message: 'Database error: ' + error.message,
            detail: error.detail
        });
    }
};

/**
 * Delete a carpool
 */
export const deleteCarpool = async (req, res) => {
    const { id } = req.params;

    try {
        if (!id) {
            return res.status(400).json({ success: false, message: 'Invalid or missing carpool id' });
        }

        // Delete participants first due to foreign key constraints
        await pool.query('DELETE FROM carpool_participants WHERE carpool_id = $1', [id]);
        
        // Then delete the carpool
        const result = await pool.query('DELETE FROM carpools WHERE id = $1 RETURNING *', [id]);

        if (result.rowCount === 0) {
            return res.status(404).json({ success: false, message: 'Carpool not found' });
        }

        res.json({ success: true, message: 'Carpool deleted successfully' });
    } catch (error) {
        console.error('[ERROR] deleteCarpool FULL DETAILS:', {
            errorMessage: error.message,
            errorCode: error.code
        });
        res.status(500).json({
            success: false,
            message: 'Database error: ' + error.message,
            detail: error.detail
        });
    }
};
