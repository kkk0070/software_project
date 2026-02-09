import { useState, useEffect } from 'react';
import { Leaf, TrendingDown, Users, Car, AlertTriangle } from 'lucide-react';
import { AreaChart, Area, BarChart, Bar, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { analyticsAPI } from '../services/api';

const Sustainability = () => {
  const [emissionData, setEmissionData] = useState([]);
  const [vehicleImpact, setVehicleImpact] = useState([]);
  const [communityMetrics, setCommunityMetrics] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const data = await analyticsAPI.getSustainability();
        setEmissionData(data.emissionData || []);
        setVehicleImpact(data.vehicleImpact || []);
        setCommunityMetrics(data.communityMetrics || []);
        setError(null);
      } catch (err) {
        setError(err.message || 'Failed to fetch sustainability data');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading sustainability data...</p>
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
        <h2 className="text-2xl font-bold text-gray-900">Sustainability Analytics</h2>
        <p className="text-gray-600 mt-1">Track emission reduction, EV impact, and community sustainability</p>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {communityMetrics.map((item, index) => {
          const Icon = item.icon;
          return (
            <div key={index} className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
              <div className="flex items-center justify-between mb-3">
                <Icon className="text-green-500" size={32} />
                <span className="text-green-600 text-sm font-semibold">{item.trend}</span>
              </div>
              <p className="text-gray-600 text-sm">{item.metric}</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{item.value}</p>
            </div>
          );
        })}
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Emission Reduction */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Total Emission Reduction (tons)</h3>
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={emissionData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Area type="monotone" dataKey="baseline" stackId="1" stroke="#ef4444" fill="#fee2e2" name="Baseline" />
              <Area type="monotone" dataKey="saved" stackId="1" stroke="#10b981" fill="#10b981" fillOpacity={0.6} name="CO₂ Saved" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Vehicle Impact Distribution */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Impact by Category</h3>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={vehicleImpact}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, value }) => `${name}: ${value}%`}
                outerRadius={100}
                fill="#8884d8"
                dataKey="value"
              >
                {vehicleImpact.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* EV & Pooling Impact */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* EV Impact */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Electric Vehicle Impact</h3>
          <div className="space-y-4">
            <div className="bg-green-50 border border-green-200 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm text-green-900 font-medium">Total EV Rides</span>
                <span className="text-2xl font-bold text-green-900">15,234</span>
              </div>
              <div className="text-sm text-green-700">
                <p>CO₂ Reduction: <strong>1,560 tons</strong></p>
                <p className="mt-1">Average per ride: <strong>102g saved</strong></p>
              </div>
            </div>
            
            <div className="space-y-2">
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <span className="text-sm text-gray-700">EV Fleet Size</span>
                <span className="font-semibold text-gray-900">168 vehicles</span>
              </div>
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <span className="text-sm text-gray-700">EV Utilization Rate</span>
                <span className="font-semibold text-gray-900">73%</span>
              </div>
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <span className="text-sm text-gray-700">Avg Daily EV Rides</span>
                <span className="font-semibold text-gray-900">304 rides</span>
              </div>
            </div>
          </div>
        </div>

        {/* Pooling Impact */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Ride Pooling Impact</h3>
          <div className="space-y-4">
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm text-blue-900 font-medium">Pooling Participation</span>
                <span className="text-2xl font-bold text-blue-900">34%</span>
              </div>
              <div className="text-sm text-blue-700">
                <p>CO₂ Reduction: <strong>840 tons</strong></p>
                <p className="mt-1">Cost savings: <strong>$145,000</strong></p>
              </div>
            </div>
            
            <div className="space-y-2">
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <span className="text-sm text-gray-700">Total Pooled Rides</span>
                <span className="font-semibold text-gray-900">5,234</span>
              </div>
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <span className="text-sm text-gray-700">Avg Passengers/Ride</span>
                <span className="font-semibold text-gray-900">2.8</span>
              </div>
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <span className="text-sm text-gray-700">Vehicle Miles Reduced</span>
                <span className="font-semibold text-gray-900">12,450 mi</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Community Sustainability Metrics */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Community Sustainability Metrics</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="text-center p-6 bg-gradient-to-br from-green-50 to-green-100 rounded-lg">
            <Leaf className="text-green-600 mx-auto mb-3" size={48} />
            <h4 className="text-3xl font-bold text-green-900 mb-2">12,500</h4>
            <p className="text-sm text-green-700">Trees Equivalent Planted</p>
            <p className="text-xs text-green-600 mt-2">Based on CO₂ absorption</p>
          </div>
          
          <div className="text-center p-6 bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg">
            <TrendingDown className="text-blue-600 mx-auto mb-3" size={48} />
            <h4 className="text-3xl font-bold text-blue-900 mb-2">35%</h4>
            <p className="text-sm text-blue-700">Emission Reduction</p>
            <p className="text-xs text-blue-600 mt-2">vs Traditional Transport</p>
          </div>
          
          <div className="text-center p-6 bg-gradient-to-br from-purple-50 to-purple-100 rounded-lg">
            <Users className="text-purple-600 mx-auto mb-3" size={48} />
            <h4 className="text-3xl font-bold text-purple-900 mb-2">89%</h4>
            <p className="text-sm text-purple-700">Eco-Conscious Users</p>
            <p className="text-xs text-purple-600 mt-2">Opted for green options</p>
          </div>
        </div>
      </div>

      {/* Achievements */}
      <div className="bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl shadow-lg p-8 text-white">
        <h3 className="text-2xl font-bold mb-4">🏆 Sustainability Achievements</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-white/20 backdrop-blur-sm rounded-lg p-4">
            <p className="text-3xl font-bold mb-1">2.4T</p>
            <p className="text-sm">Total CO₂ Saved This Month</p>
          </div>
          <div className="bg-white/20 backdrop-blur-sm rounded-lg p-4">
            <p className="text-3xl font-bold mb-1">65%</p>
            <p className="text-sm">EV Fleet Composition</p>
          </div>
          <div className="bg-white/20 backdrop-blur-sm rounded-lg p-4">
            <p className="text-3xl font-bold mb-1">+22%</p>
            <p className="text-sm">EV Adoption Growth</p>
          </div>
          <div className="bg-white/20 backdrop-blur-sm rounded-lg p-4">
            <p className="text-3xl font-bold mb-1">#1</p>
            <p className="text-sm">Most Sustainable Platform</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Sustainability;
