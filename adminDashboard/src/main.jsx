// React's StrictMode wrapper for highlighting potential problems
import { StrictMode } from 'react';
// React 18 createRoot API for rendering the app
import { createRoot } from 'react-dom/client';
// Global CSS styles for the application
import './index.css';
// Main App component with routing and providers
import App from './App.jsx';

// Get the root DOM element where React will mount
// Render the App component wrapped in StrictMode
// StrictMode enables additional development checks and warnings
createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
