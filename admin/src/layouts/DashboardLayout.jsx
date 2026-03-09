import { useState } from 'react';
import { Link, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { useTheme } from '../contexts/ThemeContext';
import {
  LayoutDashboard,
  Users,
  MapPin,
  TrendingUp,
  Route,
  Navigation,
  Leaf,
  Brain,
  Shield,
  Bell,
  FileText,
  FileCheck,
  Activity,
  Settings,
  LogOut,
  Menu,
  X,
  Sun,
  Moon
} from 'lucide-react';

const DashboardLayout = () => {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const location = useLocation();
  const navigate = useNavigate();
  const { logout, user } = useAuth();
  const { theme, toggleTheme } = useTheme();

  const menuItems = [
    { path: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
    { path: '/dashboard/users', icon: Users, label: 'Users & Drivers' },
    { path: '/dashboard/documents', icon: FileCheck, label: 'Document Verification' },
    { path: '/dashboard/rides', icon: MapPin, label: 'Live Monitoring' },
    { path: '/dashboard/demand', icon: TrendingUp, label: 'Demand Analytics' },
    { path: '/dashboard/routes', icon: Route, label: 'Route Analytics' },
    { path: '/dashboard/gps', icon: Navigation, label: 'GPS & Location' },
    { path: '/dashboard/sustainability', icon: Leaf, label: 'Sustainability' },
    { path: '/dashboard/ai', icon: Brain, label: 'AI Optimization' },
    { path: '/dashboard/safety', icon: Shield, label: 'Safety & Emergency' },
    { path: '/dashboard/notifications', icon: Bell, label: 'Notifications' },
    { path: '/dashboard/reports', icon: FileText, label: 'Reports' },
    { path: '/dashboard/monitoring', icon: Activity, label: 'System Monitoring' },
    { path: '/dashboard/api-demo', icon: Activity, label: 'API Demo' },
    { path: '/dashboard/settings', icon: Settings, label: 'Settings' }
  ];

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className="flex h-screen bg-background-light dark:bg-background-dark">
      {/* Sidebar */}
      <aside
        className={`${
          sidebarOpen ? 'w-64' : 'w-20'
        } border-r border-slate-200 dark:border-white/10 flex flex-col bg-background-light dark:bg-background-dark transition-all duration-300 overflow-y-auto`}
      >
        <div className="p-6 flex items-center gap-3 border-b border-slate-200 dark:border-white/10">
          {sidebarOpen ? (
            <>
              <div className="bg-primary p-2 rounded-lg flex items-center justify-center">
                <svg fill="none" viewBox="0 0 24 24" className="w-5 h-5 text-background-dark" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 22.9048C9.84325 22.9048 7.73489 22.2652 5.94158 21.067C4.14828 19.8688 2.75064 18.1657 1.92528 16.1731C1.09993 14.1805 0.883969 11.9879 1.3047 9.87258C1.7255 7.75725 2.76408 5.81421 4.28915 4.28914C5.81422 2.76407 7.75726 1.72549 9.87259 1.30474C11.9879 0.883987 14.1805 1.09993 16.1731 1.92529C18.1657 2.75065 19.8688 4.14829 21.067 5.94159C22.2652 7.7349 22.9048 9.84326 22.9048 12L12 12L12 22.9048Z" fill="currentColor"></path>
                </svg>
              </div>
              <span className="text-xl font-bold tracking-tight text-slate-900 dark:text-white">EcoRide</span>
            </>
          ) : (
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="p-2 rounded-lg hover:bg-slate-100 dark:hover:bg-white/5 text-slate-900 dark:text-white"
            >
              <Menu size={20} />
            </button>
          )}
          {sidebarOpen && (
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="ml-auto p-2 rounded-lg hover:bg-slate-100 dark:hover:bg-white/5 text-slate-900 dark:text-white"
            >
              <X size={20} />
            </button>
          )}
        </div>

        <nav className="flex-1 px-4 space-y-2 mt-4">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            return (
              <Link
                key={item.path}
                to={item.path}
                className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-all ${
                  isActive
                    ? 'bg-primary/10 text-primary'
                    : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-white/5'
                }`}
              >
                <Icon size={20} className="flex-shrink-0" />
                {sidebarOpen && <span className="font-medium">{item.label}</span>}
              </Link>
            );
          })}
        </nav>

        <div className="p-4 border-t border-slate-200 dark:border-white/10">
          {sidebarOpen ? (
            <div className="space-y-2">
              <div className="flex items-center gap-3 p-2 rounded-lg bg-slate-100 dark:bg-white/5">
                <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center text-background-dark font-semibold">
                  {user?.name?.charAt(0) || 'A'}
                </div>
                <div className="flex flex-col">
                  <span className="text-sm font-semibold text-slate-900 dark:text-white">{user?.name || 'Admin User'}</span>
                  <span className="text-xs text-slate-500 dark:text-slate-400">Platform Admin</span>
                </div>
              </div>
              <button
                onClick={handleLogout}
                className="flex items-center gap-3 w-full px-4 py-3 rounded-lg text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-white/5 transition-all"
              >
                <LogOut size={20} />
                <span className="font-medium">Logout</span>
              </button>
            </div>
          ) : (
            <button
              onClick={handleLogout}
              className="flex items-center justify-center w-full p-3 rounded-lg text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-white/5 transition-all"
            >
              <LogOut size={20} />
            </button>
          )}
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex-1 overflow-auto">
        <header className="bg-white dark:bg-[#1c271f] border-b border-slate-200 dark:border-[#28392e]">
          <div className="px-6 py-4 flex items-center justify-between">
            <h2 className="text-2xl font-semibold text-slate-900 dark:text-white">
              {menuItems.find(item => item.path === location.pathname)?.label || 'Dashboard'}
            </h2>
            <div className="flex items-center space-x-4">
              <button
                onClick={toggleTheme}
                className="p-2 rounded-lg hover:bg-slate-100 dark:hover:bg-white/5 text-slate-900 dark:text-white transition-all"
                title={`Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`}
              >
                {theme === 'dark' ? <Sun size={20} /> : <Moon size={20} />}
              </button>
              <div className="text-right">
                <p className="text-sm font-medium text-slate-900 dark:text-white">{user?.name || 'Admin User'}</p>
                <p className="text-xs text-slate-500 dark:text-slate-400">{user?.email || 'admin@ecoride.com'}</p>
              </div>
              <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center text-background-dark font-semibold">
                {user?.name?.charAt(0) || 'A'}
              </div>
            </div>
          </div>
        </header>

        <main className="p-6 bg-background-light dark:bg-background-dark min-h-full">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default DashboardLayout;
