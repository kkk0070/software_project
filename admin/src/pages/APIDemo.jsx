import { useState, useEffect } from 'react';
import { RefreshCw, Plus, Edit2, Trash2, CheckCircle, XCircle, Users } from 'lucide-react';
import { userAPI } from '../services/api';

const APIDemo = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [stats, setStats] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: 'password123',
    phone: '',
    location: '',
    role: 'Rider'
  });
  const [editingUser, setEditingUser] = useState(null);

  // Fetch users from API
  const fetchUsers = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await userAPI.getAll();
      setUsers(response.data || []);
    } catch (err) {
      setError(err.message);
      console.error('Error fetching users:', err);
    } finally {
      setLoading(false);
    }
  };

  // Fetch user statistics
  const fetchStats = async () => {
    try {
      const response = await userAPI.getStats();
      setStats(response.data);
    } catch (err) {
      console.error('Error fetching stats:', err);
    }
  };

  // Create new user
  const handleCreate = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      await userAPI.create(formData);
      setShowForm(false);
      setFormData({
        name: '',
        email: '',
        password: 'password123',
        phone: '',
        location: '',
        role: 'Rider'
      });
      fetchUsers();
      fetchStats();
      alert('User created successfully!');
    } catch (err) {
      setError(err.message);
      alert('Error creating user: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  // Update user status
  const handleUpdateStatus = async (userId, newStatus) => {
    setLoading(true);
    try {
      await userAPI.update(userId, { status: newStatus });
      fetchUsers();
      alert('User status updated successfully!');
    } catch (err) {
      setError(err.message);
      alert('Error updating user: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  // Delete user
  const handleDelete = async (userId) => {
    if (!confirm('Are you sure you want to delete this user?')) return;
    
    setLoading(true);
    try {
      await userAPI.delete(userId);
      fetchUsers();
      fetchStats();
      alert('User deleted successfully!');
    } catch (err) {
      setError(err.message);
      alert('Error deleting user: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  // Load users on mount
  useEffect(() => {
    fetchUsers();
    fetchStats();
  }, []);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">Backend API Demo</h2>
            <p className="text-gray-600 mt-1">Testing CRUD operations with PostgreSQL backend</p>
          </div>
          <button
            onClick={fetchUsers}
            disabled={loading}
            className="flex items-center gap-2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50"
          >
            <RefreshCw size={20} className={loading ? 'animate-spin' : ''} />
            Refresh
          </button>
        </div>
      </div>

      {/* Statistics */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Total Riders</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">{stats.total_riders || 0}</p>
              </div>
              <div className="p-3 bg-blue-100 rounded-lg">
                <Users className="text-blue-600" size={24} />
              </div>
            </div>
          </div>
          <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Total Drivers</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">{stats.total_drivers || 0}</p>
              </div>
              <div className="p-3 bg-green-100 rounded-lg">
                <Users className="text-green-600" size={24} />
              </div>
            </div>
          </div>
          <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Active Users</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">{stats.active_users || 0}</p>
              </div>
              <div className="p-3 bg-purple-100 rounded-lg">
                <CheckCircle className="text-purple-600" size={24} />
              </div>
            </div>
          </div>
          <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Pending Users</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">{stats.pending_users || 0}</p>
              </div>
              <div className="p-3 bg-yellow-100 rounded-lg">
                <XCircle className="text-yellow-600" size={24} />
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Error Display */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <p className="text-red-800">
            <strong>Error:</strong> {error}
          </p>
          <p className="text-sm text-red-600 mt-2">
            Make sure the backend server is running on port 5000 and PostgreSQL is configured correctly.
          </p>
        </div>
      )}

      {/* Add User Button */}
      <div className="flex justify-end">
        <button
          onClick={() => setShowForm(!showForm)}
          className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
        >
          <Plus size={20} />
          Add New User
        </button>
      </div>

      {/* Create User Form */}
      {showForm && (
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Create New User</h3>
          <form onSubmit={handleCreate} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Name *</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  required
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Email *</label>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({...formData, email: e.target.value})}
                  required
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Phone</label>
                <input
                  type="tel"
                  value={formData.phone}
                  onChange={(e) => setFormData({...formData, phone: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Location</label>
                <input
                  type="text"
                  value={formData.location}
                  onChange={(e) => setFormData({...formData, location: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Role *</label>
                <select
                  value={formData.role}
                  onChange={(e) => setFormData({...formData, role: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                >
                  <option value="Rider">Rider</option>
                  <option value="Driver">Driver</option>
                  <option value="Admin">Admin</option>
                </select>
              </div>
            </div>
            <div className="flex gap-3">
              <button
                type="submit"
                disabled={loading}
                className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50"
              >
                {loading ? 'Creating...' : 'Create User'}
              </button>
              <button
                type="button"
                onClick={() => setShowForm(false)}
                className="bg-gray-300 text-gray-700 px-6 py-2 rounded-lg hover:bg-gray-400 transition-colors"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Users Table */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-6 border-b border-gray-100">
          <h3 className="text-lg font-semibold text-gray-900">Users from Database</h3>
          <p className="text-sm text-gray-600 mt-1">
            {users.length} user{users.length !== 1 ? 's' : ''} loaded from PostgreSQL
          </p>
        </div>
        
        {loading && !users.length ? (
          <div className="p-8 text-center">
            <RefreshCw className="animate-spin mx-auto text-gray-400" size={32} />
            <p className="text-gray-600 mt-2">Loading users...</p>
          </div>
        ) : users.length === 0 ? (
          <div className="p-8 text-center">
            <p className="text-gray-600">No users found. Create one to get started!</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Verified</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {users.map((user) => (
                  <tr key={user.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{user.id}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{user.name}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{user.email}</td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                        user.role === 'Driver' ? 'bg-blue-100 text-blue-800' : 
                        user.role === 'Admin' ? 'bg-purple-100 text-purple-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {user.role}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                        user.status === 'Active' ? 'bg-green-100 text-green-800' :
                        user.status === 'Suspended' ? 'bg-red-100 text-red-800' :
                        'bg-yellow-100 text-yellow-800'
                      }`}>
                        {user.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {user.verified ? (
                        <CheckCircle className="text-green-600" size={20} />
                      ) : (
                        <XCircle className="text-red-600" size={20} />
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm">
                      <div className="flex items-center gap-2">
                        {user.status === 'Active' ? (
                          <button
                            onClick={() => handleUpdateStatus(user.id, 'Suspended')}
                            disabled={loading}
                            className="text-red-600 hover:text-red-800 disabled:opacity-50"
                            title="Suspend"
                          >
                            <XCircle size={18} />
                          </button>
                        ) : (
                          <button
                            onClick={() => handleUpdateStatus(user.id, 'Active')}
                            disabled={loading}
                            className="text-green-600 hover:text-green-800 disabled:opacity-50"
                            title="Activate"
                          >
                            <CheckCircle size={18} />
                          </button>
                        )}
                        <button
                          onClick={() => handleDelete(user.id)}
                          disabled={loading}
                          className="text-red-600 hover:text-red-800 disabled:opacity-50"
                          title="Delete"
                        >
                          <Trash2 size={18} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Instructions */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
        <h3 className="text-lg font-semibold text-blue-900 mb-2">Backend Setup Instructions</h3>
        <div className="text-blue-800 space-y-2">
          <p>1. Navigate to backend directory: <code className="bg-blue-100 px-2 py-1 rounded">cd backend</code></p>
          <p>2. Install dependencies: <code className="bg-blue-100 px-2 py-1 rounded">npm install</code></p>
          <p>3. Configure PostgreSQL in <code className="bg-blue-100 px-2 py-1 rounded">.env</code> file</p>
          <p>4. Initialize database: <code className="bg-blue-100 px-2 py-1 rounded">npm run init-db</code></p>
          <p>5. Start server: <code className="bg-blue-100 px-2 py-1 rounded">npm run dev</code></p>
        </div>
      </div>
    </div>
  );
};

export default APIDemo;
