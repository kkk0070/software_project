import { knex } from '../../config/database.js';

// Get overview statistics
export const getOverviewStats = async (req, res) => {
  try {
    const stats = await knex.raw(`
      SELECT 
        (SELECT COUNT(*) FROM users WHERE role = 'Rider') as total_riders,
        (SELECT COUNT(*) FROM rides WHERE status = 'Active') as active_rides,
        (SELECT COUNT(*) FROM rides WHERE status = 'Completed') as completed_rides,
        (SELECT SUM(carbon_saved) FROM rides WHERE carbon_saved IS NOT NULL) as carbon_saved
    `);

    // Get ride trends for last 7 days
    const rideTrends = await knex('rides')
      .select(knex.raw("TO_CHAR(created_at, 'HH24:00') as hour"), knex.raw('COUNT(*) as count'))
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '24 hours'"))
      .groupByRaw("TO_CHAR(created_at, 'HH24:00')")
      .orderBy('hour');

    // Get vehicle distribution
    const vehicleDistribution = await knex('drivers as d')
      .select('d.vehicle_type', knex.raw('COUNT(*) as count'))
      .innerJoin('users as u', 'd.user_id', 'u.id')
      .where('u.status', 'Active')
      .groupBy('d.vehicle_type');

    res.json({
      success: true,
      data: {
        stats: stats.rows[0],
        rideTrends: rideTrends,
        vehicleDistribution: vehicleDistribution
      }
    });
  } catch (error) {
    console.error('Error fetching overview stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching overview statistics',
      error: error.message
    });
  }
};

// Get demand heatmap data
export const getDemandHeatmap = async (req, res) => {
  try {
    // Group rides by location to create demand areas
    const demandAreas = await knex('rides')
      .select(
        'pickup_location as area',
        knex.raw('COUNT(*) as demand_count'),
        knex.raw('AVG(pickup_lat) as lat'),
        knex.raw('AVG(pickup_lng) as lng')
      )
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '30 days'")) // Increased range for better data
      .groupBy('pickup_location')
      .orderBy('demand_count', 'desc')
      .limit(15);

    // Get peak times
    const peakTimes = await knex('rides')
      .select(
        knex.raw(`
          CASE 
            WHEN EXTRACT(HOUR FROM created_at) BETWEEN 6 AND 11 THEN 'Morning (6-11 AM)'
            WHEN EXTRACT(HOUR FROM created_at) BETWEEN 12 AND 17 THEN 'Afternoon (12-5 PM)'
            WHEN EXTRACT(HOUR FROM created_at) BETWEEN 18 AND 23 THEN 'Evening (6-11 PM)'
            ELSE 'Night (12-5 AM)'
          END as period
        `),
        knex.raw('COUNT(*) as rides'),
        knex.raw('AVG(fare) as avg_fare')
      )
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '30 days'"))
      .groupByRaw(1)
      .orderBy('rides', 'desc');

    res.json({
      success: true,
      data: {
        demandAreas: demandAreas.map(a => ({
          ...a,
          demand: a.demand_count > 20 ? 'High' : a.demand_count > 10 ? 'Medium' : 'Low',
          color: a.demand_count > 20 ? 'text-red-600' : a.demand_count > 10 ? 'text-yellow-600' : 'text-green-600',
          change: '+15%', // Mock change
          rides: a.demand_count
        })),
        peakTimes: peakTimes.map(p => ({
          time: p.period.split(' ')[0],
          period: p.period,
          demand: Math.min(100, Math.floor(p.rides * 2.5)) // Normalized demand
        }))
      }
    });
  } catch (error) {
    console.error('Error fetching demand heatmap:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching demand heatmap',
      error: error.message
    });
  }
};

