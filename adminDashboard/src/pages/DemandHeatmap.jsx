import { useState, useEffect } from 'react';
import { TrendingUp, MapPin, AlertCircle } from 'lucide-react';
import { analyticsAPI } from '../services/api';

const DemandHeatmap = () => {
  const [demandAreas, setDemandAreas] = useState([]);
  const [peakTimes, setPeakTimes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const data = await analyticsAPI.getDemandHeatmap();
        setDemandAreas(data.demandAreas || []);
        setPeakTimes(data.peakTimes || []);
        setError(null);
      } catch (err) {
        setError(err.message || 'Failed to fetch demand heatmap data');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const underservedAreas = demandAreas
    .filter(area => area.gap || area.service_gap || area.demand === 'Low')
    .slice(0, 3)
    .map(area => ({
      area: area.area || area.name || 'Unknown',
      gap: area.gap || area.service_gap || 'Medium',
      waitTime: area.waitTime || area.wait_time || area.avg_wait_time || '0 min',
      coverage: area.coverage || area.coverage_percent || '0%'
    }));
  
  if (underservedAreas.length === 0) {
    underservedAreas.push(
      { area: 'No underserved areas', gap: 'Low', waitTime: '0 min', coverage: '100%' }
    );
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading demand heatmap...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-6">
        <div className="flex items-center">
          <AlertCircle className="text-red-500 mr-3" size={24} />
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
        <h2 className="text-2xl font-bold text-gray-900">Demand & Heatmap Analytics</h2>
        <p className="text-gray-600 mt-1">Area-wise demand analysis and underserved region identification</p>
      </div>

      {/* Heatmap Visualization */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Area Demand Heatmap</h3>
        <div className="bg-gradient-to-br from-green-100 via-yellow-100 to-red-100 rounded-lg h-96 flex items-center justify-center relative">
          <div className="text-center">
            <MapPin className="text-gray-700 mx-auto mb-2" size={48} />
            <p className="text-gray-700 font-medium">Interactive Heatmap View</p>
            <p className="text-sm text-gray-600 mt-2">Real-time demand distribution across city zones</p>
          </div>
          {/* Legend */}
          <div className="absolute bottom-4 right-4 bg-white p-4 rounded-lg shadow-md">
            <p className="text-xs font-semibold text-gray-700 mb-2">Demand Level</p>
            <div className="space-y-1">
              <div className="flex items-center">
                <div className="w-4 h-4 bg-red-500 rounded mr-2"></div>
                <span className="text-xs text-gray-600">High</span>
              </div>
              <div className="flex items-center">
                <div className="w-4 h-4 bg-yellow-500 rounded mr-2"></div>
                <span className="text-xs text-gray-600">Medium</span>
              </div>
              <div className="flex items-center">
                <div className="w-4 h-4 bg-green-500 rounded mr-2"></div>
                <span className="text-xs text-gray-600">Low</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Demand by Area */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Area-wise Demand</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {demandAreas.map((area, index) => (
            <div key={index} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
              <div className="flex items-center justify-between mb-3">
                <h4 className="font-semibold text-gray-900">{area.area}</h4>
                <TrendingUp className={area.color} size={20} />
              </div>
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Demand Level</span>
                  <span className={`font-semibold ${area.color}`}>{area.demand}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Total Rides</span>
                  <span className="font-medium text-gray-900">{area.rides}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Change</span>
                  <span className={`font-medium ${area.change.startsWith('+') ? 'text-green-600' : 'text-red-600'}`}>
                    {area.change}
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Peak Times and Underserved Areas */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Peak Demand Detection */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Peak Demand Times</h3>
          <div className="space-y-3">
            {peakTimes.map((peak, index) => (
              <div key={index} className="p-4 border border-gray-200 rounded-lg">
                <div className="flex items-center justify-between mb-2">
                  <span className="font-semibold text-gray-900">{peak.time}</span>
                  <span className="text-sm text-gray-600">{peak.period}</span>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex-1">
                    <div className="w-full bg-gray-200 rounded-full h-3">
                      <div 
                        className="bg-gradient-to-r from-green-500 to-red-500 h-3 rounded-full" 
                        style={{ width: `${peak.demand}%` }}
                      ></div>
                    </div>
                  </div>
                  <span className="ml-3 text-sm font-semibold text-gray-900">{peak.demand}%</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Underserved Areas */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Underserved Areas</h3>
          <div className="space-y-3">
            {underservedAreas.map((area, index) => (
              <div key={index} className="p-4 border border-gray-200 rounded-lg bg-yellow-50">
                <div className="flex items-start">
                  <AlertCircle className="text-yellow-600 mr-3 flex-shrink-0 mt-1" size={20} />
                  <div className="flex-1">
                    <h4 className="font-semibold text-gray-900 mb-2">{area.area}</h4>
                    <div className="grid grid-cols-3 gap-2 text-sm">
                      <div>
                        <p className="text-gray-600">Service Gap</p>
                        <p className={`font-semibold ${
                          area.gap === 'High' ? 'text-red-600' :
                          area.gap === 'Medium' ? 'text-yellow-600' : 'text-green-600'
                        }`}>{area.gap}</p>
                      </div>
                      <div>
                        <p className="text-gray-600">Avg Wait</p>
                        <p className="font-semibold text-gray-900">{area.waitTime}</p>
                      </div>
                      <div>
                        <p className="text-gray-600">Coverage</p>
                        <p className="font-semibold text-gray-900">{area.coverage}</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Recommendations */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">AI Recommendations</h3>
        <div className="space-y-3">
          <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <p className="text-sm text-blue-900">
              <strong>High Priority:</strong> Deploy 15 more drivers to Downtown area during evening rush (17:00-19:00) to reduce wait times by 35%.
            </p>
          </div>
          <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
            <p className="text-sm text-green-900">
              <strong>Opportunity:</strong> Shopping Mall area shows consistent demand increase. Consider driver incentives for this zone.
            </p>
          </div>
          <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
            <p className="text-sm text-yellow-900">
              <strong>Alert:</strong> Suburban East requires immediate attention - average wait time exceeds service standards by 40%.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DemandHeatmap;
