# 🌱 EcoRide - Intelligent Ride-Sharing & Sustainable Mobility Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-16+-339933?logo=node.js)](https://nodejs.org)
[![React](https://img.shields.io/badge/React-19.2+-61DAFB?logo=react)](https://reactjs.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12+-336791?logo=postgresql)](https://postgresql.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

EcoRide is a **complete, production-ready sustainable mobility ecosystem** consisting of three integrated components:
- 🚀 **Cross-platform Flutter Mobile App** - iOS, Android & Web support
- 🔧 **Node.js REST API Backend** - Express + PostgreSQL + Socket.io
- 💻 **React Admin Dashboard** - Real-time monitoring & management

The platform prioritizes environmental impact while providing efficient transportation with features like carbon tracking, ride pooling, gamification, and comprehensive safety measures.

---

# Auth Controller (14 tests)
npm test -- tests/unit/controllers/shared/authController.test.js

# Chat Controller (26 tests)
npm test -- tests/unit/controllers/shared/chatController.test.js

# Emergency Controller (22 tests)
npm test -- tests/unit/controllers/shared/emergencyController.test.js

# Settings Controller (28 tests)
npm test -- tests/unit/controllers/shared/settingsController.test.js

# Notification Controller (30 tests)
npm test -- tests/unit/controllers/shared/notificationController.test.js


# Monitoring Controller (30 tests)
npm test -- tests/unit/controllers/shared/monitoringController.test.js

# Reports Controller (28 tests)
npm test -- tests/unit/controllers/shared/reportsController.test.js




## 📋 Table of Contents

- [📖 Overview](#-overview)
- [🏗️ Architecture](#️-architecture)
- [✨ Key Features](#-key-features)
- [🛠️ Technology Stack](#️-technology-stack)
- [🚀 Quick Start](#-quick-start)
- [📱 Application Components](#-application-components)
- [📂 Project Structure](#-project-structure)
- [🔒 Security](#-security)
- [📖 API Documentation](#-api-documentation)
- [🧪 Testing](#-testing)
- [🎨 Design System](#-design-system)
- [📚 Documentation](#-documentation)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 📖 Overview

**EcoRide** is a comprehensive sustainable mobility platform that combines ride-sharing with broader travel services while maintaining a strong focus on environmental impact. The platform enables users to:

- 🚗 **Book Eco-Friendly Rides** - Choose from solo, pooled, or EV options
- 🌍 **Track Carbon Footprint** - Monitor CO₂ emissions across all transportation
- 🏨 **Find Green Accommodations** - Hotels with sustainability certifications
- 🍽️ **Discover Sustainable Dining** - Restaurants with vegan and organic options
- 🗺️ **Plan Smart Trips** - Day-wise itineraries with budget tracking
- 🎮 **Earn Eco Rewards** - Gamified incentives for sustainable choices
- 🔒 **Stay Safe** - Emergency SOS, location sharing, and real-time tracking

The ecosystem consists of three tightly integrated components that work together seamlessly to deliver a complete experience.

---

## 🏗️ Architecture

EcoRide follows a **modern three-tier architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT APPLICATIONS                       │
├─────────────────────────────────────────────────────────────┤
│  📱 Flutter Mobile App                💻 Admin Dashboard    │
│  • iOS / Android / Web                • React + Vite        │
│  • Material Design 3                  • Tailwind CSS        │
│  • Provider State Management          • Real-time Updates   │
└──────────────────┬──────────────────────────┬───────────────┘
                   │                          │
                   │      REST API / HTTP     │
                   │      WebSocket (Real-time)│
                   ▼                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    BACKEND API SERVER                        │
├─────────────────────────────────────────────────────────────┤
│  🔧 Node.js + Express.js                                    │
│  • RESTful API Endpoints (66+)                              │
│  • JWT Authentication + 2FA                                  │
│  • Socket.io (Real-time notifications)                      │
│  • Multer (File uploads)                                    │
│  • Express Validator (Input validation)                     │
│  • Nodemailer (Email service)                               │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   │      SQL Queries (Knex.js)
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    DATABASE LAYER                            │
├─────────────────────────────────────────────────────────────┤
│  🗄️ PostgreSQL Database                                     │
│  • 10+ Tables (Users, Rides, Bookings, Messages, etc.)     │
│  • AES Encryption for sensitive data                        │
│  • Transaction support with rollback                        │
│  • Foreign key constraints & indexes                        │
└─────────────────────────────────────────────────────────────┘
```

### Communication Flow

1. **Authentication** → Client → Backend validates → JWT token + refresh token
2. **Ride Booking** → Client request → Backend processes → Database stores → Socket.io notifies driver
3. **Real-time Tracking** → GPS updates → Backend → WebSocket broadcast → All clients updated
4. **Admin Operations** → Dashboard → Backend → Database → Response with analytics

---

## ✨ Key Features

### 🚗 Core Ride Management
- ✅ **Smart Ride Booking** - Map-based pickup/drop-off with real-time location selection
- ✅ **Ride Pooling** - Cost-effective shared rides with CO₂ savings comparison
- ✅ **Live Tracking** - Real-time vehicle tracking with dynamic ETA updates
- ✅ **Driver Navigation** - Turn-by-turn navigation with traffic-aware routing
- ✅ **Route Optimization** - Dynamic rerouting and intelligent pickup sequencing
- ✅ **Ride History** - Complete transaction history with receipts and details
- ✅ **Rating System** - Bidirectional ratings and feedback for quality assurance

### 🌱 Sustainability & Environmental Impact
- ✅ **Carbon Tracking** - Monitor CO₂ emissions for every trip and transport mode
- ✅ **Eco Score** - Personalized sustainability score with percentile ranking
- ✅ **Green Routes** - AI-powered eco-optimized route recommendations
- ✅ **EV Priority** - Filter and prefer electric vehicle fleet options
- ✅ **Impact Dashboard** - Visual charts showing environmental contribution over time
- ✅ **Eco Certifications** - Green ratings for hotels and services (Gold/Silver/Bronze)
- ✅ **Trees Saved Calculator** - Conversion of CO₂ savings to equivalent trees planted

### 🎮 Gamification & Rewards
- ✅ **Eco Points System** - Earn points for every sustainable ride choice
- ✅ **Achievement Badges** - Unlock badges (Eco Warrior, Pool Pro, EV Champion, Green Explorer)
- ✅ **Milestones & Goals** - Track progress toward sustainability targets
- ✅ **Leaderboards** - Compare eco-scores with friends and global community
- ✅ **Reward Tiers** - Progressive rewards (Bronze → Silver → Gold → Platinum)
- ✅ **Challenge System** - Weekly/monthly sustainability challenges

### 🔒 Safety & Security
- ✅ **Emergency SOS** - Hold-to-activate emergency alert with auto-location sharing
- ✅ **Live Location Sharing** - Share real-time location with emergency contacts
- ✅ **Two-Factor Authentication (2FA)** - Email-based verification for secure logins
- ✅ **Data Encryption** - AES-256 encryption for sensitive user data
- ✅ **Location Accuracy Monitoring** - GPS validation and anomaly detection
- ✅ **Privacy Controls** - Granular permissions for location and data access
- ✅ **Incident Logging** - Comprehensive safety event tracking and reporting
- ✅ **Password Security** - Bcrypt hashing with salt for password storage

### 🏨 Multi-Service Travel Platform
- ✅ **Multi-modal Transportation** - Flights, trains, buses, and EV rides
- ✅ **Hotel Booking** - Eco-friendly accommodations with green certifications
- ✅ **Restaurant Discovery** - Find sustainable dining with vegan/organic filters
- ✅ **Travel Guides** - Connect with certified local experts by language/specialization
- ✅ **Experiences & Activities** - Book tours, adventures, and cultural experiences
- ✅ **Smart Trip Planner** - Create day-wise itineraries with budget breakdowns
- ✅ **Budget Tracker** - Monitor expenses across transport, hotels, food, and activities

### 💻 Admin Dashboard Features
- ✅ **Real-time Analytics** - Monitor active rides, bookings, and revenue with live updates
- ✅ **User Management** - View, edit, suspend, and manage user accounts
- ✅ **Driver Management** - Approve/reject driver applications and verify documents
- ✅ **Ride Monitoring** - Track all rides with status, location, and completion data
- ✅ **Revenue Reports** - Financial analytics with charts, trends, and export options
- ✅ **System Notifications** - Broadcast announcements to users and drivers
- ✅ **Data Export** - Export reports in CSV/PDF formats for analysis
- ✅ **Settings Management** - Configure app settings, pricing, and features

### 📱 Mobile App Screens (20+ Screens)

#### Main Navigation
1. **Explore Screen** - Main hub with stats, search, categories, and destinations
2. **Transportation Hub** - Multi-modal transport with carbon comparison
3. **Hotels Screen** - Search eco-friendly accommodations
4. **Restaurants Screen** - Discover sustainable dining options
5. **Travel Guides** - Book certified local experts

#### Ride Management
6. **Ride Booking** - Interactive booking with map and preferences
7. **Ride Pooling** - Compare solo vs. pooled options with savings
8. **Live Tracking** - Real-time ride monitoring with driver info
9. **Driver Navigation** - Turn-by-turn guidance for drivers
10. **Route Optimization** - Dynamic route updates and alerts

#### User Features
11. **User Profile** - Profile management and document upload
12. **Location Permissions** - GPS and privacy settings
13. **Ride History** - Past rides with receipts and details
14. **Rating & Feedback** - Post-ride rating system
15. **Notifications** - Ride alerts and system updates

#### Sustainability & Planning
16. **Sustainability Dashboard** - Carbon tracking and eco score
17. **Green Routes** - Eco-optimized route recommendations
18. **Rewards** - Gamification and achievement system
19. **Trip Planner** - Day-wise itinerary builder
20. **Budget Tracker** - Expense tracking by category

#### Support & Safety
21. **Emergency Support** - SOS button and emergency contacts
22. **Language Helper** - Translation with pronunciation guide
23. **Help & Support** - FAQs and customer support
24. **Settings** - App preferences, account, and privacy

---

## 🛠️ Technology Stack

### 📱 Flutter Mobile App

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| **Framework** | Flutter | ^3.9.2 | Cross-platform mobile development |
| **Language** | Dart | Latest | Programming language |
| **UI** | Material Design 3 | - | Modern UI components |
| **State Management** | Provider | ^6.1.1 | Application state handling |
| **Maps** | google_maps_flutter | ^2.5.0 | Map integration & visualization |
| **Location** | geolocator, location | ^10.1.0, ^5.0.3 | GPS & location services |
| **Charts** | fl_chart | ^0.66.2 | Data visualization |
| **Animations** | animate_do | ^3.3.4 | Smooth UI animations |
| **Icons** | font_awesome_flutter | ^10.7.0 | Comprehensive icon library |
| **HTTP** | http | ^1.1.2 | API communication |
| **Security** | flutter_secure_storage | ^10.0.0 | Secure token storage |
| **Encryption** | encrypt, crypto | ^5.0.3, ^3.0.3 | Data encryption |
| **Storage** | shared_preferences | ^2.2.2 | Local data persistence |
| **Files** | file_picker, image_picker | ^8.0.0, ^1.1.0 | Document & image handling |
| **Notifications** | firebase_messaging | ^16.1.1 | Push notifications |

### 🔧 Backend API (Node.js)

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| **Runtime** | Node.js | 16+ | JavaScript runtime |
| **Framework** | Express.js | ^4.18.2 | Web framework |
| **Database** | PostgreSQL | 12+ | Relational database |
| **Query Builder** | Knex.js | ^3.1.0 | SQL query builder & migrations |
| **Authentication** | jsonwebtoken | ^9.0.2 | JWT token generation |
| **Password** | bcrypt | ^5.1.1 | Password hashing |
| **Validation** | express-validator | ^7.0.1 | Input validation & sanitization |
| **Real-time** | Socket.io | ^4.8.3 | WebSocket for live updates |
| **File Upload** | Multer | ^2.0.2 | Multipart file handling |
| **Email** | Nodemailer | ^7.0.13 | Email service |
| **CORS** | cors | ^2.8.5 | Cross-origin resource sharing |
| **Environment** | dotenv | ^16.3.1 | Environment variable management |
| **Testing** | Jest, Supertest | ^30.2.0, ^7.2.2 | Unit & integration testing |

### 💻 Admin Dashboard (React)

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| **Framework** | React | ^19.2.0 | UI library |
| **Build Tool** | Vite | ^7.2.4 | Fast build & hot reload |
| **Styling** | Tailwind CSS | ^4.1.18 | Utility-first CSS framework |
| **Routing** | React Router DOM | ^7.12.0 | Client-side routing |
| **Charts** | Recharts | ^3.6.0 | Data visualization |
| **Icons** | Lucide React | ^0.562.0 | Icon library |
| **Date** | date-fns | ^4.1.0 | Date manipulation |
| **Linting** | ESLint | ^9.39.1 | Code quality |

---

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (^3.9.2) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Node.js** (v16+) - [Download Node.js](https://nodejs.org/)
- **PostgreSQL** (v12+) - [Download PostgreSQL](https://www.postgresql.org/download/)
- **Git** - [Install Git](https://git-scm.com/)
- **Google Maps API Key** - [Get API Key](https://console.cloud.google.com/)

### Installation Steps

#### 1️⃣ Clone the Repository

```bash
git clone https://github.com/punithsai18/sePro.git
cd sePro
```

#### 2️⃣ Setup Backend Server

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create environment configuration
cp .env.example .env

# Edit .env file with your database credentials
# Update DB_PASSWORD if needed

# Initialize database (creates tables and schema)
npm run init-db

# Start the backend server
npm start
```

The backend server will start on `http://localhost:5000`

**Backend Environment Variables (`.env`):**
```env
# Server Configuration
PORT=5000
NODE_ENV=development

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ecoride_db
DB_USER=postgres
DB_PASSWORD=your_password_here

# JWT Configuration
JWT_SECRET=your_jwt_secret_here
JWT_REFRESH_SECRET=your_refresh_secret_here
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# Email Configuration (for 2FA)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password

# Encryption
ENCRYPTION_KEY=your_32_character_encryption_key
```

#### 3️⃣ Setup Flutter Mobile App

```bash
# Navigate back to root directory
cd ..

# Install Flutter dependencies
flutter pub get

# Copy environment example
cp .env.example .env

# Add your Google Maps API key to .env
echo "GOOGLE_MAPS_API_KEY=your_api_key_here" >> .env

# For Android: Update android/app/src/main/AndroidManifest.xml
# Add: <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY"/>

# For iOS: Update ios/Runner/AppDelegate.swift
# Add: GMSServices.provideAPIKey("YOUR_KEY")

# For Web: Update web/index.html
# Add Google Maps script with your API key

# Run the app
flutter run              # For mobile
flutter run -d chrome    # For web
```

#### 4️⃣ Setup Admin Dashboard

```bash
# Navigate to admin directory
cd admin

# Install dependencies
npm install

# Create environment configuration
cp .env.example .env

# Start development server
npm run dev
```

The admin dashboard will start on `http://localhost:5173`

**Admin Environment Variables (`.env`):**
```env
VITE_API_URL=http://localhost:5000
```

### Quick Test

1. **Test Backend Health:**
   ```bash
   curl http://localhost:5000/health
   ```

2. **Open Flutter App:**
   - You should see the landing page
   - Click "Get Started"
   - Register as a Rider or Driver

3. **Open Admin Dashboard:**
   - Navigate to `http://localhost:5173`
   - Login with admin credentials (created during `npm run init-db`)

---

## 📱 Application Components

### 1. Flutter Mobile App

The mobile application is the primary user interface for riders and drivers.

**Key Directories:**
- `lib/screens/` - All app screens (20+ screens)
- `lib/widgets/` - Reusable UI components
- `lib/services/` - API communication and business logic
- `lib/providers/` - State management with Provider
- `lib/models/` - Data structures and models
- `lib/theme/` - Design system and theming
- `lib/utils/` - Helper functions and utilities

**User Flows:**

**Rider Flow:**
1. Landing → Sign Up (Rider) → Profile Setup
2. Enter locations → Choose preferences → Select pool option
3. Track driver → View ETA → Complete ride
4. Rate experience → View updated eco score

**Driver Flow:**
1. Landing → Sign Up (Driver) → Upload documents → Await approval
2. Accept ride request → Navigate to pickup
3. Follow turn-by-turn navigation → Handle route changes
4. Complete ride → Confirm and rate

### 2. Backend API Server

The backend provides RESTful APIs and real-time communication.

**Key Features:**
- 66+ API endpoints organized by domain
- JWT authentication with refresh tokens
- Two-factor authentication (2FA) via email
- Real-time notifications with Socket.io
- File upload handling (documents, profile photos)
- Input validation and sanitization
- Error handling and logging
- Database transactions with rollback
- Rate limiting and security headers

**API Endpoint Categories:**
- `/api/auth/*` - Authentication (signup, login, 2FA)
- `/api/users/*` - User management
- `/api/rides/*` - Ride operations (book, track, complete)
- `/api/drivers/*` - Driver-specific operations
- `/api/bookings/*` - Booking management
- `/api/messages/*` - Chat and messaging
- `/api/notifications/*` - Push notifications
- `/api/admin/*` - Admin operations

**Database Schema:**
- `users` - User accounts (riders, drivers, admins)
- `rides` - Ride records and history
- `bookings` - Booking transactions
- `drivers` - Driver profiles and documents
- `vehicles` - Vehicle information
- `messages` - Chat messages
- `conversations` - Message threads
- `notifications` - User notifications
- `user_encryption` - Encrypted sensitive data
- `two_factor_codes` - 2FA verification codes

### 3. React Admin Dashboard

Web-based dashboard for administrators to manage the platform.

**Pages:**
1. **Dashboard** - Overview with key metrics and charts
2. **Users** - List, search, edit, and manage users
3. **Drivers** - Approve/reject driver applications
4. **Rides** - Monitor all rides in real-time
5. **Bookings** - View and manage bookings
6. **Revenue** - Financial analytics and reports
7. **Vehicles** - Fleet management
8. **Notifications** - Send system-wide announcements
9. **Settings** - App configuration and preferences
10. **Reports** - Export data in CSV/PDF

**Features:**
- Real-time updates with auto-refresh
- Search and filter capabilities
- Data export functionality
- Responsive design for all screen sizes
- Role-based access control
- Dark mode support

---

## 📂 Project Structure

```
sePro/
├── lib/                              # Flutter app source code
│   ├── main.dart                     # App entry point
│   ├── firebase_options.dart         # Firebase configuration
│   ├── models/                       # Data models
│   │   └── ride_models.dart         # All travel-related models
│   ├── providers/                    # State management
│   │   ├── auth_provider.dart       # Authentication state
│   │   ├── ride_provider.dart       # Ride booking state
│   │   └── theme_provider.dart      # Theme state
│   ├── screens/                      # App screens (20+)
│   │   ├── rideshare/               # Ride-sharing screens
│   │   │   ├── landing_screen.dart
│   │   │   ├── auth_screen.dart
│   │   │   ├── ride_booking_screen.dart
│   │   │   ├── live_tracking_screen.dart
│   │   │   └── ...
│   │   ├── explore_screen.dart      # Main hub
│   │   ├── transportation_screen.dart
│   │   ├── hotels_screen.dart
│   │   └── ...
│   ├── services/                     # Business logic
│   │   ├── api_service.dart         # API communication
│   │   ├── auth_service.dart        # Authentication
│   │   ├── location_service.dart    # GPS services
│   │   └── encryption_service.dart  # Data encryption
│   ├── widgets/                      # Reusable components
│   │   ├── common_widgets.dart
│   │   ├── ride_card.dart
│   │   └── ...
│   ├── theme/                        # Design system
│   │   └── app_theme.dart           # Colors & theme config
│   └── utils/                        # Helper functions
│       ├── constants.dart
│       └── validators.dart
│
├── backend/                          # Node.js backend API
│   ├── src/
│   │   ├── server.js                # Server entry point
│   │   ├── controllers/             # Business logic
│   │   │   ├── authController.js
│   │   │   ├── rideController.js
│   │   │   ├── userController.js
│   │   │   └── ...
│   │   ├── routes/                  # API routes
│   │   │   ├── authRoutes.js
│   │   │   ├── rideRoutes.js
│   │   │   └── ...
│   │   ├── services/                # Database operations
│   │   │   ├── authService.js
│   │   │   ├── rideService.js
│   │   │   └── ...
│   │   ├── middleware/              # Express middleware
│   │   │   ├── auth.js             # JWT verification
│   │   │   ├── validation.js       # Input validation
│   │   │   └── errorHandler.js     # Error handling
│   │   ├── config/                  # Configuration
│   │   │   ├── database.js         # DB connection
│   │   │   ├── initDatabase.js     # Schema setup
│   │   │   └── migrate*.js         # Migrations
│   │   └── utils/                   # Utilities
│   │       ├── encryption.js
│   │       └── email.js
│   ├── tests/                       # Test suites
│   │   ├── unit/                    # Unit tests
│   │   └── integration/             # Integration tests
│   ├── .env.example                 # Environment template
│   ├── package.json                 # Dependencies
│   └── README.md                    # Backend docs
│
├── admin/                            # React admin dashboard
│   ├── src/
│   │   ├── App.jsx                  # Main app component
│   │   ├── main.jsx                 # Entry point
│   │   ├── pages/                   # Dashboard pages
│   │   │   ├── Dashboard.jsx
│   │   │   ├── Users.jsx
│   │   │   ├── Drivers.jsx
│   │   │   └── ...
│   │   ├── components/              # Reusable UI
│   │   │   ├── Sidebar.jsx
│   │   │   ├── Navbar.jsx
│   │   │   └── ...
│   │   ├── contexts/                # React Context
│   │   │   └── AuthContext.jsx
│   │   ├── services/                # API calls
│   │   │   └── api.js
│   │   └── styles/                  # CSS files
│   ├── public/                      # Static assets
│   ├── .env.example                 # Environment template
│   ├── package.json                 # Dependencies
│   ├── tailwind.config.js           # Tailwind config
│   ├── vite.config.js               # Vite config
│   └── README.md                    # Admin docs
│
├── android/                          # Android-specific code
├── ios/                              # iOS-specific code
├── web/                              # Web-specific code
├── test/                             # Flutter tests
├── assests/                          # App assets (images, etc.)
│
├── Documentation Files (146 .md files)
│   ├── BACKEND_SETUP.md             # Backend setup guide
│   ├── GOOGLE_MAPS_SETUP.md         # Maps configuration
│   ├── API_TESTING_QUICK_REF.md     # API testing guide
│   ├── 2FA_IMPLEMENTATION.md        # 2FA details
│   ├── ENCRYPTION_README.md         # Encryption guide
│   ├── SECURITY_SUMMARY.md          # Security overview
│   └── ... (140+ more docs)
│
├── pubspec.yaml                      # Flutter dependencies
├── package.json                      # Root package file
├── .env.example                      # Environment template
├── .gitignore                        # Git ignore rules
├── firebase.json                     # Firebase config
├── postman_collection.json           # API testing collection
└── README.md                         # This file
```

---

## 🔒 Security

EcoRide implements multiple layers of security to protect user data and ensure platform integrity.

### Authentication & Authorization
- **JWT Tokens** - Secure token-based authentication with refresh tokens
- **Two-Factor Authentication (2FA)** - Email-based verification codes
- **Password Security** - Bcrypt hashing with salt (10 rounds)
- **Role-Based Access Control (RBAC)** - Separate permissions for riders, drivers, and admins
- **Token Refresh** - Automatic token renewal without re-login
- **Session Management** - Secure session handling with expiration

### Data Protection
- **AES-256 Encryption** - Sensitive user data encrypted at rest
- **HTTPS/TLS** - All communications encrypted in transit (production)
- **Secure Storage** - Flutter Secure Storage for tokens on mobile
- **Environment Variables** - Secrets stored in `.env` files (never committed)
- **SQL Injection Prevention** - Parameterized queries with Knex.js
- **XSS Protection** - Input sanitization and output encoding

### API Security
- **Input Validation** - express-validator for all endpoints
- **Rate Limiting** - Prevent brute force and DoS attacks
- **CORS Configuration** - Restrict cross-origin requests
- **Security Headers** - Helmet.js for security headers
- **File Upload Validation** - File type and size restrictions
- **Error Handling** - Generic error messages to prevent information leakage

### Privacy & Compliance
- **Data Minimization** - Only collect necessary data
- **User Consent** - Explicit permission for location and data usage
- **Data Retention** - Automatic cleanup of old data
- **Right to Delete** - Users can request account deletion
- **Audit Logging** - Track all security-relevant events
- **Incident Reporting** - Comprehensive logging for security incidents

### Best Practices
- Regular security audits
- Dependency updates for vulnerabilities
- Code reviews for security issues
- Secure deployment configurations
- Database backups and disaster recovery
- Monitoring and alerting for suspicious activities

**Security Documentation:**
- [SECURITY_SUMMARY.md](SECURITY_SUMMARY.md) - Complete security overview
- [ENCRYPTION_README.md](ENCRYPTION_README.md) - Encryption implementation
- [2FA_IMPLEMENTATION.md](2FA_IMPLEMENTATION.md) - Two-factor auth details
- [PASSWORD_HASHING_SECURITY.md](PASSWORD_HASHING_SECURITY.md) - Password security

---

## 📖 API Documentation

The backend provides **66+ RESTful API endpoints** organized by functionality.

### Base URL
- **Development:** `http://localhost:5000`
- **Production:** `https://your-domain.com`

### Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/signup` | Register new user | No |
| POST | `/api/auth/login` | User login | No |
| POST | `/api/auth/refresh` | Refresh JWT token | Yes (Refresh Token) |
| POST | `/api/auth/logout` | User logout | Yes |
| POST | `/api/auth/verify-2fa` | Verify 2FA code | No |
| POST | `/api/auth/resend-2fa` | Resend 2FA code | No |
| POST | `/api/auth/forgot-password` | Request password reset | No |
| POST | `/api/auth/reset-password` | Reset password | No |

### User Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/users/profile` | Get user profile | Yes |
| PUT | `/api/users/profile` | Update profile | Yes |
| POST | `/api/users/upload-document` | Upload document | Yes |
| POST | `/api/users/upload-photo` | Upload profile photo | Yes |
| GET | `/api/users/:id` | Get user by ID | Yes (Admin) |
| GET | `/api/users` | List all users | Yes (Admin) |
| DELETE | `/api/users/:id` | Delete user | Yes (Admin) |

### Ride Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/rides` | Create ride request | Yes |
| GET | `/api/rides/:id` | Get ride details | Yes |
| PUT | `/api/rides/:id` | Update ride | Yes |
| DELETE | `/api/rides/:id` | Cancel ride | Yes |
| GET | `/api/rides` | List rides | Yes |
| POST | `/api/rides/:id/complete` | Complete ride | Yes (Driver) |
| POST | `/api/rides/:id/rate` | Rate ride | Yes |
| GET | `/api/rides/:id/location` | Get real-time location | Yes |

### Driver Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/drivers/apply` | Apply to be driver | Yes |
| GET | `/api/drivers/:id` | Get driver details | Yes |
| PUT | `/api/drivers/:id/approve` | Approve driver | Yes (Admin) |
| PUT | `/api/drivers/:id/reject` | Reject driver | Yes (Admin) |
| GET | `/api/drivers/available` | Get available drivers | Yes |
| PUT | `/api/drivers/status` | Update driver status | Yes (Driver) |

### Booking Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/bookings` | Create booking | Yes |
| GET | `/api/bookings/:id` | Get booking details | Yes |
| PUT | `/api/bookings/:id` | Update booking | Yes |
| DELETE | `/api/bookings/:id` | Cancel booking | Yes |
| GET | `/api/bookings/history` | Get booking history | Yes |

### Notification Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/notifications` | Get user notifications | Yes |
| PUT | `/api/notifications/:id/read` | Mark as read | Yes |
| DELETE | `/api/notifications/:id` | Delete notification | Yes |
| POST | `/api/notifications/broadcast` | Send to all users | Yes (Admin) |

### Admin Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/admin/dashboard` | Get dashboard stats | Yes (Admin) |
| GET | `/api/admin/analytics` | Get analytics data | Yes (Admin) |
| GET | `/api/admin/reports` | Generate reports | Yes (Admin) |
| POST | `/api/admin/settings` | Update app settings | Yes (Admin) |

### Request/Response Examples

**Create Ride Request:**
```json
POST /api/rides
Authorization: Bearer <jwt_token>

{
  "pickupLocation": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "address": "123 Main St, New York, NY"
  },
  "dropoffLocation": {
    "latitude": 40.7589,
    "longitude": -73.9851,
    "address": "456 Park Ave, New York, NY"
  },
  "rideType": "pool",
  "vehiclePreference": "ev",
  "passengerCount": 2,
  "scheduledTime": "2024-03-15T14:30:00Z"
}

Response: 201 Created
{
  "success": true,
  "data": {
    "rideId": "rid_abc123",
    "status": "pending",
    "estimatedFare": 15.50,
    "estimatedDuration": 20,
    "carbonSaved": 0.8,
    "createdAt": "2024-03-15T14:25:00Z"
  }
}
```

**Postman Collection:**
Import `postman_collection.json` for complete API testing with examples.

**Full API Documentation:**
- [POSTMAN_API_URLS.md](POSTMAN_API_URLS.md) - Complete endpoint list
- [API_TESTING_QUICK_REF.md](API_TESTING_QUICK_REF.md) - Quick reference guide
- [BACKEND_INTEGRATION_GUIDE.md](BACKEND_INTEGRATION_GUIDE.md) - Integration details

---

## 🧪 Testing

The project includes comprehensive testing for backend APIs.

### Backend Testing

**Test Coverage:**
- **200+ Unit Tests** - Individual function testing
- **50+ Integration Tests** - API endpoint testing
- **Controllers** - Business logic validation
- **Services** - Database operations
- **Middleware** - Auth, validation, error handling
- **Utilities** - Helper functions

**Running Tests:**

```bash
# Navigate to backend directory
cd backend

# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage report
npm run test:coverage

# Run specific test file
npm test -- authController.test.js
```

**Test Structure:**
```
backend/tests/
├── unit/
│   ├── controllers/
│   │   ├── authController.test.js
│   │   ├── rideController.test.js
│   │   └── ...
│   ├── services/
│   │   ├── authService.test.js
│   │   └── ...
│   └── utils/
│       ├── encryption.test.js
│       └── ...
├── integration/
│   ├── auth.test.js
│   ├── rides.test.js
│   └── ...
└── setup.js
```

**Testing Technologies:**
- **Jest** - Testing framework
- **Supertest** - HTTP assertions
- **babel-jest** - ES6 module support
- **@types/jest** - TypeScript definitions

**Test Documentation:**
- [TESTING_GUIDE.md](backend/TESTING_GUIDE.md) - Complete testing guide
- [backend/tests/unit/controllers/README.md](backend/tests/unit/controllers/README.md) - Controller tests

### Flutter Testing

```bash
# Run Flutter tests
flutter test

# Run with coverage
flutter test --coverage
```

### Manual Testing

**Testing Checklist:**
1. ✅ User registration and login
2. ✅ 2FA verification flow
3. ✅ Ride booking and cancellation
4. ✅ Real-time location tracking
5. ✅ Driver navigation
6. ✅ Rating and feedback
7. ✅ Admin dashboard access
8. ✅ File upload (documents, photos)
9. ✅ Notification system
10. ✅ Payment flow (if implemented)

---

## 🎨 Design System

EcoRide uses a **modern, eco-friendly design system** with a dark theme.

### Color Palette

**Primary Colors:**
- `#30e87a` - Vibrant eco green (Primary)
- `#2E7D32` - Dark green (Secondary)
- `#4CAF50` - Light green (Accent)

**UI Colors:**
- `#112117` - Background (Deep dark green-black)
- `#1c2620` - Surface (Card backgrounds)
- `#2a3b31` - Surface variant
- `#FFFFFF` - On surface (Text)
- `#B0BEC5` - On surface variant (Secondary text)

**Functional Colors:**
- `#1976D2` - Information (Blue)
- `#388E3C` - Success (Green)
- `#F57C00` - Warning (Orange)
- `#D32F2F` - Error (Red)

**Category Colors:**
- `#1976D2` - Transportation (Blue)
- `#7B1FA2` - Hotels (Purple)
- `#E65100` - Restaurants (Orange)
- `#C62828` - Experiences (Red)
- `#388E3C` - Guides (Green)
- `#F9A825` - Eco certifications (Gold)

### Typography

**Font Family:** System default (San Francisco / Roboto)

**Text Styles:**
- **Display Large** - 57px / Bold / For hero sections
- **Headline Large** - 32px / Bold / Page titles
- **Title Large** - 22px / Medium / Section headers
- **Body Large** - 16px / Regular / Main content
- **Body Medium** - 14px / Regular / Secondary content
- **Label Large** - 14px / Medium / Buttons, chips

### Components

**Buttons:**
- Primary: Filled with eco green background
- Secondary: Outlined with green border
- Text: Text-only buttons
- Icon: Icon buttons with touch feedback

**Cards:**
- Elevated: Shadow elevation with rounded corners (16px radius)
- Filled: Solid background with subtle border
- Outlined: Border with transparent background

**Navigation:**
- Bottom Navigation Bar - 4-5 main tabs
- Drawer - Side navigation for additional options
- App Bar - Top bar with title and actions

**Forms:**
- Text Fields: Outlined with focus states
- Dropdowns: Material dropdown with search
- Checkboxes/Radio: Material design
- Switches: Material toggle switches

### Spacing System

- **XXS:** 4px
- **XS:** 8px
- **S:** 12px
- **M:** 16px (Base unit)
- **L:** 24px
- **XL:** 32px
- **XXL:** 48px

### Icons

- **Font Awesome Flutter** - 10,000+ icons
- **Material Icons** - Native Material icons
- Consistent 24px size for UI elements

### Animations

- **Fade In/Out** - animate_do package
- **Slide Animations** - For page transitions
- **Loading Indicators** - Circular progress with green color
- **Micro-interactions** - Button press, card tap feedback

---

## 📚 Documentation

EcoRide includes **146+ documentation files** covering every aspect of the platform.

### Setup & Configuration

| Document | Description |
|----------|-------------|
| [BACKEND_SETUP.md](BACKEND_SETUP.md) | Backend server setup guide |
| [GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md) | Google Maps API configuration |
| [DATABASE_SETUP.md](DATABASE_SETUP.md) | PostgreSQL database setup |
| [FIREBASE_SETUP.md](FIREBASE_SETUP.md) | Firebase configuration |
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | Complete setup instructions |
| [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) | Build and deployment |
| [BUILD_APK_GUIDE.md](BUILD_APK_GUIDE.md) | Android APK building |

### Features & Implementation

| Document | Description |
|----------|-------------|
| [CARPOOL_IMPLEMENTATION_COMPLETE.md](CARPOOL_IMPLEMENTATION_COMPLETE.md) | Ride pooling feature |
| [2FA_IMPLEMENTATION.md](2FA_IMPLEMENTATION.md) | Two-factor authentication |
| [ENCRYPTION_IMPLEMENTATION.md](ENCRYPTION_IMPLEMENTATION.md) | Data encryption details |
| [LIVE_NOTIFICATIONS_IMPLEMENTATION.md](LIVE_NOTIFICATIONS_IMPLEMENTATION.md) | Real-time notifications |
| [CHAT_AND_NAVIGATION_IMPLEMENTATION.md](CHAT_AND_NAVIGATION_IMPLEMENTATION.md) | Chat & navigation |
| [DRIVER_NAVIGATION_IMPLEMENTATION.md](DRIVER_NAVIGATION_IMPLEMENTATION.md) | Driver features |
| [PROFILE_SETUP_IMPLEMENTATION.md](PROFILE_SETUP_IMPLEMENTATION.md) | User profile system |

### Security

| Document | Description |
|----------|-------------|
| [SECURITY_SUMMARY.md](SECURITY_SUMMARY.md) | Complete security overview |
| [PASSWORD_HASHING_SECURITY.md](PASSWORD_HASHING_SECURITY.md) | Password security |
| [ENCRYPTION_README.md](ENCRYPTION_README.md) | Encryption guide |
| [SECURITY_REVIEW_SUMMARY.md](SECURITY_REVIEW_SUMMARY.md) | Security audit |

### Testing & API

| Document | Description |
|----------|-------------|
| [API_TESTING_QUICK_REF.md](API_TESTING_QUICK_REF.md) | API testing quick reference |
| [POSTMAN_API_URLS.md](POSTMAN_API_URLS.md) | Complete API documentation |
| [BACKEND_INTEGRATION_GUIDE.md](BACKEND_INTEGRATION_GUIDE.md) | Backend integration |
| [backend/TESTING_GUIDE.md](backend/TESTING_GUIDE.md) | Testing guide |

### Troubleshooting

| Document | Description |
|----------|-------------|
| [QUICK_FIX_GUIDE.md](QUICK_FIX_GUIDE.md) | Common issues and fixes |
| [EMAIL_TROUBLESHOOTING.md](EMAIL_TROUBLESHOOTING.md) | Email configuration issues |
| [DATABASE_ERROR_FIX.md](DATABASE_ERROR_FIX.md) | Database troubleshooting |
| [MIGRATION_ERROR_FIX.md](MIGRATION_ERROR_FIX.md) | Migration issues |

### Visual Guides

| Document | Description |
|----------|-------------|
| [UI_CHANGES_VISUAL_GUIDE.md](UI_CHANGES_VISUAL_GUIDE.md) | UI screenshots and changes |
| [CARPOOL_VISUAL_GUIDE.md](CARPOOL_VISUAL_GUIDE.md) | Carpool feature visuals |
| [COMPLETE_FLOW_DIAGRAM.md](COMPLETE_FLOW_DIAGRAM.md) | System flow diagrams |
| [CRASH_FIX_VISUALIZATION.md](CRASH_FIX_VISUALIZATION.md) | Bug fix examples |

### Quick Reference

| Document | Description |
|----------|-------------|
| [QUICK_START.md](QUICK_START.md) | Get started quickly |
| [QUICK_REFERENCE_CARD.md](QUICK_REFERENCE_CARD.md) | Command reference |
| [DEFAULT_LOGIN_CREDENTIALS.md](DEFAULT_LOGIN_CREDENTIALS.md) | Test accounts |

---

## 🤝 Contributing

We welcome contributions to EcoRide! Here's how you can help:

### Getting Started

1. **Fork the repository**
   ```bash
   gh repo fork punithsai18/sePro
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/sePro.git
   cd sePro
   ```

3. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make your changes**
   - Follow the existing code style
   - Write clear commit messages
   - Add tests for new features
   - Update documentation

5. **Test your changes**
   ```bash
   # Test Flutter app
   flutter test
   
   # Test backend
   cd backend && npm test
   ```

6. **Commit and push**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your fork and branch
   - Describe your changes clearly

### Code Style

**Flutter/Dart:**
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format .` before committing
- Use meaningful variable names
- Add comments for complex logic

**JavaScript/Node.js:**
- Follow [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- Use ES6+ features
- Use async/await over callbacks
- Handle errors properly

**React/JSX:**
- Use functional components with hooks
- Follow [React Best Practices](https://react.dev/learn)
- Use proper component structure
- Implement proper prop types

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new feature
fix: bug fix
docs: documentation changes
style: code style changes (formatting, etc.)
refactor: code refactoring
test: add or update tests
chore: maintenance tasks
```

### Areas for Contribution

- 🐛 **Bug Fixes** - Fix reported issues
- ✨ **New Features** - Add new functionality
- 📝 **Documentation** - Improve docs and guides
- 🧪 **Testing** - Add more test coverage
- 🎨 **UI/UX** - Enhance user interface
- 🔒 **Security** - Improve security measures
- ♿ **Accessibility** - Make app more accessible
- 🌍 **Internationalization** - Add language support

### Reporting Issues

When reporting issues, please include:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if applicable)
- Environment details (OS, Flutter version, etc.)

---

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2024 EcoRide Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👥 Team & Acknowledgments

### Project Team
Built with passion for sustainable mobility and environmental impact by the Software Engineering Project Team.

### Special Thanks
- **Flutter Team** - For the amazing cross-platform framework
- **Node.js Community** - For robust backend tools
- **React Team** - For the excellent UI library
- **PostgreSQL** - For the reliable database
- **Open Source Community** - For countless packages and libraries

### Technology Credits
- [Flutter](https://flutter.dev) - UI framework
- [Express.js](https://expressjs.com) - Web framework
- [React](https://react.dev) - UI library
- [PostgreSQL](https://www.postgresql.org) - Database
- [Google Maps](https://developers.google.com/maps) - Maps & location
- [Socket.io](https://socket.io) - Real-time communication
- [Tailwind CSS](https://tailwindcss.com) - CSS framework

---

## 📞 Support & Contact

### Getting Help

- **📖 Documentation** - Check the 146+ docs for detailed guides
- **🐛 Issues** - Report bugs on [GitHub Issues](https://github.com/punithsai18/sePro/issues)
- **💬 Discussions** - Ask questions on GitHub Discussions
- **📧 Email** - Contact the team for urgent matters

### Quick Links

- 🌐 **Repository:** [github.com/punithsai18/sePro](https://github.com/punithsai18/sePro)
- 📦 **Postman Collection:** [Import API Collection](postman_collection.json)
- 📚 **API Docs:** [POSTMAN_API_URLS.md](POSTMAN_API_URLS.md)
- 🚀 **Quick Start:** [QUICK_START.md](QUICK_START.md)
- 🔧 **Backend Setup:** [BACKEND_SETUP.md](BACKEND_SETUP.md)

### Project Status

✅ **Production Ready** - All core features implemented and tested  
🚀 **Active Development** - Continuous improvements and new features  
📊 **Test Coverage** - 200+ unit and integration tests  
📖 **Well Documented** - 146+ documentation files  

---

## 🌟 Features Roadmap

### Completed ✅
- [x] Flutter mobile app (iOS, Android, Web)
- [x] Backend API with 66+ endpoints
- [x] Admin dashboard with real-time analytics
- [x] User authentication with JWT and 2FA
- [x] Ride booking and pooling
- [x] Live tracking and navigation
- [x] Carbon tracking and eco score
- [x] Gamification and rewards
- [x] Emergency SOS and safety features
- [x] File upload (documents, photos)
- [x] Real-time notifications (Socket.io)
- [x] Chat and messaging
- [x] Data encryption
- [x] Comprehensive testing
- [x] Complete documentation

### In Progress 🚧
- [ ] Payment gateway integration
- [ ] Advanced route optimization algorithms
- [ ] Social features and friend leaderboards
- [ ] Machine learning for demand prediction

### Planned 📋
- [ ] iOS and Android app store deployment
- [ ] Multi-language support (i18n)
- [ ] Accessibility improvements (WCAG 2.1)
- [ ] Offline mode with data sync
- [ ] Advanced analytics dashboard
- [ ] Augmented reality navigation
- [ ] Blockchain for credential verification
- [ ] Integration with public transport APIs
- [ ] Carbon offset marketplace
- [ ] Corporate accounts and fleet management

---

<div align="center">

## 🌱 EcoRide - Smart Rides, Greener Planet 🚗

**Built with ❤️ for a sustainable future**


---

*Making transportation sustainable, one ride at a time* 🌍

</div>
