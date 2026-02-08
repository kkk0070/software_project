import { useState, useEffect } from 'react';
import { MapPin, Clock, User, Navigation as NavIcon, AlertTriangle } from 'lucide-react';
import { monitoringAPI } from '../services/api';

const LiveRideMonitoring = () => {
  const [monitoringData, setMonitoringData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchMonitoringData();
    // Refresh every 30 seconds
    const interval = setInterval(fetchMonitoringData, 30000);
    return () => clearInterval(interval);
  }, []);

  const fetchMonitoringData = async () => {
    try {
      setLoading(true);
      const response = await monitoringAPI.getLiveRides();
      if (response.success) {
        setMonitoringData(response.data);
      }
    } catch (err) {
      console.error('Error fetching monitoring data:', err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading && !monitoringData) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Loading ride monitoring data...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
        Error loading data: {error}
      </div>
    );
  }

  const activeRides = monitoringData?.activeRides || [];
  const incidents = monitoringData?.recentIncidents || [];
  const fleetStats = monitoringData?.fleetStats || [];

  const getStatusColor = (status) => {
    switch(status) {
      case 'In Progress': return 'bg-blue-100 text-blue-800';
      case 'Pickup': return 'bg-yellow-100 text-yellow-800';
      case 'Dropoff': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getSeverityColor = (severity) => {
    switch(severity) {
      case 'high': return 'text-red-500';
      case 'medium': return 'text-yellow-500';
      case 'low': return 'text-blue-500';
      default: return 'text-gray-500';
    }
  };

  return (
    <div className="space-y-6">
      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Active Rides</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{activeRides.length}</p>
            </div>
            <MapPin className="text-green-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Available Drivers</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">
                {fleetStats.reduce((sum, stat) => sum + (stat.available || 0), 0)}
              </p>
            </div>
            <User className="text-blue-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Avg Duration</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">
                {activeRides.length > 0 
                  ? Math.round(activeRides.reduce((sum, r) => sum + (r.duration || 0), 0) / activeRides.length) 
                  : 0} min
              </p>
            </div>
            <Clock className="text-purple-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Incidents</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{incidents.length}</p>
            </div>
            <AlertTriangle className="text-red-500" size={32} />
          </div>
        </div>
      </div>

      {/* Map Placeholder and Active Rides */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Map */}
        <div className="lg:col-span-2 bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Real-Time Ride Map</h3>
          <div className="bg-gray-100 rounded-lg h-96 flex items-center justify-center">
            <div className="text-center">
              <MapPin className="text-gray-400 mx-auto mb-2" size={48} />
              <p className="text-gray-500">Interactive map showing live ride locations</p>
              <p className="text-sm text-gray-400 mt-2">Real-time vehicle tracking with dynamic updates</p>
            </div>
          </div>
        </div>

        {/* Active Rides List */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Active Rides</h3>
          <div className="space-y-3 max-h-96 overflow-y-auto">
            {activeRides.map((ride) => (
              <div key={ride.id} className="p-4 border border-gray-200 rounded-lg hover:shadow-md transition-shadow">
                <div className="flex items-center justify-between mb-2">
                  <span className="font-semibold text-gray-900">#{ride.id}</span>
                  <span className={`text-xs px-2 py-1 rounded-full ${getStatusColor(ride.status)}`}>
                    {ride.status}
                  </span>
                </div>
                <div className="space-y-1 text-sm">
                  <p className="text-gray-600">
                    <span className="font-medium">Driver:</span> {ride.driver_name || 'N/A'}
                  </p>
                  <p className="text-gray-600">
                    <span className="font-medium">Rider:</span> {ride.rider_name || 'N/A'}
                  </p>
                  <p className="text-gray-600 flex items-center">
                    <MapPin size={14} className="mr-1 text-green-500" />
                    {ride.pickup_location}
                  </p>
                  <p className="text-gray-600 flex items-center">
                    <NavIcon size={14} className="mr-1 text-red-500" />
                    {ride.dropoff_location}
                  </p>
                  <div className="flex justify-between mt-2 pt-2 border-t border-gray-100">
                    <span className="text-blue-600 font-medium">{ride.vehicle_type || 'Vehicle'}</span>
                    <span className="text-gray-500">{ride.distance ? `${ride.distance} km` : 'N/A'}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Fleet Distribution and Incidents */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Fleet Distribution */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Fleet Distribution</h3>
          <div className="space-y-4">
            {fleetStats.map((fleet) => (
              <div key={fleet.vehicle_type} className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-center justify-between mb-3">
                  <h4 className="font-semibold text-gray-900">{fleet.vehicle_type} Vehicles</h4>
                  <span className="text-lg font-bold text-gray-900">{fleet.total || 0}</span>
                </div>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-600">Available</span>
                    <span className="font-medium text-green-600">{fleet.available || 0}</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className="bg-green-500 h-2 rounded-full" 
                      style={{ width: `${fleet.total > 0 ? ((fleet.available || 0) / fleet.total) * 100 : 0}%` }}
                    ></div>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-600">Active</span>
                    <span className="font-medium text-blue-600">{(fleet.total || 0) - (fleet.available || 0)}</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className="bg-blue-500 h-2 rounded-full" 
                      style={{ width: `${fleet.total > 0 ? (((fleet.total || 0) - (fleet.available || 0)) / fleet.total) * 100 : 0}%` }}
                    ></div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Incidents */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Incident Tracking</h3>
          <div className="space-y-3">
            {incidents.map((incident) => (
              <div key={incident.id} className="flex items-start p-4 border border-gray-200 rounded-lg">
                <AlertTriangle className={`${getSeverityColor(incident.priority?.toLowerCase() || 'low')} mr-3 flex-shrink-0`} size={20} />
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-1">
                    <h4 className="font-semibold text-gray-900">{incident.incident_type}</h4>
                    <span className="text-xs text-gray-500">
                      {incident.created_at ? new Date(incident.created_at).toLocaleString() : 'N/A'}
                    </span>
                  </div>
                  <p className="text-sm text-gray-600">{incident.location || 'Location not specified'}</p>
                  <span className={`text-xs px-2 py-1 rounded-full inline-block mt-2 ${
                    incident.priority === 'Critical' || incident.priority === 'High' ? 'bg-red-100 text-red-800' :
                    incident.priority === 'Medium' ? 'bg-yellow-100 text-yellow-800' :
                    'bg-blue-100 text-blue-800'
                  }`}>
                    {(incident.priority || 'LOW').toUpperCase()}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default LiveRideMonitoring;
