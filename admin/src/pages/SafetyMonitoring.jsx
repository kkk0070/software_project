import { useState, useEffect } from 'react';
import { Shield, AlertTriangle, MapPin, Clock, CheckCircle } from 'lucide-react';
import { monitoringAPI } from '../services/api';

const SafetyMonitoring = () => {
  const [sosIncidents, setSosIncidents] = useState([]);
  const [emergencyStats, setEmergencyStats] = useState([]);
  const [recentResolutions, setRecentResolutions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const data = await monitoringAPI.getSafety();
        setSosIncidents(data.sosIncidents || []);
        setEmergencyStats(data.emergencyStats || []);
        setRecentResolutions(data.recentResolutions || []);
        setError(null);
      } catch (err) {
        setError(err.message || 'Failed to fetch safety data');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const getStatusColor = (status) => {
    switch(status) {
      case 'Active': return 'bg-red-100 text-red-800 border-red-300';
      case 'Responding': return 'bg-yellow-100 text-yellow-800 border-yellow-300';
      case 'Resolved': return 'bg-green-100 text-green-800 border-green-300';
      default: return 'bg-gray-100 text-gray-800 border-gray-300';
    }
  };

  const getSeverityColor = (severity) => {
    switch(severity) {
      case 'High': return 'text-red-500';
      case 'Medium': return 'text-yellow-500';
      case 'Low': return 'text-blue-500';
      default: return 'text-gray-500';
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading safety data...</p>
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
        <h2 className="text-2xl font-bold text-gray-900">Safety & Emergency Monitoring</h2>
        <p className="text-gray-600 mt-1">Real-time SOS incident tracking and emergency response</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        {emergencyStats.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <div key={index} className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-gray-600 text-sm">{stat.label}</p>
                  <p className={`text-3xl font-bold mt-1 ${stat.color}`}>{stat.value}</p>
                </div>
                <Icon className={stat.color} size={32} />
              </div>
            </div>
          );
        })}
      </div>

      {/* Active Incidents and Map */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* SOS Incident Dashboard */}
        <div className="lg:col-span-1 bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Active SOS Incidents</h3>
          <div className="space-y-3">
            {sosIncidents.filter(incident => incident.status !== 'Resolved').map((incident) => (
              <div key={incident.id} className={`border-2 rounded-lg p-4 ${getStatusColor(incident.status)}`}>
                <div className="flex items-start justify-between mb-2">
                  <div>
                    <h4 className="font-semibold text-gray-900">{incident.id}</h4>
                    <p className="text-sm text-gray-700">{incident.user}</p>
                  </div>
                  <AlertTriangle className={getSeverityColor(incident.severity)} size={20} />
                </div>
                <div className="space-y-2 text-sm">
                  <div className="flex items-start">
                    <MapPin size={16} className="mr-2 text-gray-600 flex-shrink-0 mt-0.5" />
                    <span className="text-gray-700">{incident.location}</span>
                  </div>
                  <div className="flex items-center justify-between pt-2 border-t border-gray-200">
                    <span className="text-gray-600">{incident.time}</span>
                    <span className="text-gray-600">{incident.responders} responder(s)</span>
                  </div>
                </div>
                <button className="w-full mt-3 bg-gray-900 text-white py-2 rounded-lg hover:bg-gray-800 transition-colors text-sm font-medium">
                  View Details
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Live Emergency Location Map */}
        <div className="lg:col-span-2 bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Live Emergency Locations</h3>
          <div className="bg-gradient-to-br from-red-50 to-orange-50 rounded-lg h-96 flex items-center justify-center relative">
            <div className="text-center">
              <MapPin className="text-red-500 mx-auto mb-2" size={48} />
              <p className="text-gray-700 font-medium">Real-time Emergency Map</p>
              <p className="text-sm text-gray-600 mt-2">Live tracking of active SOS incidents</p>
            </div>
            {/* Active incident markers simulation */}
            <div className="absolute top-1/4 left-1/4 w-4 h-4 bg-red-500 rounded-full animate-ping"></div>
            <div className="absolute top-1/4 left-1/4 w-4 h-4 bg-red-500 rounded-full"></div>
            <div className="absolute top-1/3 right-1/3 w-4 h-4 bg-yellow-500 rounded-full animate-ping"></div>
            <div className="absolute top-1/3 right-1/3 w-4 h-4 bg-yellow-500 rounded-full"></div>
          </div>
          <div className="mt-4 grid grid-cols-3 gap-4">
            <div className="bg-red-50 border border-red-200 rounded-lg p-3 text-center">
              <div className="flex items-center justify-center mb-1">
                <div className="w-3 h-3 bg-red-500 rounded-full mr-2"></div>
                <span className="text-sm font-semibold text-red-800">Active</span>
              </div>
              <p className="text-xs text-red-700">Requires immediate attention</p>
            </div>
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-3 text-center">
              <div className="flex items-center justify-center mb-1">
                <div className="w-3 h-3 bg-yellow-500 rounded-full mr-2"></div>
                <span className="text-sm font-semibold text-yellow-800">Responding</span>
              </div>
              <p className="text-xs text-yellow-700">Help is on the way</p>
            </div>
            <div className="bg-green-50 border border-green-200 rounded-lg p-3 text-center">
              <div className="flex items-center justify-center mb-1">
                <div className="w-3 h-3 bg-green-500 rounded-full mr-2"></div>
                <span className="text-sm font-semibold text-green-800">Resolved</span>
              </div>
              <p className="text-xs text-green-700">Safely resolved</p>
            </div>
          </div>
        </div>
      </div>

      {/* Resolution Tracking */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Resolutions</h3>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-200">
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Incident ID</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">User</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Issue</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Resolution</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Time</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Status</th>
              </tr>
            </thead>
            <tbody>
              {recentResolutions.map((resolution) => (
                <tr key={resolution.id} className="border-b border-gray-100 hover:bg-gray-50">
                  <td className="py-4 px-4 font-medium text-gray-900">{resolution.id}</td>
                  <td className="py-4 px-4 text-gray-700">{resolution.user}</td>
                  <td className="py-4 px-4 text-gray-600">{resolution.issue}</td>
                  <td className="py-4 px-4 text-gray-700">{resolution.resolution}</td>
                  <td className="py-4 px-4 text-gray-600">{resolution.time}</td>
                  <td className="py-4 px-4">
                    <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                      <CheckCircle size={16} className="mr-1" />
                      Resolved
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Safety Metrics */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Response Performance */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Response Performance</h3>
          <div className="space-y-4">
            <div>
              <div className="flex justify-between mb-2">
                <span className="text-sm text-gray-600">Avg Response Time</span>
                <span className="text-sm font-semibold text-gray-900">3.2 minutes</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3">
                <div className="bg-green-500 h-3 rounded-full" style={{ width: '95%' }}></div>
              </div>
              <p className="text-xs text-green-600 mt-1">Excellent - Under 5 min target</p>
            </div>
            <div>
              <div className="flex justify-between mb-2">
                <span className="text-sm text-gray-600">Resolution Rate</span>
                <span className="text-sm font-semibold text-gray-900">98.5%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3">
                <div className="bg-blue-500 h-3 rounded-full" style={{ width: '98.5%' }}></div>
              </div>
              <p className="text-xs text-blue-600 mt-1">Above target of 95%</p>
            </div>
            <div>
              <div className="flex justify-between mb-2">
                <span className="text-sm text-gray-600">User Satisfaction</span>
                <span className="text-sm font-semibold text-gray-900">4.8/5.0</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3">
                <div className="bg-purple-500 h-3 rounded-full" style={{ width: '96%' }}></div>
              </div>
              <p className="text-xs text-purple-600 mt-1">High satisfaction rating</p>
            </div>
          </div>
        </div>

        {/* Safety Insights */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Safety Insights</h3>
          <div className="space-y-3">
            <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
              <div className="flex items-start">
                <CheckCircle className="text-green-600 mr-3 flex-shrink-0 mt-1" size={20} />
                <div>
                  <h4 className="font-semibold text-green-900 mb-1">Improved Response</h4>
                  <p className="text-sm text-green-700">
                    Response time decreased by 25% this month through optimized dispatch
                  </p>
                </div>
              </div>
            </div>
            <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
              <div className="flex items-start">
                <Shield className="text-blue-600 mr-3 flex-shrink-0 mt-1" size={20} />
                <div>
                  <h4 className="font-semibold text-blue-900 mb-1">Safety Features Usage</h4>
                  <p className="text-sm text-blue-700">
                    89% of users have enabled location sharing for safety
                  </p>
                </div>
              </div>
            </div>
            <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
              <div className="flex items-start">
                <AlertTriangle className="text-yellow-600 mr-3 flex-shrink-0 mt-1" size={20} />
                <div>
                  <h4 className="font-semibold text-yellow-900 mb-1">Alert</h4>
                  <p className="text-sm text-yellow-700">
                    Slightly higher SOS triggers in Downtown area - increased monitoring recommended
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SafetyMonitoring;
