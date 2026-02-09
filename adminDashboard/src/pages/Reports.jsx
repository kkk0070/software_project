import { useState, useEffect } from 'react';
import { FileText, Download, Calendar, Filter } from 'lucide-react';
import { reportsAPI } from '../services/api';

const Reports = () => {
  const [operationalReports, setOperationalReports] = useState([]);
  const [sustainabilityReports, setSustainabilityReports] = useState([]);
  const [scheduledReports, setScheduledReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        
        // Fetch operational and sustainability reports
        const [operationalRes, sustainabilityRes, scheduledRes] = await Promise.all([
          reportsAPI.getRecent('operational'),
          reportsAPI.getRecent('sustainability'),
          reportsAPI.getScheduled()
        ]);
        
        setOperationalReports(operationalRes.data || []);
        setSustainabilityReports(sustainabilityRes.data || []);
        setScheduledReports(scheduledRes.data || []);
        
        setError(null);
      } catch (err) {
        setError(err.message);
        console.error('Error fetching reports data:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const reportTypes = [
    { name: 'Operational Report', description: 'Daily operations, rides, and driver performance', icon: '📊' },
    { name: 'Sustainability Report', description: 'Carbon savings, EV usage, and eco metrics', icon: '🌱' },
    { name: 'Financial Report', description: 'Revenue, costs, and financial analytics', icon: '💰' },
    { name: 'User Analytics', description: 'User behavior, retention, and engagement', icon: '👥' },
    { name: 'Safety Report', description: 'SOS incidents, response times, and safety metrics', icon: '🛡️' },
    { name: 'System Performance', description: 'API health, uptime, and technical metrics', icon: '⚙️' },
  ];

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Loading reports data...</div>
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

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">Reports & Export</h2>
            <p className="text-gray-600 mt-1">Generate and download operational and sustainability reports</p>
          </div>
          <button className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition-colors flex items-center">
            <FileText size={20} className="mr-2" />
            Generate Report
          </button>
        </div>
      </div>

      {/* Report Generation */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Generate New Report</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {reportTypes.map((type, index) => (
            <div key={index} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow cursor-pointer">
              <div className="text-3xl mb-3">{type.icon}</div>
              <h4 className="font-semibold text-gray-900 mb-2">{type.name}</h4>
              <p className="text-sm text-gray-600 mb-4">{type.description}</p>
              <button className="w-full bg-gray-100 text-gray-700 py-2 rounded-lg hover:bg-gray-200 transition-colors text-sm font-medium">
                Generate
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* Custom Report Builder */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Custom Report Builder</h3>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Report Name</label>
              <input
                type="text"
                placeholder="My Custom Report"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Date Range</label>
              <div className="flex space-x-2">
                <input
                  type="date"
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                />
                <span className="flex items-center px-2">to</span>
                <input
                  type="date"
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Export Format</label>
              <div className="grid grid-cols-3 gap-2">
                <button className="px-4 py-2 border-2 border-green-500 bg-green-50 text-green-700 rounded-lg font-medium">
                  PDF
                </button>
                <button className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50">
                  CSV
                </button>
                <button className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50">
                  Excel
                </button>
              </div>
            </div>
          </div>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Include Metrics</label>
              <div className="space-y-2 max-h-48 overflow-y-auto">
                {['Ride Statistics', 'User Analytics', 'Driver Performance', 'Carbon Savings', 'Revenue Data', 'Safety Metrics', 'System Performance'].map((metric, index) => (
                  <label key={index} className="flex items-center p-2 hover:bg-gray-50 rounded cursor-pointer">
                    <input type="checkbox" defaultChecked className="rounded border-gray-300 text-green-500 focus:ring-green-500 mr-3" />
                    <span className="text-sm text-gray-700">{metric}</span>
                  </label>
                ))}
              </div>
            </div>
            <button className="w-full bg-green-600 text-white py-3 rounded-lg hover:bg-green-700 transition-colors font-semibold flex items-center justify-center">
              <Download size={20} className="mr-2" />
              Generate & Download
            </button>
          </div>
        </div>
      </div>

      {/* Recent Reports */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Operational Reports */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Operational Reports</h3>
          <div className="space-y-3">
            {operationalReports.map((report) => (
              <div key={report.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:shadow-md transition-shadow">
                <div className="flex items-center flex-1">
                  <FileText className="text-blue-500 mr-3" size={24} />
                  <div>
                    <h4 className="font-semibold text-gray-900">{report.name}</h4>
                    <p className="text-sm text-gray-600">{report.date} • {report.size}</p>
                  </div>
                </div>
                <div className="flex items-center space-x-2">
                  <span className="text-xs px-2 py-1 bg-blue-100 text-blue-800 rounded font-medium">
                    {report.format}
                  </span>
                  <button className="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors">
                    <Download size={20} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Sustainability Reports */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Sustainability Reports</h3>
          <div className="space-y-3">
            {sustainabilityReports.map((report) => (
              <div key={report.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:shadow-md transition-shadow">
                <div className="flex items-center flex-1">
                  <FileText className="text-green-500 mr-3" size={24} />
                  <div>
                    <h4 className="font-semibold text-gray-900">{report.name}</h4>
                    <p className="text-sm text-gray-600">{report.date} • {report.size}</p>
                  </div>
                </div>
                <div className="flex items-center space-x-2">
                  <span className="text-xs px-2 py-1 bg-green-100 text-green-800 rounded font-medium">
                    {report.format}
                  </span>
                  <button className="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors">
                    <Download size={20} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Scheduled Reports */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Automated Report Schedule</h3>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-200">
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Report Type</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Frequency</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Next Generation</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Recipients</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Status</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Actions</th>
              </tr>
            </thead>
            <tbody>
              {scheduledReports.map((schedule) => (
                <tr key={schedule.id} className="border-b border-gray-100 hover:bg-gray-50">
                  <td className="py-4 px-4 font-medium text-gray-900">{schedule.type}</td>
                  <td className="py-4 px-4 text-gray-600">{schedule.frequency}</td>
                  <td className="py-4 px-4 text-gray-600">{schedule.next}</td>
                  <td className="py-4 px-4 text-gray-600">{schedule.recipients}</td>
                  <td className="py-4 px-4">
                    <span className="px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                      {schedule.status}
                    </span>
                  </td>
                  <td className="py-4 px-4">
                    <div className="flex space-x-2">
                      <button className="text-blue-600 hover:text-blue-800 text-sm font-medium">
                        Edit
                      </button>
                      <button className="text-red-600 hover:text-red-800 text-sm font-medium">
                        Disable
                      </button>
                    </div>
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

export default Reports;
