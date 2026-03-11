import pool from '../../config/database.js';

/**
 * Save a downloaded map (encoded polyline)
 */
export const saveDownloadedMap = async (req, res) => {
    const { userId, pickup, dropoff, encodedPolyline } = req.body;

    try {
        if (!userId || !encodedPolyline) {
            console.warn('[WARN] saveDownloadedMap: Missing userId or encodedPolyline', { userId, encodedPolyline });
            return res.status(400).json({ success: false, message: 'Missing required fields' });
        }

        const numericUserId = parseInt(userId);
        if (isNaN(numericUserId)) {
            return res.status(400).json({ success: false, message: 'Invalid userId' });
        }

        const result = await pool.query(`
            INSERT INTO downloaded_maps (user_id, pickup, dropoff, encoded_polyline, expires_at)
            VALUES ($1, $2, $3, $4, NOW() + INTERVAL '1 hour')
            RETURNING *
        `, [numericUserId, pickup, dropoff, encodedPolyline]);

        res.status(201).json({ success: true, data: result.rows[0], message: 'Map downloaded successfully. It will be deleted after 1 hour.' });
    } catch (error) {
        console.error('[ERROR] saveDownloadedMap:', error);
        res.status(500).json({ success: false, message: 'Database error: ' + error.message });
    }
};

/**
 * Get downloaded maps for a user (also auto-deletes expired ones first)
 */
export const getDownloadedMaps = async (req, res) => {
    const userId = req.query.userId;

    try {
        if (!userId) {
            return res.status(400).json({ success: false, message: 'Missing userId' });
        }

        // Auto-cleanup expired maps occasionally
        await pool.query('DELETE FROM downloaded_maps WHERE expires_at < NOW()');

        const result = await pool.query(`
            SELECT * FROM downloaded_maps 
            WHERE user_id = $1
            ORDER BY created_at DESC
        `, [userId]);

        res.json({ success: true, data: result.rows });
    } catch (error) {
        console.error('[ERROR] getDownloadedMaps:', error);
        res.status(500).json({ success: false, message: 'Database error' });
    }
};

/**
 * Explicitly delete a downloaded map
 */
export const deleteDownloadedMap = async (req, res) => {
    const { id } = req.params;

    try {
        const result = await pool.query('DELETE FROM downloaded_maps WHERE id = $1 RETURNING *', [id]);
        if (result.rowCount === 0) {
            return res.status(404).json({ success: false, message: 'Map not found' });
        }
        res.json({ success: true, message: 'Map deleted successfully' });
    } catch (error) {
        console.error('[ERROR] deleteDownloadedMap:', error);
        res.status(500).json({ success: false, message: 'Database error' });
    }
};
