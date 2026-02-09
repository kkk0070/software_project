// React Router for client-side routing and navigation
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
// Authentication context provider for managing user login state
import { AuthProvider } from './contexts/AuthContext';
// Theme context provider for light/dark mode management
import { ThemeProvider } from './contexts/ThemeContext';
// Component to protect routes that require authentication
import { ProtectedRoute } from './components/ProtectedRoute';
// Main dashboard layout with sidebar and header
import DashboardLayout from './layouts/DashboardLayout';

// Import all page components for routing
import Login from './pages/Login';                             // Login page
import Overview from './pages/Overview';                       // Dashboard overview with key metrics
import UserManagement from './pages/UserManagement';           // Manage users (riders/drivers)
import LiveRideMonitoring from './pages/LiveRideMonitoring';   // Real-time ride tracking
import DemandHeatmap from './pages/DemandHeatmap';             // Heatmap showing ride demand
import RouteAnalytics from './pages/RouteAnalytics';           // Analytics for popular routes
import GPSLogs from './pages/GPSLogs';                         // GPS tracking history
import Sustainability from './pages/Sustainability';           // Carbon emissions and eco metrics
import AIOptimization from './pages/AIOptimization';           // AI-based route optimization
import SafetyMonitoring from './pages/SafetyMonitoring';       // Safety alerts and monitoring
import Notifications from './pages/Notifications';             // Push notification management
import Reports from './pages/Reports';                         // Generate reports and analytics
import SystemMonitoring from './pages/SystemMonitoring';       // System health and performance
import Settings from './pages/Settings';                       // Admin settings
import APIDemo from './pages/APIDemo';                         // API testing and demonstration
import DocumentVerification from './pages/DocumentVerification'; // Verify driver documents

/**
 * Main App component - sets up routing and context providers
 */
function App() {
  return (
    // Wrap app with ThemeProvider for theme switching support
    <ThemeProvider>
      {/* Wrap app with AuthProvider for authentication state management */}
      <AuthProvider>
        {/* BrowserRouter enables client-side routing */}
        <BrowserRouter>
          <Routes>
            {/* Public route - accessible without authentication */}
            <Route path="/login" element={<Login />} />
            
            {/* Protected dashboard routes - require authentication */}
            <Route
              path="/dashboard"
              element={
                // ProtectedRoute redirects to login if user not authenticated
                <ProtectedRoute>
                  <DashboardLayout />
                </ProtectedRoute>
              }
            >
              {/* Nested routes within dashboard layout */}
              <Route index element={<Overview />} />                          {/* Default dashboard page */}
              <Route path="users" element={<UserManagement />} />             {/* /dashboard/users */}
              <Route path="rides" element={<LiveRideMonitoring />} />         {/* /dashboard/rides */}
              <Route path="demand" element={<DemandHeatmap />} />             {/* /dashboard/demand */}
              <Route path="routes" element={<RouteAnalytics />} />            {/* /dashboard/routes */}
              <Route path="gps" element={<GPSLogs />} />                      {/* /dashboard/gps */}
              <Route path="sustainability" element={<Sustainability />} />    {/* /dashboard/sustainability */}
              <Route path="ai" element={<AIOptimization />} />                {/* /dashboard/ai */}
              <Route path="safety" element={<SafetyMonitoring />} />          {/* /dashboard/safety */}
              <Route path="notifications" element={<Notifications />} />      {/* /dashboard/notifications */}
              <Route path="reports" element={<Reports />} />                  {/* /dashboard/reports */}
              <Route path="monitoring" element={<SystemMonitoring />} />      {/* /dashboard/monitoring */}
              <Route path="settings" element={<Settings />} />                {/* /dashboard/settings */}
              <Route path="api-demo" element={<APIDemo />} />                 {/* /dashboard/api-demo */}
              <Route path="documents" element={<DocumentVerification />} />   {/* /dashboard/documents */}
            </Route>
            
            {/* Root path redirects to login */}
            <Route path="/" element={<Navigate to="/login" replace />} />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;
