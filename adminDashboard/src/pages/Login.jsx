import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { Lock, Mail, AlertCircle, ArrowRight, HelpCircle, FileText } from 'lucide-react';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState('Fleet Manager');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { login } = useAuth();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const result = await login(email, password);
      if (result.success) {
        navigate('/dashboard');
      } else {
        setError(result.message || 'Login failed');
      }
    } catch (err) {
      setError('An error occurred during login');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-background-light dark:bg-background-dark min-h-screen flex flex-col font-display transition-colors duration-300">
      {/* Top Navigation */}
      <header className="flex items-center justify-between whitespace-nowrap border-b border-solid border-[#28392e]/20 dark:border-[#28392e] px-10 py-4">
        <div className="flex items-center gap-3 text-background-dark dark:text-white">
          <div className="size-8 text-primary">
            <svg fill="none" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
              <path d="M24 45.8096C19.6865 45.8096 15.4698 44.5305 11.8832 42.134C8.29667 39.7376 5.50128 36.3314 3.85056 32.3462C2.19985 28.361 1.76794 23.9758 2.60947 19.7452C3.451 15.5145 5.52816 11.6284 8.57829 8.5783C11.6284 5.52817 15.5145 3.45101 19.7452 2.60948C23.9758 1.76795 28.361 2.19986 32.3462 3.85057C36.3314 5.50129 39.7376 8.29668 42.134 11.8833C44.5305 15.4698 45.8096 19.6865 45.8096 24L24 24L24 45.8096Z" fill="currentColor"></path>
            </svg>
          </div>
          <h2 className="text-xl font-bold leading-tight tracking-tight">EcoRide <span className="text-primary">Admin</span></h2>
        </div>
        <div className="flex items-center gap-2 text-sm text-slate-500 dark:text-slate-400">
          <Lock size={16} />
          <span>Enterprise-grade security</span>
        </div>
      </header>

      <main className="flex-1 flex items-center justify-center p-6 bg-gradient-to-br from-background-light to-emerald-50 dark:from-background-dark dark:to-[#0a150d]">
        <div className="w-full max-w-[480px] space-y-8">
          {/* Headline Section */}
          <div className="text-center space-y-2">
            <h1 className="text-slate-900 dark:text-white tracking-tight text-3xl font-bold">Sustainable Mobility Management</h1>
            <p className="text-slate-600 dark:text-slate-400 text-base">Enter your credentials to access the command center</p>
          </div>

          {/* Login Card */}
          <div className="bg-white dark:bg-[#1c271f] border border-slate-200 dark:border-[#28392e] rounded-xl shadow-xl overflow-hidden p-8">
            {error && (
              <div className="mb-4 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg flex items-center text-red-700 dark:text-red-400">
                <AlertCircle size={20} className="mr-2 flex-shrink-0" />
                <span>{error}</span>
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Role Selector */}
              <div className="space-y-3">
                <label className="text-slate-900 dark:text-white text-sm font-semibold">Select Administrative Role</label>
                <div className="flex h-12 w-full items-center justify-center rounded-lg bg-slate-100 dark:bg-[#28392e] p-1.5">
                  {['Fleet Manager', 'Admin', 'Support'].map((roleOption) => (
                    <label
                      key={roleOption}
                      className={`flex cursor-pointer h-full grow items-center justify-center overflow-hidden rounded-md px-2 transition-all text-sm font-medium ${
                        role === roleOption
                          ? 'bg-white dark:bg-background-dark shadow-sm text-primary'
                          : 'text-slate-500 dark:text-[#9db9a6]'
                      }`}
                    >
                      <span className="truncate">{roleOption}</span>
                      <input
                        type="radio"
                        name="role-select"
                        value={roleOption}
                        checked={role === roleOption}
                        onChange={(e) => setRole(e.target.value)}
                        className="invisible w-0"
                      />
                    </label>
                  ))}
                </div>
              </div>

              {/* Email Field */}
              <div className="space-y-2">
                <label className="text-slate-900 dark:text-white text-sm font-semibold">Email Address</label>
                <div className="relative">
                  <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-[#9db9a6]" size={20} />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full pl-12 pr-4 py-3.5 rounded-lg border border-slate-200 dark:border-[#3b5443] bg-slate-50 dark:bg-[#111813] text-slate-900 dark:text-white placeholder:text-slate-400 dark:placeholder:text-[#9db9a6] focus:ring-2 focus:ring-primary focus:border-transparent transition-all outline-none"
                    placeholder="admin@ecoride.com"
                    required
                  />
                </div>
              </div>

              {/* Password Field */}
              <div className="space-y-2">
                <div className="flex justify-between items-center">
                  <label className="text-slate-900 dark:text-white text-sm font-semibold">Password</label>
                  <a href="#" className="text-primary text-xs font-semibold hover:underline">Forgot password?</a>
                </div>
                <div className="relative">
                  <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-[#9db9a6]" size={20} />
                  <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full pl-12 pr-4 py-3.5 rounded-lg border border-slate-200 dark:border-[#3b5443] bg-slate-50 dark:bg-[#111813] text-slate-900 dark:text-white placeholder:text-slate-400 dark:placeholder:text-[#9db9a6] focus:ring-2 focus:ring-primary focus:border-transparent transition-all outline-none"
                    placeholder="••••••••"
                    required
                  />
                </div>
              </div>

              {/* CTA Button */}
              <button
                type="submit"
                disabled={loading}
                className="w-full bg-primary hover:bg-primary/90 text-background-dark font-bold py-4 rounded-lg shadow-lg shadow-primary/20 transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span>{loading ? 'Signing in...' : 'Sign In to Dashboard'}</span>
                <ArrowRight size={20} />
              </button>
            </form>
          </div>

          {/* Additional Links */}
          <div className="flex justify-center gap-6 text-sm">
            <a href="#" className="text-slate-500 dark:text-slate-400 hover:text-primary transition-colors flex items-center gap-1">
              <HelpCircle size={16} />
              Support Center
            </a>
            <a href="#" className="text-slate-500 dark:text-slate-400 hover:text-primary transition-colors flex items-center gap-1">
              <FileText size={16} />
              Documentation
            </a>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="py-8 px-10 text-center text-xs text-slate-500 dark:text-slate-500 border-t border-[#28392e]/10 dark:border-[#28392e]">
        <div className="flex flex-col md:flex-row justify-between items-center max-w-5xl mx-auto gap-4">
          <p>© 2024 EcoRide Systems Inc. All rights reserved.</p>
          <div className="flex items-center gap-4">
            <span className="flex items-center gap-1">
              <Lock size={12} className="text-primary" /> 256-bit SSL Encrypted
            </span>
            <a href="#" className="hover:text-primary underline">Privacy Policy</a>
            <a href="#" className="hover:text-primary underline">Security Standards</a>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Login;
