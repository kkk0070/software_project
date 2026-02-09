import { useState, useEffect } from 'react';
import { Route as RouteIcon, TrendingUp, Clock, MapPin, AlertTriangle } from 'lucide-react';
import { BarChart, Bar, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { analyticsAPI } from '../services/api';

const RouteAnalytics = () => {
  const [popularRoutes, setPopularRoutes] = useState([]);
  const [savingsData, setSavingsData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const data = await analyticsAPI.getRouteAnalytics();
        setPopularRoutes(data.popularRoutes || []);
        setSavingsData(data.savingsData || []);
        setError(null);
      } catch (err) {
        setError(err.message || 'Failed to fetch route analytics data');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const routeComparison = popularRoutes.slice(0, 4).map(route => ({
    route: route.route || route.name || 'Unknown',
    actual: route.actual_time || route.actual || 0,
    predicted: route.predicted_time || route.predicted || 0,
    efficiency: route.efficiency || 90
  }));

  const topRoutes = popularRoutes.slice(0, 4).map(route => {
    const time = route.avgTime || route.avg_time || route.avg_duration || 0;
    const formattedTime = typeof time === 'number' ? `${time} min` : time;
    return {
      route: route.route || route.name || 'Unknown',
      trips: route.trips || route.count || 0,
      avgTime: formattedTime,
      savings: route.savings || route.efficiency || '0%'
    };
  });

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading route analytics...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-6">
        <div className="flex items-center">
          <AlertTriangle className="text-red-500 mr-3" size={24} />
          <div>
            <h3 className="text-red-900 font-semibold">Error Loading Data</h3>
            <p className="text-red-700 text-sm mt-1">{error}</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h2 className="text-2xl font-bold text-gray-900">Route & Performance Analytics</h2>
        <p className="text-gray-600 mt-1">Route efficiency, time predictions, and fuel savings analysis</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Avg Efficiency</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">92.5%</p>
            </div>
            <TrendingUp className="text-green-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Distance Saved</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">2,100km</p>
            </div>
            <MapPin className="text-blue-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Fuel Saved</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">750L</p>
            </div>
            <RouteIcon className="text-purple-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Time Accuracy</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">94%</p>
            </div>
            <Clock className="text-orange-500" size={32} />
          </div>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Predicted vs Actual Time */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Predicted vs Actual Time</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={routeComparison}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="route" />
              <YAxis label={{ value: 'Minutes', angle: -90, position: 'insideLeft' }} />
              <Tooltip />
              <Legend />
              <Bar dataKey="predicted" fill="#3b82f6" name="Predicted" />
              <Bar dataKey="actual" fill="#10b981" name="Actual" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Distance & Fuel Savings */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Distance & Fuel Savings</h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={savingsData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis yAxisId="left" label={{ value: 'Distance (km)', angle: -90, position: 'insideLeft' }} />
              <YAxis yAxisId="right" orientation="right" label={{ value: 'Fuel (L)', angle: 90, position: 'insideRight' }} />
              <Tooltip />
              <Legend />
              <Line yAxisId="left" type="monotone" dataKey="distance" stroke="#3b82f6" name="Distance Saved (km)" />
              <Line yAxisId="right" type="monotone" dataKey="fuel" stroke="#10b981" name="Fuel Saved (L)" />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Route Efficiency Table */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Route Efficiency Comparison</h3>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-200">
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Route</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Predicted Time</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Actual Time</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Efficiency</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Status</th>
              </tr>
            </thead>
            <tbody>
              {routeComparison.map((route, index) => (
                <tr key={index} className="border-b border-gray-100 hover:bg-gray-50">
                  <td className="py-4 px-4 font-medium text-gray-900">{route.route}</td>
                  <td className="py-4 px-4 text-gray-600">{route.predicted} min</td>
                  <td className="py-4 px-4 text-gray-600">{route.actual} min</td>
                  <td className="py-4 px-4">
                    <div className="flex items-center">
                      <div className="w-full bg-gray-200 rounded-full h-2 mr-2" style={{ maxWidth: '100px' }}>
                        <div 
                          className="bg-green-500 h-2 rounded-full" 
                          style={{ width: `${route.efficiency}%` }}
                        ></div>
                      </div>
                      <span className="font-semibold text-gray-900">{route.efficiency}%</span>
                    </div>
                  </td>
                  <td className="py-4 px-4">
                    <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                      route.efficiency >= 94 ? 'bg-green-100 text-green-800' :
                      route.efficiency >= 90 ? 'bg-yellow-100 text-yellow-800' :
                      'bg-red-100 text-red-800'
                    }`}>
                      {route.efficiency >= 94 ? 'Excellent' : route.efficiency >= 90 ? 'Good' : 'Needs Improvement'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Top Routes */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Top Performing Routes</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {topRoutes.map((route, index) => (
            <div key={index} className="border border-gray-200 rounded-lg p-4">
              <div className="flex items-center mb-3">
                <div className="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center text-white font-semibold mr-3">
                  {index + 1}
                </div>
                <h4 className="font-semibold text-gray-900">{route.route}</h4>
              </div>
              <div className="grid grid-cols-3 gap-2 text-sm">
                <div>
                  <p className="text-gray-600">Trips</p>
                  <p className="font-semibold text-gray-900">{route.trips}</p>
                </div>
                <div>
                  <p className="text-gray-600">Avg Time</p>
                  <p className="font-semibold text-gray-900">{route.avgTime}</p>
                </div>
                <div>
                  <p className="text-gray-600">Savings</p>
                  <p className="font-semibold text-green-600">{route.savings}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default RouteAnalytics;
