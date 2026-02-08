import { useState, useEffect } from 'react';
import { Navigation, AlertTriangle, TrendingUp, MapPin } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { monitoringAPI } from '../services/api';

const GPSLogs = () => {
  const [gpsLogs, setGpsLogs] = useState([]);
  const [accuracy, setAccuracy] = useState([]);
  const [totalRecords, setTotalRecords] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const data = await monitoringAPI.getGPSLogs();
        setGpsLogs(data.gpsLogs || []);
        setAccuracy(data.accuracy || []);
        setTotalRecords(data.totalRecords || 0);
        setError(null);
      } catch (err) {
        setError(err.message || 'Failed to fetch GPS logs data');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const accuracyData = Array.isArray(accuracy) 
    ? accuracy.slice(0, 7).map(item => ({
        time: item.time || item.hour || '00:00',
        accuracy: item.accuracy || item.value || 95
      }))
    : [];

  const anomalies = gpsLogs
    .filter(log => log.severity || log.issue)
    .slice(0, 3)
    .map((log, index) => ({
      id: log.id || index + 1,
      vehicle: log.vehicle || log.vehicle_id || 'Unknown',
      location: log.location || 'Unknown',
      issue: log.issue || log.event_type || 'Unknown',
      severity: log.severity || 'Low',
      time: log.time || log.timestamp || 'N/A'
    }));

  const problematicRegions = gpsLogs
    .filter(log => log.region || log.area)
    .slice(0, 4)
    .map(log => ({
      region: log.region || log.area || 'Unknown',
      incidents: log.incidents || log.count || 0,
      avgAccuracy: log.avgAccuracy || log.accuracy || 90,
      status: log.status || 'Normal'
    }));

  const getSeverityColor = (severity) => {
    switch(severity) {
      case 'High': return 'text-red-500';
      case 'Medium': return 'text-yellow-500';
      case 'Low': return 'text-blue-500';
      default: return 'text-gray-500';
    }
  };

  const getStatusColor = (status) => {
    switch(status) {
      case 'Critical': return 'bg-red-100 text-red-800';
      case 'Warning': return 'bg-yellow-100 text-yellow-800';
      case 'Monitor': return 'bg-blue-100 text-blue-800';
      case 'Normal': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading GPS logs...</p>
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
        <h2 className="text-2xl font-bold text-gray-900">Location Accuracy & GPS Logs</h2>
        <p className="text-gray-600 mt-1">GPS anomaly logs, accuracy trends, and problematic regions</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Avg Accuracy</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">94.5%</p>
            </div>
            <Navigation className="text-green-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Active Vehicles</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">342</p>
            </div>
            <MapPin className="text-blue-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Anomalies Today</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{anomalies.length}</p>
            </div>
            <AlertTriangle className="text-yellow-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Problematic Zones</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{problematicRegions.length}</p>
            </div>
            <TrendingUp className="text-red-500" size={32} />
          </div>
        </div>
      </div>

      {/* Accuracy Trend */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">GPS Accuracy Trend (24h)</h3>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={accuracyData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="time" />
            <YAxis domain={[90, 100]} label={{ value: 'Accuracy %', angle: -90, position: 'insideLeft' }} />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="accuracy" stroke="#10b981" strokeWidth={2} name="GPS Accuracy" />
          </LineChart>
        </ResponsiveContainer>
      </div>

      {/* Anomalies and Problematic Regions */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* GPS Anomaly Logs */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">GPS Anomaly Logs</h3>
          <div className="space-y-3">
            {anomalies.map((anomaly) => (
              <div key={anomaly.id} className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-start justify-between mb-2">
                  <div className="flex items-center">
                    <AlertTriangle className={`${getSeverityColor(anomaly.severity)} mr-2`} size={20} />
                    <div>
                      <h4 className="font-semibold text-gray-900">{anomaly.vehicle}</h4>
                      <p className="text-sm text-gray-600">{anomaly.location}</p>
                    </div>
                  </div>
                  <span className="text-xs text-gray-500">{anomaly.time}</span>
                </div>
                <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-100">
                  <span className="text-sm text-gray-700">{anomaly.issue}</span>
                  <span className={`text-xs px-2 py-1 rounded-full font-medium ${
                    anomaly.severity === 'High' ? 'bg-red-100 text-red-800' :
                    anomaly.severity === 'Medium' ? 'bg-yellow-100 text-yellow-800' :
                    'bg-blue-100 text-blue-800'
                  }`}>
                    {anomaly.severity}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Problematic Regions */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Problematic Regions</h3>
          <div className="space-y-3">
            {problematicRegions.map((region, index) => (
              <div key={index} className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-center justify-between mb-3">
                  <h4 className="font-semibold text-gray-900">{region.region}</h4>
                  <span className={`text-xs px-2 py-1 rounded-full font-medium ${getStatusColor(region.status)}`}>
                    {region.status}
                  </span>
                </div>
                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <p className="text-gray-600">Incidents</p>
                    <p className="font-semibold text-gray-900">{region.incidents}</p>
                  </div>
                  <div>
                    <p className="text-gray-600">Avg Accuracy</p>
                    <p className="font-semibold text-gray-900">{region.avgAccuracy}%</p>
                  </div>
                </div>
                <div className="mt-3">
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className={`h-2 rounded-full ${
                        region.avgAccuracy >= 85 ? 'bg-green-500' :
                        region.avgAccuracy >= 75 ? 'bg-yellow-500' : 'bg-red-500'
                      }`}
                      style={{ width: `${region.avgAccuracy}%` }}
                    ></div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Detailed Logs */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent GPS Events</h3>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-200">
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Time</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Vehicle</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Event</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Location</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Accuracy</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Status</th>
              </tr>
            </thead>
            <tbody>
              {[
                { time: '14:35:22', vehicle: 'V-1234', event: 'Signal Loss', location: 'Highway 101', accuracy: '0%', status: 'Resolved' },
                { time: '14:28:15', vehicle: 'V-5678', event: 'Low Accuracy', location: 'Downtown', accuracy: '75%', status: 'Monitoring' },
                { time: '14:15:48', vehicle: 'V-9012', event: 'GPS Drift', location: 'Mountain Rd', accuracy: '82%', status: 'Normal' },
                { time: '13:52:33', vehicle: 'V-3456', event: 'Connection Lost', location: 'Tunnel Exit', accuracy: '0%', status: 'Resolved' },
              ].map((log, index) => (
                <tr key={index} className="border-b border-gray-100 hover:bg-gray-50">
                  <td className="py-4 px-4 text-gray-600">{log.time}</td>
                  <td className="py-4 px-4 font-medium text-gray-900">{log.vehicle}</td>
                  <td className="py-4 px-4 text-gray-700">{log.event}</td>
                  <td className="py-4 px-4 text-gray-600">{log.location}</td>
                  <td className="py-4 px-4 font-semibold text-gray-900">{log.accuracy}</td>
                  <td className="py-4 px-4">
                    <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                      log.status === 'Resolved' ? 'bg-green-100 text-green-800' :
                      log.status === 'Monitoring' ? 'bg-yellow-100 text-yellow-800' :
                      'bg-blue-100 text-blue-800'
                    }`}>
                      {log.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default GPSLogs;
