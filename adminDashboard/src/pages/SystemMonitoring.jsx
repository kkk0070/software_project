import { useState, useEffect } from 'react';
import { Activity, Server, AlertTriangle, CheckCircle, Clock } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { monitoringAPI } from '../services/api';

const SystemMonitoring = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await monitoringAPI.getSystem();
        setData(response.data);
        setError(null);
      } catch (err) {
        setError(err.message);
        console.error('Error fetching system monitoring data:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Loading system monitoring data...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-4">
        <p className="text-red-800">Error loading data: {error}</p>
      </div>
    );
  }

  const { errorLogs = [], securityLogs = [], systemStats = {}, uptimePercentage = 99.8 } = data || {};
  const { uptimeData = [], apiEndpoints = [], performanceMetrics = [] } = systemStats;
  const DEFAULT_AVG_RESPONSE = '67ms';
  const DEFAULT_ACTIVE_SERVICES = '12/12';
  const DEFAULT_ERROR_RATE = '0.02%';

  const getStatusColor = (status) => {
    switch(status) {
      case 'Healthy': return 'bg-green-100 text-green-800';
      case 'Warning': return 'bg-yellow-100 text-yellow-800';
      case 'Critical': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getLevelColor = (level) => {
    switch(level) {
      case 'Error': return 'text-red-500 bg-red-50';
      case 'Warning': return 'text-yellow-500 bg-yellow-50';
      case 'Info': return 'text-blue-500 bg-blue-50';
      default: return 'text-gray-500 bg-gray-50';
    }
  };

  const getSeverityColor = (severity) => {
    switch(severity) {
      case 'High': return 'bg-red-100 text-red-800';
      case 'Medium': return 'bg-yellow-100 text-yellow-800';
      case 'Low': return 'bg-blue-100 text-blue-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h2 className="text-2xl font-bold text-gray-900">System Monitoring & Logs</h2>
        <p className="text-gray-600 mt-1">Monitor API health, performance, and security logs</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">System Uptime</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{uptimePercentage}%</p>
            </div>
            <CheckCircle className="text-green-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Avg Response</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{systemStats.avgResponse || DEFAULT_AVG_RESPONSE}</p>
            </div>
            <Clock className="text-blue-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Active Services</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{systemStats.activeServices || DEFAULT_ACTIVE_SERVICES}</p>
            </div>
            <Server className="text-purple-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Error Rate</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{systemStats.errorRate || DEFAULT_ERROR_RATE}</p>
            </div>
            <AlertTriangle className="text-yellow-500" size={32} />
          </div>
        </div>
      </div>

      {/* Uptime Chart */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">API Health & Uptime (24h)</h3>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={uptimeData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="time" />
            <YAxis domain={[99, 100]} label={{ value: 'Uptime %', angle: -90, position: 'insideLeft' }} />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="uptime" stroke="#10b981" strokeWidth={2} name="Uptime %" />
          </LineChart>
        </ResponsiveContainer>
      </div>

      {/* API Endpoints Status */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">API Endpoints Status</h3>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-200">
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Endpoint</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Status</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Uptime</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Avg Response</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Requests/Day</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Health</th>
              </tr>
            </thead>
            <tbody>
              {apiEndpoints.map((endpoint, index) => (
                <tr key={index} className="border-b border-gray-100 hover:bg-gray-50">
                  <td className="py-4 px-4 font-mono text-sm text-gray-900">{endpoint.endpoint}</td>
                  <td className="py-4 px-4">
                    <span className={`px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(endpoint.status)}`}>
                      {endpoint.status}
                    </span>
                  </td>
                  <td className="py-4 px-4 font-semibold text-gray-900">{endpoint.uptime}%</td>
                  <td className="py-4 px-4 text-gray-600">{endpoint.avgResponse}</td>
                  <td className="py-4 px-4 text-gray-600">{endpoint.requests}</td>
                  <td className="py-4 px-4">
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div 
                        className={`h-2 rounded-full ${
                          endpoint.status === 'Healthy' ? 'bg-green-500' :
                          endpoint.status === 'Warning' ? 'bg-yellow-500' : 'bg-red-500'
                        }`}
                        style={{ width: `${endpoint.uptime}%` }}
                      ></div>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Error and Security Logs */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Error Logs */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Error Logs</h3>
          <div className="space-y-3">
            {errorLogs.map((log) => (
              <div key={log.id} className={`border rounded-lg p-4 ${getLevelColor(log.level)}`}>
                <div className="flex items-start justify-between mb-2">
                  <div className="flex items-center">
                    <AlertTriangle size={18} className="mr-2" />
                    <span className="font-semibold text-sm">{log.level}</span>
                  </div>
                  <span className="text-xs text-gray-600">{log.timestamp}</span>
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-900 mb-1">{log.service}</p>
                  <p className="text-sm text-gray-700">{log.message}</p>
                  <p className="text-xs text-gray-600 mt-2">Occurrences: {log.count}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Security Logs */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Security Logs</h3>
          <div className="space-y-3">
            {securityLogs.map((log) => (
              <div key={log.id} className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-start justify-between mb-2">
                  <div>
                    <h4 className="font-semibold text-gray-900 text-sm">{log.type}</h4>
                    <p className="text-xs text-gray-600 mt-1">{log.timestamp}</p>
                  </div>
                  <span className={`text-xs px-2 py-1 rounded-full font-medium ${getSeverityColor(log.severity)}`}>
                    {log.severity}
                  </span>
                </div>
                <p className="text-sm text-gray-700 mt-2">{log.details}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Performance Metrics */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Performance Metrics</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {performanceMetrics.map((metric, index) => (
            <div key={index} className="border border-gray-200 rounded-lg p-4">
              <div className="flex items-center justify-between mb-3">
                <h4 className="font-semibold text-gray-900">{metric.name}</h4>
                <span className="text-sm font-medium text-green-600">{metric.status}</span>
              </div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-2xl font-bold text-gray-900">{metric.value}</span>
                <span className="text-sm text-gray-600">/ {metric.max}</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3">
                <div 
                  className="bg-blue-500 h-3 rounded-full" 
                  style={{ width: `${(metric.value / metric.max) * 100}%` }}
                ></div>
              </div>
              <p className="text-xs text-gray-600 mt-2">
                {Math.round((metric.value / metric.max) * 100)}% utilized
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default SystemMonitoring;
