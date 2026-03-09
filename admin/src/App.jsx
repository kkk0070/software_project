import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { ThemeProvider } from './contexts/ThemeContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import DashboardLayout from './layouts/DashboardLayout';
import Login from './pages/Login';
import Overview from './pages/Overview';
import UserManagement from './pages/UserManagement';
import LiveRideMonitoring from './pages/LiveRideMonitoring';
import DemandHeatmap from './pages/DemandHeatmap';
import RouteAnalytics from './pages/RouteAnalytics';
import GPSLogs from './pages/GPSLogs';
import Sustainability from './pages/Sustainability';
import AIOptimization from './pages/AIOptimization';
import SafetyMonitoring from './pages/SafetyMonitoring';
import Notifications from './pages/Notifications';
import Reports from './pages/Reports';
import SystemMonitoring from './pages/SystemMonitoring';
import Settings from './pages/Settings';
import APIDemo from './pages/APIDemo';
import DocumentVerification from './pages/DocumentVerification';

function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <BrowserRouter>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route
              path="/dashboard"
              element={
                <ProtectedRoute>
                  <DashboardLayout />
                </ProtectedRoute>
              }
            >
              <Route index element={<Overview />} />
              <Route path="users" element={<UserManagement />} />
              <Route path="rides" element={<LiveRideMonitoring />} />
              <Route path="demand" element={<DemandHeatmap />} />
              <Route path="routes" element={<RouteAnalytics />} />
              <Route path="gps" element={<GPSLogs />} />
              <Route path="sustainability" element={<Sustainability />} />
              <Route path="ai" element={<AIOptimization />} />
              <Route path="safety" element={<SafetyMonitoring />} />
              <Route path="notifications" element={<Notifications />} />
              <Route path="reports" element={<Reports />} />
              <Route path="monitoring" element={<SystemMonitoring />} />
              <Route path="settings" element={<Settings />} />
              <Route path="api-demo" element={<APIDemo />} />
              <Route path="documents" element={<DocumentVerification />} />
            </Route>
            <Route path="/" element={<Navigate to="/login" replace />} />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;
