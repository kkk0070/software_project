import { useState, useEffect } from 'react';
import { Bell, Send, Calendar, Target, CheckCircle, Clock } from 'lucide-react';
import { notificationAPI } from '../services/api';

const Notifications = () => {
  const [selectedType, setSelectedType] = useState('all');
  const [data, setData] = useState(null);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const [notificationsRes, statsRes] = await Promise.all([
          notificationAPI.getAll(),
          notificationAPI.getStats()
        ]);
        setData(notificationsRes.data || []);
        setStats(statsRes.data || {});
        setError(null);
      } catch (err) {
        setError(err.message);
        console.error('Error fetching notifications data:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Loading notifications data...</div>
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

  const campaigns = data.filter(n => n.type === 'campaign') || [];
  const scheduledNotifications = data.filter(n => n.status === 'scheduled') || [];
  const recentNotifications = data.filter(n => n.type !== 'campaign' && n.status !== 'scheduled').slice(0, 3) || [];

  const getStatusColor = (status) => {
    switch(status) {
      case 'Active': return 'bg-green-100 text-green-800';
      case 'Scheduled': return 'bg-blue-100 text-blue-800';
      case 'Completed': return 'bg-gray-100 text-gray-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">Notifications & Campaign Management</h2>
            <p className="text-gray-600 mt-1">Manage push notifications, campaigns, and alerts</p>
          </div>
          <button className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition-colors flex items-center">
            <Send size={20} className="mr-2" />
            Create Campaign
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Total Sent</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{(stats.total_notifications / 1000).toFixed(1)}K</p>
            </div>
            <Send className="text-blue-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Open Rate</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.open_rate || 72}%</p>
            </div>
            <Bell className="text-green-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Click Rate</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.click_rate || 54}%</p>
            </div>
            <Target className="text-purple-500" size={32} />
          </div>
        </div>
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Active Campaigns</p>
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.active_campaigns || campaigns.filter(c => c.status === 'Active').length}</p>
            </div>
            <Calendar className="text-orange-500" size={32} />
          </div>
        </div>
      </div>

      {/* Campaigns */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Sustainability Campaigns</h3>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-200">
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Campaign</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Type</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Status</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Sent</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Opened</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Clicks</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Actions</th>
              </tr>
            </thead>
            <tbody>
              {campaigns.map((campaign) => (
                <tr key={campaign.id} className="border-b border-gray-100 hover:bg-gray-50">
                  <td className="py-4 px-4 font-medium text-gray-900">{campaign.name}</td>
                  <td className="py-4 px-4">
                    <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
                      {campaign.type}
                    </span>
                  </td>
                  <td className="py-4 px-4">
                    <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(campaign.status)}`}>
                      {campaign.status}
                    </span>
                  </td>
                  <td className="py-4 px-4 text-gray-600">{campaign.sent.toLocaleString()}</td>
                  <td className="py-4 px-4">
                    <div className="flex items-center">
                      <span className="text-gray-900 font-medium mr-2">{campaign.opened.toLocaleString()}</span>
                      {campaign.sent > 0 && (
                        <span className="text-sm text-green-600">
                          ({Math.round((campaign.opened / campaign.sent) * 100)}%)
                        </span>
                      )}
                    </div>
                  </td>
                  <td className="py-4 px-4">
                    <div className="flex items-center">
                      <span className="text-gray-900 font-medium mr-2">{campaign.clicks.toLocaleString()}</span>
                      {campaign.sent > 0 && (
                        <span className="text-sm text-blue-600">
                          ({Math.round((campaign.clicks / campaign.sent) * 100)}%)
                        </span>
                      )}
                    </div>
                  </td>
                  <td className="py-4 px-4">
                    <div className="flex space-x-2">
                      <button className="text-blue-600 hover:text-blue-800 text-sm font-medium">
                        View
                      </button>
                      <button className="text-gray-600 hover:text-gray-800 text-sm font-medium">
                        Edit
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Scheduled Notifications and Recent */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Alert Scheduling */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Scheduled Alerts</h3>
          <div className="space-y-3">
            {scheduledNotifications.map((notification) => (
              <div key={notification.id} className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-start justify-between mb-2">
                  <div className="flex-1">
                    <h4 className="font-semibold text-gray-900">{notification.title}</h4>
                    <p className="text-sm text-gray-600 mt-1">Target: {notification.target}</p>
                  </div>
                  <span className="text-xs px-2 py-1 rounded-full bg-blue-100 text-blue-800 font-medium">
                    {notification.type}
                  </span>
                </div>
                <div className="flex items-center text-sm text-gray-600 mt-3 pt-3 border-t border-gray-100">
                  <Clock size={16} className="mr-2" />
                  <span>{notification.schedule}</span>
                </div>
                <div className="flex space-x-2 mt-3">
                  <button className="flex-1 bg-gray-100 text-gray-700 py-2 rounded-lg hover:bg-gray-200 transition-colors text-sm font-medium">
                    Edit
                  </button>
                  <button className="flex-1 bg-red-100 text-red-700 py-2 rounded-lg hover:bg-red-200 transition-colors text-sm font-medium">
                    Cancel
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Notifications */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Notifications</h3>
          <div className="space-y-3">
            {recentNotifications.map((notification) => (
              <div key={notification.id} className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-start">
                  <Bell className="text-green-500 mr-3 flex-shrink-0 mt-1" size={20} />
                  <div className="flex-1">
                    <h4 className="font-semibold text-gray-900">{notification.title}</h4>
                    <p className="text-sm text-gray-600 mt-1">{notification.message}</p>
                    <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-100 text-sm">
                      <span className="text-gray-500">{notification.sent}</span>
                      <span className="text-gray-600">
                        <strong>{notification.recipients.toLocaleString()}</strong> recipients
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Push Notification Control */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Send Push Notification</h3>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Notification Title</label>
              <input
                type="text"
                placeholder="Enter notification title"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Message</label>
              <textarea
                placeholder="Enter notification message"
                rows={4}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              ></textarea>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Target Audience</label>
              <select className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500">
                <option>All Users</option>
                <option>Active Riders</option>
                <option>Active Drivers</option>
                <option>Eco-conscious Users</option>
                <option>Custom Segment</option>
              </select>
            </div>
          </div>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Campaign Type</label>
              <select className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500">
                <option>Sustainability</option>
                <option>Promotion</option>
                <option>Alert</option>
                <option>Information</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Schedule</label>
              <div className="flex space-x-2">
                <input
                  type="datetime-local"
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                />
                <button className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors">
                  Now
                </button>
              </div>
            </div>
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <h4 className="font-semibold text-blue-900 mb-2">Preview</h4>
              <div className="bg-white rounded-lg p-3 shadow-sm">
                <p className="font-semibold text-gray-900 text-sm">Notification Title</p>
                <p className="text-xs text-gray-600 mt-1">Your message will appear here...</p>
              </div>
            </div>
            <div className="flex space-x-3">
              <button className="flex-1 bg-green-600 text-white py-3 rounded-lg hover:bg-green-700 transition-colors font-semibold">
                Send Notification
              </button>
              <button className="px-6 bg-gray-100 text-gray-700 py-3 rounded-lg hover:bg-gray-200 transition-colors font-semibold">
                Save Draft
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Notifications;
