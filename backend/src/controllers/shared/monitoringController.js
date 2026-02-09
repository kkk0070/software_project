import { knex } from '../../config/database.js';

// Get live ride monitoring data
export const getLiveRideMonitoring = async (req, res) => {
  try {
    // Get active rides with full details
    const activeRides = await knex('rides as r')
      .select(
        'r.*',
        'rider.name as rider_name',
        'rider.phone as rider_phone',
        'driver.name as driver_name',
        'driver.phone as driver_phone',
        'd.vehicle_type',
        'd.vehicle_model',
        'd.license_plate'
      )
      .innerJoin('users as rider', 'r.rider_id', 'rider.id')
      .innerJoin('users as driver', 'r.driver_id', 'driver.id')
      .innerJoin('drivers as d', 'driver.id', 'd.user_id')
      .where('r.status', 'Active')
      .orderBy('r.started_at', 'desc')
      .limit(20);

    // Get recent incidents
    const recentIncidents = await knex('emergency_incidents as ei')
      .select(
        'ei.*',
        'u.name as user_name',
        'u.phone as user_phone'
      )
      .innerJoin('users as u', 'ei.user_id', 'u.id')
      .whereIn('ei.status', ['Open', 'In Progress'])
      .orderBy('ei.created_at', 'desc')
      .limit(10);

    // Get fleet statistics
    const fleetStats = await knex('drivers as d')
      .select(
        'd.vehicle_type',
        knex.raw('COUNT(*) as total'),
        knex.raw("COUNT(*) FILTER (WHERE d.available = true AND u.status = 'Active') as available")
      )
      .innerJoin('users as u', 'd.user_id', 'u.id')
      .where('u.role', 'Driver')
      .groupBy('d.vehicle_type');

    res.json({
      success: true,
      data: {
        activeRides: activeRides,
        recentIncidents: recentIncidents,
        fleetStats: fleetStats
      }
    });
  } catch (error) {
    console.error('Error fetching live ride monitoring:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching live ride monitoring data',
      error: error.message
    });
  }
};

// Get safety monitoring data
export const getSafetyMonitoring = async (req, res) => {
  try {
    // Get SOS incidents
    const sosIncidents = await knex('emergency_incidents as ei')
      .select(
        'ei.*',
        'u.name as user_name',
        'u.email as user_email',
        'u.phone as user_phone',
        'r.pickup_location',
        'r.dropoff_location'
      )
      .innerJoin('users as u', 'ei.user_id', 'u.id')
      .leftJoin('rides as r', 'ei.ride_id', 'r.id')
      .where(function() {
        this.where('ei.incident_type', 'like', '%SOS%')
          .orWhereIn('ei.priority', ['High', 'Critical']);
      })
      .orderBy('ei.created_at', 'desc')
      .limit(20);

    // Get emergency statistics
    const emergencyStats = await knex('emergency_incidents')
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '30 days'"))
      .select(
        knex.raw('COUNT(*) as total_incidents'),
        knex.raw("COUNT(*) FILTER (WHERE status = 'Open') as open_incidents"),
        knex.raw("COUNT(*) FILTER (WHERE priority = 'Critical') as critical_incidents"),
        knex.raw("AVG(EXTRACT(EPOCH FROM (resolved_at - created_at))/60) FILTER (WHERE resolved_at IS NOT NULL) as avg_response_time")
      )
      .first();

    // Get recent resolutions
    const recentResolutions = await knex('emergency_incidents as ei')
      .select(
        'ei.*',
        'u.name as user_name',
        knex.raw('EXTRACT(EPOCH FROM (ei.resolved_at - ei.created_at))/60 as resolution_time_minutes')
      )
      .innerJoin('users as u', 'ei.user_id', 'u.id')
      .where('ei.status', 'Resolved')
      .whereNotNull('ei.resolved_at')
      .orderBy('ei.resolved_at', 'desc')
      .limit(10);

    res.json({
      success: true,
      data: {
        sosIncidents: sosIncidents,
        emergencyStats: emergencyStats,
        recentResolutions: recentResolutions
      }
    });
  } catch (error) {
    console.error('Error fetching safety monitoring:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching safety monitoring data',
      error: error.message
    });
  }
};

// Get system monitoring data
export const getSystemMonitoring = async (req, res) => {
  try {
    // Get system logs
    const errorLogs = await knex('system_logs')
      .where('log_type', 'Error')
      .orderBy('created_at', 'desc')
      .limit(20);

    const securityLogs = await knex('system_logs')
      .where('log_type', 'Security')
      .orderBy('created_at', 'desc')
      .limit(20);

    // Get system statistics
    const systemStats = await knex.raw(`
      SELECT 
        (SELECT COUNT(*) FROM users WHERE status = 'Active') as active_users,
        (SELECT COUNT(*) FROM rides WHERE status = 'Active') as active_rides,
        (SELECT COUNT(*) FROM system_logs WHERE log_type = 'Error' AND created_at >= NOW() - INTERVAL '24 hours') as errors_24h,
        (SELECT COUNT(*) FROM emergency_incidents WHERE status = 'Open') as open_incidents
    `);

    // Calculate uptime percentage (mock calculation based on error rate)
    const totalLogs = await knex('system_logs')
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '7 days'"))
      .count('* as total')
      .first();
      
    const errorCount = await knex('system_logs')
      .where('log_type', 'Error')
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '7 days'"))
      .count('* as errors')
      .first();
    
    const uptimePercentage = totalLogs.total > 0 
      ? (100 - (errorCount.errors / totalLogs.total * 100)).toFixed(2)
      : 99.9;

    res.json({
      success: true,
      data: {
        errorLogs: errorLogs,
        securityLogs: securityLogs,
        systemStats: systemStats.rows[0],
        uptimePercentage: parseFloat(uptimePercentage)
      }
    });
  } catch (error) {
    console.error('Error fetching system monitoring:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching system monitoring data',
      error: error.message
    });
  }
};

// Get GPS logs data
export const getGPSLogs = async (req, res) => {
  try {
    // Get recent rides with GPS data
    const gpsData = await knex('rides as r')
      .select(
        'r.id',
        'r.pickup_lat',
        'r.pickup_lng',
        'r.dropoff_lat',
        'r.dropoff_lng',
        'r.distance',
        'r.created_at',
        'driver.name as driver_name'
      )
      .innerJoin('users as driver', 'r.driver_id', 'driver.id')
      .whereNotNull('r.pickup_lat')
      .whereNotNull('r.dropoff_lat')
      .orderBy('r.created_at', 'desc')
      .limit(50);

    // Calculate GPS accuracy metrics (mock based on data quality)
    const accuracyMetrics = await knex('rides')
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '7 days'"))
      .select(
        knex.raw('COUNT(*) as total_records'),
        knex.raw('COUNT(*) FILTER (WHERE pickup_lat IS NOT NULL AND dropoff_lat IS NOT NULL) as valid_records'),
        knex.raw('AVG(distance) as avg_distance')
      )
      .first();

    const accuracy = accuracyMetrics.total_records > 0 
      ? (accuracyMetrics.valid_records / accuracyMetrics.total_records * 100).toFixed(2)
      : 95.0;

    res.json({
      success: true,
      data: {
        gpsLogs: gpsData,
        accuracy: parseFloat(accuracy),
        totalRecords: parseInt(accuracyMetrics.total_records)
      }
    });
  } catch (error) {
    console.error('Error fetching GPS logs:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching GPS logs',
      error: error.message
    });
  }
};
