import { useState, useEffect } from 'react';
import { Search, Filter, CheckCircle, XCircle, AlertCircle, User, X, Mail, Phone, MapPin, Calendar, Star, Car } from 'lucide-react';
import { userAPI } from '../services/api';

const UserManagement = () => {
  const [activeTab, setActiveTab] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [showFilters, setShowFilters] = useState(false);
  const [filters, setFilters] = useState({
    status: 'all',
    verified: 'all',
    rating: 'all'
  });
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await userAPI.getAll();
      if (response.success) {
        setUsers(response.data.map(user => ({
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          location: user.location,
          role: user.role,
          status: user.status,
          rides: user.total_rides || 0,
          verified: user.verified,
          joinedDate: user.joined_date,
          rating: parseFloat(user.rating) || 0,
          vehicleType: user.vehicle_type,
          vehicleModel: user.vehicle_model,
          licensePlate: user.license_plate
        })));
      }
    } catch (err) {
      console.error('Error fetching users:', err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Loading users...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
        Error loading users: {error}
      </div>
    );
  }

  const filteredUsers = users.filter(user => {
    // Tab filter
    const tabMatch = activeTab === 'all' || user.role.toLowerCase() === activeTab;
    
    // Search filter
    const searchMatch = user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                       user.email.toLowerCase().includes(searchTerm.toLowerCase());
    
    // Status filter
    const statusMatch = filters.status === 'all' || user.status === filters.status;
    
    // Verified filter
    const verifiedMatch = filters.verified === 'all' || 
                          (filters.verified === 'verified' && user.verified) ||
                          (filters.verified === 'unverified' && !user.verified);
    
    // Rating filter (for drivers)
    let ratingMatch = true;
    if (filters.rating !== 'all' && user.role === 'Driver') {
      if (filters.rating === 'high' && user.rating < 4.5) ratingMatch = false;
      if (filters.rating === 'medium' && (user.rating < 3.5 || user.rating >= 4.5)) ratingMatch = false;
      if (filters.rating === 'low' && user.rating >= 3.5) ratingMatch = false;
    }
    
    return tabMatch && searchMatch && statusMatch && verifiedMatch && ratingMatch;
  });

  const getStatusColor = (status) => {
    switch(status) {
      case 'Active': return 'bg-green-100 text-green-800';
      case 'Suspended': return 'bg-red-100 text-red-800';
      case 'Pending': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="space-y-6">
      {/* User Profile Modal */}
      {selectedUser && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white dark:bg-gray-800 rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6 border-b border-gray-200 dark:border-gray-700 flex justify-between items-start">
              <div className="flex items-center gap-4">
                <div className="w-16 h-16 rounded-full bg-green-500 flex items-center justify-center text-white font-semibold text-2xl">
                  {selectedUser.name.charAt(0)}
                </div>
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 dark:text-white">{selectedUser.name}</h2>
                  <p className="text-gray-600 dark:text-gray-400">{selectedUser.role}</p>
                </div>
              </div>
              <button
                onClick={() => setSelectedUser(null)}
                className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-500 dark:text-gray-400"
              >
                <X size={24} />
              </button>
            </div>
            
            <div className="p-6 space-y-6">
              {/* Contact Information */}
              <div>
                <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Contact Information</h3>
                <div className="space-y-3">
                  <div className="flex items-center gap-3 text-gray-700 dark:text-gray-300">
                    <Mail className="text-green-600" size={20} />
                    <span>{selectedUser.email}</span>
                  </div>
                  <div className="flex items-center gap-3 text-gray-700 dark:text-gray-300">
                    <Phone className="text-green-600" size={20} />
                    <span>{selectedUser.phone}</span>
                  </div>
                  <div className="flex items-center gap-3 text-gray-700 dark:text-gray-300">
                    <MapPin className="text-green-600" size={20} />
                    <span>{selectedUser.location}</span>
                  </div>
                </div>
              </div>

              {/* Account Details */}
              <div>
                <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Account Details</h3>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="bg-gray-50 dark:bg-gray-700 p-4 rounded-lg">
                    <p className="text-sm text-gray-600 dark:text-gray-400">Status</p>
                    <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium mt-2 ${getStatusColor(selectedUser.status)}`}>
                      {selectedUser.status}
                    </span>
                  </div>
                  <div className="bg-gray-50 dark:bg-gray-700 p-4 rounded-lg">
                    <p className="text-sm text-gray-600 dark:text-gray-400">Verified</p>
                    <div className="mt-2">
                      {selectedUser.verified ? (
                        <span className="flex items-center gap-2 text-green-600">
                          <CheckCircle size={20} />
                          <span className="font-medium">Verified</span>
                        </span>
                      ) : (
                        <span className="flex items-center gap-2 text-red-600">
                          <XCircle size={20} />
                          <span className="font-medium">Not Verified</span>
                        </span>
                      )}
                    </div>
                  </div>
                  <div className="bg-gray-50 dark:bg-gray-700 p-4 rounded-lg">
                    <p className="text-sm text-gray-600 dark:text-gray-400">Total Rides</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-white mt-1">{selectedUser.rides}</p>
                  </div>
                  <div className="bg-gray-50 dark:bg-gray-700 p-4 rounded-lg">
                    <p className="text-sm text-gray-600 dark:text-gray-400">Rating</p>
                    <div className="flex items-center gap-2 mt-1">
                      <Star className="text-yellow-500 fill-yellow-500" size={20} />
                      <span className="text-2xl font-bold text-gray-900 dark:text-white">
                        {selectedUser.rating > 0 ? selectedUser.rating.toFixed(1) : 'N/A'}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Driver-specific Information */}
              {selectedUser.role === 'Driver' && selectedUser.vehicleModel && (
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Vehicle Information</h3>
                  <div className="bg-gray-50 dark:bg-gray-700 p-4 rounded-lg space-y-3">
                    <div className="flex items-center gap-3 text-gray-700 dark:text-gray-300">
                      <Car className="text-green-600" size={20} />
                      <div>
                        <p className="font-medium">{selectedUser.vehicleModel}</p>
                        <p className="text-sm text-gray-600 dark:text-gray-400">{selectedUser.vehicleType}</p>
                      </div>
                    </div>
                    <div className="flex items-center justify-between pt-2 border-t border-gray-200 dark:border-gray-600">
                      <span className="text-sm text-gray-600 dark:text-gray-400">License Plate</span>
                      <span className="font-mono font-bold text-gray-900 dark:text-white">{selectedUser.licensePlate}</span>
                    </div>
                  </div>
                </div>
              )}

              {/* Member Since */}
              <div className="flex items-center gap-3 text-gray-700 dark:text-gray-300 pt-4 border-t border-gray-200 dark:border-gray-700">
                <Calendar className="text-green-600" size={20} />
                <div>
                  <p className="text-sm text-gray-600 dark:text-gray-400">Member Since</p>
                  <p className="font-medium">{new Date(selectedUser.joinedDate).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</p>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex flex-wrap gap-3 pt-4">
                <button className="flex-1 min-w-[120px] bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
                  Edit Profile
                </button>
                <button className="flex-1 min-w-[120px] bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors">
                  {selectedUser.verified ? 'Verified' : 'Verify User'}
                </button>
                <button className="flex-1 min-w-[120px] bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors">
                  {selectedUser.status === 'Suspended' ? 'Activate' : 'Suspend'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Header */}
      <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 sm:p-6 border border-gray-100 dark:border-gray-700">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h2 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white">User & Driver Management</h2>
            <p className="text-sm sm:text-base text-gray-600 dark:text-gray-400 mt-1">Manage user verification, roles, and status</p>
          </div>
          <button className="bg-green-600 text-white px-4 sm:px-6 py-2 rounded-lg hover:bg-green-700 transition-colors text-sm sm:text-base">
            Add New User
          </button>
        </div>
      </div>

      {/* Tabs, Search and Filters */}
      <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 sm:p-6 border border-gray-100 dark:border-gray-700">
        <div className="space-y-4">
          {/* Tabs */}
          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => setActiveTab('all')}
              className={`px-3 sm:px-4 py-2 rounded-lg font-medium transition-colors text-sm sm:text-base ${
                activeTab === 'all' ? 'bg-green-600 text-white' : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
              }`}
            >
              All Users
            </button>
            <button
              onClick={() => setActiveTab('rider')}
              className={`px-3 sm:px-4 py-2 rounded-lg font-medium transition-colors text-sm sm:text-base ${
                activeTab === 'rider' ? 'bg-green-600 text-white' : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
              }`}
            >
              Riders
            </button>
            <button
              onClick={() => setActiveTab('driver')}
              className={`px-3 sm:px-4 py-2 rounded-lg font-medium transition-colors text-sm sm:text-base ${
                activeTab === 'driver' ? 'bg-green-600 text-white' : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
              }`}
            >
              Drivers
            </button>
          </div>

          {/* Search and Filter Toggle */}
          <div className="flex flex-col sm:flex-row gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search users..."
                className="pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 w-full"
              />
            </div>
            <button
              onClick={() => setShowFilters(!showFilters)}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-colors ${
                showFilters ? 'bg-green-600 text-white' : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
              }`}
            >
              <Filter size={20} />
              <span>Filters</span>
            </button>
          </div>

          {/* Filter Options */}
          {showFilters && (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Status</label>
                <select
                  value={filters.status}
                  onChange={(e) => setFilters({...filters, status: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 dark:bg-gray-800 dark:text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                >
                  <option value="all">All Status</option>
                  <option value="Active">Active</option>
                  <option value="Pending">Pending</option>
                  <option value="Suspended">Suspended</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Verification</label>
                <select
                  value={filters.verified}
                  onChange={(e) => setFilters({...filters, verified: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 dark:bg-gray-800 dark:text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                >
                  <option value="all">All</option>
                  <option value="verified">Verified</option>
                  <option value="unverified">Unverified</option>
                </select>
              </div>
              {activeTab === 'driver' && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Rating</label>
                  <select
                    value={filters.rating}
                    onChange={(e) => setFilters({...filters, rating: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 dark:bg-gray-800 dark:text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                  >
                    <option value="all">All Ratings</option>
                    <option value="high">High (4.5+)</option>
                    <option value="medium">Medium (3.5-4.5)</option>
                    <option value="low">Low (&lt; 3.5)</option>
                  </select>
                </div>
              )}
            </div>
          )}
        </div>

        {/* Users Table */}
        <div className="overflow-x-auto">
          <table className="w-full min-w-[800px]">
            <thead>
              <tr className="border-b border-gray-200 dark:border-gray-700">
                <th className="text-left py-3 px-4 font-semibold text-gray-700 dark:text-gray-300">User</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700 dark:text-gray-300">Role</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700 dark:text-gray-300">Status</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700 dark:text-gray-300">Verified</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700 dark:text-gray-300">Rides</th>
                {activeTab === 'driver' && (
                  <th className="text-left py-3 px-4 font-semibold text-gray-700 dark:text-gray-300">Rating</th>
                )}
                <th className="text-left py-3 px-4 font-semibold text-gray-700 dark:text-gray-300">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredUsers.map((user) => (
                <tr 
                  key={user.id} 
                  className="border-b border-gray-100 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700 cursor-pointer transition-colors"
                  onClick={() => setSelectedUser(user)}
                >
                  <td className="py-4 px-4">
                    <div className="flex items-center">
                      <div className="w-10 h-10 rounded-full bg-green-500 flex items-center justify-center text-white font-semibold mr-3 flex-shrink-0">
                        {user.name.charAt(0)}
                      </div>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-white">{user.name}</p>
                        <p className="text-sm text-gray-500 dark:text-gray-400">{user.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="py-4 px-4">
                    <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200">
                      {user.role}
                    </span>
                  </td>
                  <td className="py-4 px-4">
                    <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(user.status)}`}>
                      {user.status}
                    </span>
                  </td>
                  <td className="py-4 px-4">
                    {user.verified ? (
                      <CheckCircle className="text-green-500" size={20} />
                    ) : (
                      <XCircle className="text-red-500" size={20} />
                    )}
                  </td>
                  <td className="py-4 px-4">
                    <span className="text-gray-900 dark:text-white font-medium">{user.rides}</span>
                  </td>
                  {activeTab === 'driver' && (
                    <td className="py-4 px-4">
                      <div className="flex items-center gap-1">
                        <Star className="text-yellow-500 fill-yellow-500" size={16} />
                        <span className="text-gray-900 dark:text-white font-medium">
                          {user.rating > 0 ? user.rating.toFixed(1) : 'N/A'}
                        </span>
                      </div>
                    </td>
                  )}
                  <td className="py-4 px-4">
                    <div className="flex flex-wrap gap-2">
                      <button 
                        onClick={(e) => e.stopPropagation()}
                        className="text-green-600 hover:text-green-800 dark:text-green-400 dark:hover:text-green-300 text-sm font-medium"
                      >
                        Verify
                      </button>
                      <button 
                        onClick={(e) => e.stopPropagation()}
                        className="text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300 text-sm font-medium"
                      >
                        Suspend
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {filteredUsers.length === 0 && (
            <div className="text-center py-12">
              <User className="mx-auto text-gray-400 mb-4" size={48} />
              <p className="text-gray-600 dark:text-gray-400">No users found matching your criteria.</p>
            </div>
          )}
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 sm:p-6 border border-gray-100 dark:border-gray-700">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 dark:text-gray-400 text-sm">Total Users</p>
              <p className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mt-1">12,458</p>
            </div>
            <User className="text-blue-500" size={32} />
          </div>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 sm:p-6 border border-gray-100 dark:border-gray-700">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 dark:text-gray-400 text-sm">Active Drivers</p>
              <p className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mt-1">1,234</p>
            </div>
            <User className="text-green-500" size={32} />
          </div>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 sm:p-6 border border-gray-100 dark:border-gray-700">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 dark:text-gray-400 text-sm">Pending Verification</p>
              <p className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mt-1">45</p>
            </div>
            <AlertCircle className="text-yellow-500" size={32} />
          </div>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 sm:p-6 border border-gray-100 dark:border-gray-700">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 dark:text-gray-400 text-sm">Suspended</p>
              <p className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mt-1">23</p>
            </div>
            <XCircle className="text-red-500" size={32} />
          </div>
        </div>
      </div>
    </div>
  );
};

export default UserManagement;
