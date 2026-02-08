import { useState, useEffect } from 'react';
import { Brain, TrendingUp, Target, Zap, AlertTriangle } from 'lucide-react';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { analyticsAPI } from '../services/api';

const AIOptimization = () => {
  const [demandPrediction, setDemandPrediction] = useState([]);
  const [clusteringPerformance, setClusteringPerformance] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const data = await analyticsAPI.getAIOptimization();
        setDemandPrediction(data.demandPrediction || []);
        setClusteringPerformance(data.clusteringPerformance || []);
        setError(null);
      } catch (err) {
        setError(err.message || 'Failed to fetch AI optimization data');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const modelMetrics = clusteringPerformance.slice(0, 4).map((perf, index) => ({
    model: perf.model || perf.metric || 'Unknown Model',
    accuracy: perf.accuracy || perf.value || 90,
    latency: perf.latency || perf.response_time || '50ms',
    status: perf.status || (perf.value >= 92 ? 'Excellent' : 'Good')
  }));

  const aiInsights = [
    {
      title: 'High Demand Prediction',
      description: 'AI predicts 35% increase in demand for Downtown area between 17:00-19:00 tomorrow.',
      priority: 'high',
      action: 'Pre-position 12 additional drivers'
    },
    {
      title: 'Optimal Clustering',
      description: 'Ride clustering algorithm has identified 23 potential pooling opportunities in the next hour.',
      priority: 'medium',
      action: 'Send pooling suggestions to riders'
    },
    {
      title: 'Route Efficiency',
      description: 'New route optimization model improved average trip time by 8% in pilot test.',
      priority: 'low',
      action: 'Deploy to production fleet'
    },
  ];

  const getStatusColor = (status) => {
    switch(status) {
      case 'Excellent': return 'bg-green-100 text-green-800';
      case 'Good': return 'bg-blue-100 text-blue-800';
      case 'Fair': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getPriorityColor = (priority) => {
    switch(priority) {
      case 'high': return 'bg-red-100 text-red-800 border-red-300';
      case 'medium': return 'bg-yellow-100 text-yellow-800 border-yellow-300';
      case 'low': return 'bg-blue-100 text-blue-800 border-blue-300';
      default: return 'bg-gray-100 text-gray-800 border-gray-300';
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading AI optimization data...</p>
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
        <h2 className="text-2xl font-bold text-gray-900">AI & Optimization Control</h2>
        <p className="text-gray-600 mt-1">Monitor AI models, predictions, and optimization performance</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Model Accuracy</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">92%</p>
            </div>
            <Brain className="text-purple-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Predictions/Day</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">45.2K</p>
            </div>
            <TrendingUp className="text-blue-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Optimization Rate</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">94%</p>
            </div>
            <Target className="text-green-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Avg Response</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">51ms</p>
            </div>
            <Zap className="text-yellow-500" size={32} />
          </div>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Demand Prediction Monitoring */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Demand Prediction Accuracy</h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={demandPrediction}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="hour" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="predicted" stroke="#3b82f6" strokeWidth={2} name="AI Predicted" />
              <Line type="monotone" dataKey="actual" stroke="#10b981" strokeWidth={2} name="Actual Demand" />
            </LineChart>
          </ResponsiveContainer>
          <div className="mt-4 p-3 bg-blue-50 rounded-lg">
            <p className="text-sm text-blue-900">
              <strong>Accuracy Rate:</strong> 94.5% - Model is performing within expected parameters
            </p>
          </div>
        </div>

        {/* Clustering Performance */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Ride Clustering Performance</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={clusteringPerformance}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="metric" />
              <YAxis domain={[0, 100]} />
              <Tooltip />
              <Legend />
              <Bar dataKey="value" fill="#10b981" name="Current" />
              <Bar dataKey="target" fill="#3b82f6" name="Target" />
            </BarChart>
          </ResponsiveContainer>
          <div className="mt-4 p-3 bg-green-50 rounded-lg">
            <p className="text-sm text-green-900">
              <strong>Status:</strong> All metrics exceeding targets - Excellent clustering efficiency
            </p>
          </div>
        </div>
      </div>

      {/* Model Evaluation Metrics */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Model Evaluation Metrics</h3>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-200">
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Model</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Accuracy</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Avg Latency</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Performance</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Status</th>
              </tr>
            </thead>
            <tbody>
              {modelMetrics.map((model, index) => (
                <tr key={index} className="border-b border-gray-100 hover:bg-gray-50">
                  <td className="py-4 px-4 font-medium text-gray-900">{model.model}</td>
                  <td className="py-4 px-4">
                    <div className="flex items-center">
                      <div className="w-full bg-gray-200 rounded-full h-2 mr-2" style={{ maxWidth: '100px' }}>
                        <div 
                          className="bg-green-500 h-2 rounded-full" 
                          style={{ width: `${model.accuracy}%` }}
                        ></div>
                      </div>
                      <span className="font-semibold text-gray-900">{model.accuracy}%</span>
                    </div>
                  </td>
                  <td className="py-4 px-4 text-gray-600">{model.latency}</td>
                  <td className="py-4 px-4">
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div 
                        className={`h-2 rounded-full ${
                          model.accuracy >= 92 ? 'bg-green-500' :
                          model.accuracy >= 88 ? 'bg-blue-500' : 'bg-yellow-500'
                        }`}
                        style={{ width: `${model.accuracy}%` }}
                      ></div>
                    </div>
                  </td>
                  <td className="py-4 px-4">
                    <span className={`px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(model.status)}`}>
                      {model.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* AI Insights & Recommendations */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">AI Insights & Recommendations</h3>
        <div className="space-y-4">
          {aiInsights.map((insight, index) => (
            <div key={index} className={`border-2 rounded-lg p-4 ${getPriorityColor(insight.priority)}`}>
              <div className="flex items-start justify-between mb-2">
                <h4 className="font-semibold text-gray-900">{insight.title}</h4>
                <span className="text-xs px-2 py-1 rounded-full font-semibold uppercase">
                  {insight.priority}
                </span>
              </div>
              <p className="text-sm text-gray-700 mb-3">{insight.description}</p>
              <div className="flex items-center justify-between pt-3 border-t border-gray-200">
                <span className="text-xs text-gray-600">
                  <strong>Recommended Action:</strong> {insight.action}
                </span>
                <button className="text-sm bg-gray-900 text-white px-4 py-2 rounded-lg hover:bg-gray-800 transition-colors">
                  Take Action
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* System Status */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-gradient-to-br from-purple-50 to-purple-100 rounded-xl p-6 border border-purple-200">
          <Brain className="text-purple-600 mb-3" size={32} />
          <h4 className="font-semibold text-gray-900 mb-2">Neural Network</h4>
          <p className="text-sm text-gray-700 mb-3">Deep learning models active and processing</p>
          <div className="flex items-center">
            <div className="w-3 h-3 bg-green-500 rounded-full mr-2 animate-pulse"></div>
            <span className="text-sm font-medium text-green-700">Operational</span>
          </div>
        </div>

        <div className="bg-gradient-to-br from-blue-50 to-blue-100 rounded-xl p-6 border border-blue-200">
          <Target className="text-blue-600 mb-3" size={32} />
          <h4 className="font-semibold text-gray-900 mb-2">Optimization Engine</h4>
          <p className="text-sm text-gray-700 mb-3">Route and resource optimization running</p>
          <div className="flex items-center">
            <div className="w-3 h-3 bg-green-500 rounded-full mr-2 animate-pulse"></div>
            <span className="text-sm font-medium text-green-700">Operational</span>
          </div>
        </div>

        <div className="bg-gradient-to-br from-green-50 to-green-100 rounded-xl p-6 border border-green-200">
          <Zap className="text-green-600 mb-3" size={32} />
          <h4 className="font-semibold text-gray-900 mb-2">Real-time Processing</h4>
          <p className="text-sm text-gray-700 mb-3">Live data analysis and predictions</p>
          <div className="flex items-center">
            <div className="w-3 h-3 bg-green-500 rounded-full mr-2 animate-pulse"></div>
            <span className="text-sm font-medium text-green-700">Operational</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AIOptimization;