// Get route analytics
export const getRouteAnalytics = async (req, res) => {
  try {
    // Get popular routes
    const popularRoutes = await knex('rides')
      .select(
        'pickup_location',
        'dropoff_location',
        knex.raw('AVG(pickup_lat) as pickup_lat'),
        knex.raw('AVG(pickup_lng) as pickup_lng'),
        knex.raw('AVG(dropoff_lat) as dropoff_lat'),
        knex.raw('AVG(dropoff_lng) as dropoff_lng'),
        knex.raw('COUNT(*) as frequency'),
        knex.raw('AVG(distance) as avg_distance'),
        knex.raw('AVG(fare) as avg_fare'),
        knex.raw('AVG(duration) as avg_duration'),
        knex.raw('SUM(carbon_saved) as total_carbon_saved')
      )
      .where('status', 'Completed')
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '30 days'"))
      .groupBy('pickup_location', 'dropoff_location')
      .orderBy('frequency', 'desc')
      .limit(10);

    // Get savings over time
    // We group by date_trunc and include it in selection for proper sorting
    const savingsDataRaw = await knex('rides')
      .select(
        knex.raw("DATE_TRUNC('month', created_at) as month_date"),
        knex.raw("TO_CHAR(created_at, 'Mon YYYY') as month"),
        knex.raw('SUM(carbon_saved) as carbon_saved'),
        knex.raw('SUM(distance) as distance_saved'),
        knex.raw('COUNT(*) as count')
      )
      .where('status', 'Completed')
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '12 months'"))
      .groupByRaw("DATE_TRUNC('month', created_at), TO_CHAR(created_at, 'Mon YYYY')")
      .orderBy('month_date', 'asc');

    res.json({
      success: true,
      data: {
        popularRoutes: popularRoutes.map(r => ({
          ...r,
          route: `${r.pickup_location} ➔ ${r.dropoff_location}`,
          actual_time: Math.floor(r.avg_duration),
          predicted_time: Math.floor(r.avg_duration * 0.95),
          efficiency: 95
        })),
        savingsData: savingsDataRaw.map(s => ({
          month: s.month,
          distance: parseFloat(s.distance_saved || 0).toFixed(1),
          fuel: parseFloat(s.distance_saved * 0.08 || 0).toFixed(1), // Mock fuel calculation
          carbon: parseFloat(s.carbon_saved || 0).toFixed(1)
        }))
      }
    });
  } catch (error) {
    console.error('Error fetching route analytics:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching route analytics',
      error: error.message
    });
  }
};

// Get sustainability metrics
export const getSustainabilityMetrics = async (req, res) => {
  try {
    const emissionData = await knex('rides')
      .select(
        knex.raw("DATE_TRUNC('month', created_at) as month_date"),
        knex.raw("TO_CHAR(created_at, 'Mon') as month"),
        knex.raw('SUM(carbon_saved) as co2_saved')
      )
      .where('status', 'Completed')
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '6 months'"))
      .groupByRaw("DATE_TRUNC('month', created_at), TO_CHAR(created_at, 'Mon')")
      .orderBy('month_date', 'asc');

    const vehicleImpact = await knex('rides as r')
      .select(
        'd.vehicle_type',
        knex.raw('COUNT(r.id) as rides'),
        knex.raw('SUM(r.carbon_saved) as carbon_saved')
      )
      .innerJoin('drivers as d', 'r.driver_id', 'd.user_id')
      .where('r.status', 'Completed')
      .where('r.created_at', '>=', knex.raw("NOW() - INTERVAL '30 days'"))
      .groupBy('d.vehicle_type')
      .orderBy('carbon_saved', 'desc');

    const communityMetrics = await knex('rides')
      .select(
        knex.raw('COUNT(DISTINCT rider_id) as active_users'),
        knex.raw('COUNT(*) as total_rides'),
        knex.raw('SUM(carbon_saved) as total_carbon_saved'),
        knex.raw('SUM(distance) as total_distance')
      )
      .where('status', 'Completed')
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '30 days'"))
      .first();

    res.json({
      success: true,
      data: {
        emissionData: emissionData,
        vehicleImpact: vehicleImpact,
        communityMetrics: communityMetrics
      }
    });
  } catch (error) {
    console.error('Error fetching sustainability metrics:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching sustainability metrics',
      error: error.message
    });
  }
};

// Get AI optimization data
export const getAIOptimization = async (req, res) => {
  try {
    const demandPrediction = await knex('rides')
      .select(
        knex.raw('EXTRACT(HOUR FROM created_at) as hour'),
        knex.raw('COUNT(*) as rides'),
        knex.raw('AVG(fare) as avg_fare')
      )
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '7 days'"))
      .groupByRaw(1)
      .orderBy('hour');

    const clusteringPerformance = await knex('rides')
      .select(
        'pickup_location as area',
        knex.raw('COUNT(*) as total_rides'),
        knex.raw('AVG(duration) as avg_duration'),
        knex.raw("COUNT(*) FILTER (WHERE ride_type = 'Pool') * 100.0 / COUNT(*) as pool_percentage")
      )
      .where('created_at', '>=', knex.raw("NOW() - INTERVAL '7 days'"))
      .groupBy('pickup_location')
      .orderBy('total_rides', 'desc')
      .limit(5);

    res.json({
      success: true,
      data: {
        demandPrediction: demandPrediction,
        clusteringPerformance: clusteringPerformance
      }
    });
  } catch (error) {
    console.error('Error fetching AI optimization data:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching AI optimization data',
      error: error.message
    });
  }
};
