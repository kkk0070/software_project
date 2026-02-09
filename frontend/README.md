# EcoRide - Intelligent Ride-Sharing & Sustainable Mobility Platform

A comprehensive Flutter-based ride-sharing platform designed to provide sustainable, eco-friendly transportation with integrated carbon tracking, pooling options, and gamification features.

## ⚠️ Important: Backend Server Setup Required

**Before running the app, you must start the backend server!** Otherwise, you'll encounter network errors like:
```
Network error: ClientException: Failed to fetch, uri=http://localhost:5000/api/auth/signup
```

**The app now automatically detects your platform (Web, Android, iOS) and connects to the correct backend URL!**

**Quick Fix:** Follow the [Backend Setup Guide](BACKEND_SETUP.md) to start the server in just 5 minutes.

**Quick Steps:**
1. Navigate to backend directory: `cd backend`
2. Install dependencies: `npm install`
3. Create configuration: `cp .env.example .env`
4. Initialize database: `npm run init-db`
5. Start server: `npm start`
6. Run app: `flutter run` (for mobile) or `flutter run -d chrome` (for web)

For detailed instructions, see [BACKEND_SETUP.md](BACKEND_SETUP.md).

## 🗺️ Google Maps API Setup Required

**The app uses Google Maps for location and navigation features!** You must configure your Google Maps API key before using map features.

**Quick Fix:** Follow the [Google Maps Setup Guide](GOOGLE_MAPS_SETUP.md) to configure your API key in just 5 minutes.

**Quick Steps:**
1. Get API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Maps SDK for Android, iOS, and Maps JavaScript API (for web)
3. Copy `.env.example` to `.env` and add your API key
4. Update `android/app/src/main/AndroidManifest.xml` with your key
5. Update `ios/Runner/AppDelegate.swift` with your key
6. Update `web/index.html` with your key

For detailed instructions, see [GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md).

## 🌍 Overview

EcoRide is a complete ride-sharing and sustainable mobility platform that prioritizes environmental impact while providing efficient transportation. The app features a modern dark-mode UI, comprehensive ride management, and extensive sustainability tracking.

## ✨ Key Features

### 🚗 Ride Management
- **Smart Ride Booking**: Map-based pickup and drop-off selection with EV and pooling preferences
- **Ride Pooling**: Cost-effective shared rides with carbon savings comparison
- **Live Tracking**: Real-time vehicle tracking with dynamic ETA updates
- **Driver Navigation**: Turn-by-turn navigation with traffic-aware routing
- **Route Optimization**: Dynamic rerouting and pickup sequence optimization

### 🌱 Sustainability Features
- **Carbon Tracking**: Monitor CO₂ emissions for every ride
- **Eco Score**: Personalized sustainability score with percentile ranking
- **Green Routes**: AI-powered eco-optimized route recommendations
- **EV Priority**: Preference for electric vehicle fleet
- **Impact Dashboard**: Visual representation of environmental contribution

### 🎮 Gamification & Rewards
- **Eco Points**: Earn points for sustainable ride choices
- **Badge System**: Unlock achievements (Eco Warrior, Pool Pro, EV Champion)
- **Milestones**: Track progress toward sustainability goals
- **Leaderboards**: Compare with other eco-conscious riders

### 🔒 Safety & Security
- **Emergency SOS**: Hold-to-activate emergency alert system
- **Live Location Sharing**: Share real-time location with contacts
- **Location Accuracy Monitoring**: GPS validation and anomaly detection
- **Privacy Controls**: Granular location permission management
- **Incident Logging**: Comprehensive safety event tracking

## 📱 Complete Screen List (18+ Screens)

1. **Landing Page** - Platform overview and authentication entry
2. **Authentication** - Login/register with rider/driver role selection
3. **User Profile** - Profile management and document upload
4. **Location Permissions** - GPS and privacy settings
5. **Ride Booking** - Interactive ride request with preferences
6. **Ride Pooling** - Multiple ride option comparison
7. **Live Tracking** - Real-time ride monitoring
8. **Driver Navigation** - Turn-by-turn guidance for drivers
9. **Route Optimization** - Dynamic route updates and alerts
10. **Location Accuracy** - GPS monitoring system features
11. **Ride History** - Past rides with detailed information
12. **Rating & Feedback** - Post-ride rating and review system
13. **Emergency** - SOS and safety features
14. **Sustainability Dashboard** - Carbon tracking and eco score
15. **Green Routes** - Eco-optimized route recommendations
16. **Rewards** - Gamification and achievement system
17. **Notifications** - Ride alerts and system updates
18. **Help & Support** - FAQs and customer support

## 🎨 Design System

- **Theme**: Modern dark mode with green accents
- **Primary Color**: `#30e87a` (Vibrant eco green)
- **Background**: `#112117` (Deep dark green-black)
- **Surface**: `#1c2620` (Card surfaces)
- **Typography**: Clean sans-serif with clear hierarchy
- **Components**: Rounded corners, subtle shadows, icon-based navigation

## 🛠️ Technical Stack

### Core Technologies
- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **Material Design 3**: UI framework
- **Provider**: State management (ready for integration)

### Key Dependencies
- `google_maps_flutter`: Map integration and visualization
- `location` & `geolocator`: GPS and location services
- `fl_chart`: Data visualization for sustainability metrics
- `animate_do`: Smooth animations and transitions
- `font_awesome_flutter`: Comprehensive icon set
- `file_picker` & `image_picker`: Document and image uploads

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.9.2)
- Dart SDK
- Android Studio / Xcode for mobile development
- Google Maps API key (for map features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/punithsai18/sePro.git
   cd sePro
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API keys**
   - Add Google Maps API key to `android/app/src/main/AndroidManifest.xml`
   - Add API key to `ios/Runner/AppDelegate.swift`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
├── theme/
│   └── app_theme.dart                # Theme configuration & colors
├── screens/
│   ├── rideshare/                    # All ride-sharing screens
│   │   ├── landing_screen.dart       # Landing page
│   │   ├── auth_screen.dart          # Authentication
│   │   ├── rideshare_home_screen.dart # Main navigation
│   │   ├── ride_booking_screen.dart  # Ride booking
│   │   ├── ride_pooling_screen.dart  # Pooling options
│   │   ├── live_tracking_screen.dart # Live tracking
│   │   ├── driver_navigation_screen.dart # Driver nav
│   │   ├── route_optimization_screen.dart # Route updates
│   │   ├── location_accuracy_screen.dart # GPS monitoring
│   │   ├── ride_history_screen.dart  # Ride history
│   │   ├── ride_rating_screen.dart   # Rating & feedback
│   │   ├── emergency_screen.dart     # Emergency & SOS
│   │   ├── sustainability_dashboard_screen.dart # Eco dashboard
│   │   ├── green_route_screen.dart   # Green routes
│   │   ├── rewards_screen.dart       # Rewards & badges
│   │   ├── notifications_screen.dart # Notifications
│   │   ├── help_support_screen.dart  # Help & support
│   │   ├── user_profile_screen.dart  # User profile
│   │   └── location_permission_screen.dart # Location settings
│   └── [other screens...]            # Legacy travel screens
├── widgets/                          # Reusable widgets
├── models/                           # Data models
└── utils/                            # Utility functions
```

## 🔄 User Flows

### Rider Journey
1. **Onboarding**: Landing → Sign Up (select Rider) → Profile Setup
2. **Book Ride**: Enter locations → Choose preferences → Select pool option
3. **During Ride**: Track driver → View ETA → Access emergency if needed
4. **After Ride**: Rate experience → View updated eco score
5. **Review Impact**: Check sustainability dashboard → Earn rewards

### Driver Journey
1. **Onboarding**: Landing → Sign Up (select Driver) → Upload documents
2. **Accept Ride**: View ride request → Accept → Navigate to pickup
3. **During Ride**: Follow navigation → Handle route changes
4. **Complete Ride**: Drop off passenger → Confirm completion
5. **Optimize**: View route optimization for pooled rides

## 🌟 Key Highlights

✅ **18+ fully functional screens** with complete navigation
✅ **Dark mode UI** with modern design system
✅ **Sustainability-first** approach with carbon tracking
✅ **Dual roles** supporting both riders and drivers
✅ **Gamification** to encourage eco-friendly behavior
✅ **Safety features** including emergency SOS
✅ **Location privacy** with granular controls
✅ **Route optimization** for efficiency and savings

## 📊 Sustainability Impact

- Track carbon emissions per ride
- Compare eco-friendly route options
- Incentivize ride pooling with cost savings
- Prioritize EV fleet access
- Visualize cumulative environmental impact
- Gamify sustainable transportation choices

## 🔐 Privacy & Security

- Encrypted location data
- Granular permission controls
- No third-party data sharing without consent
- Emergency contact system
- Incident logging and reporting
- Fraud prevention in ratings

## 📈 Backend API

✅ **Backend API integration completed!**

The project now includes a complete Node.js + Express + PostgreSQL backend with:
- RESTful API endpoints for CRUD operations
- PostgreSQL database with 8 tables
- API service layer for admin dashboard
- Comprehensive documentation

See [BACKEND_INTEGRATION_GUIDE.md](BACKEND_INTEGRATION_GUIDE.md) for setup instructions.

## 📈 Future Enhancements

- [x] Backend API integration
- [ ] Real-time map implementation
- [ ] Payment gateway integration
- [ ] Push notification service
- [ ] In-app chat between rider and driver
- [ ] Advanced route optimization algorithms
- [ ] Social features and leaderboards
- [ ] Multi-language support
- [ ] Accessibility improvements
- [ ] iOS and Android deployment

## 📄 Documentation

For detailed implementation information:
- [RIDESHARE_IMPLEMENTATION.md](RIDESHARE_IMPLEMENTATION.md) - Flutter app details
- [ADMIN_DASHBOARD_SUMMARY.md](ADMIN_DASHBOARD_SUMMARY.md) - Admin dashboard details
- [BACKEND_INTEGRATION_GUIDE.md](BACKEND_INTEGRATION_GUIDE.md) - Backend setup and integration

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

Built with passion for sustainable mobility and environmental impact.

---

**EcoRide** - Smart Rides, Greener Planet 🌱🚗

### All-in-One Travel Platform
- **Transportation Hub**: Book flights, trains, buses, and EV rides with carbon footprint tracking
- **Hotel Booking**: Discover eco-friendly hotels with green certifications
- **Restaurant Discovery**: Find local restaurants with vegan and organic options
- **Travel Guides**: Connect with certified local experts
- **Experiences & Activities**: Book tours, adventures, and cultural experiences
- **Trip Planner**: Create smart day-wise itineraries with budget tracking

### Low-Carbon Footprint Solutions
- **Carbon Tracking**: Monitor CO₂ emissions for all travel modes
- **Eco-Friendly Options**: Filter for EVs, public transport, green hotels, and sustainable experiences
- **Green Certifications**: Hotels rated Gold, Silver, Bronze for environmental practices
- **Impact Dashboard**: Visualize your environmental contribution
- **Sustainable Choices**: Incentivize eco-friendly travel decisions

### Comfort & Safety Features
- **Real-time Weather**: Current conditions integrated into home screen
- **Language Translation**: Essential phrases with pronunciation guide in multiple languages
- **Emergency Support**: SOS button with emergency contacts and local numbers
- **Safety Tips**: Location-specific safety recommendations
- **Nearby Hospitals**: Quick access to medical facilities

### Smart Personalization & Planner
- **Month-wise Suggestions**: Best destinations for current month
- **Adaptive Itineraries**: Day-by-day trip planning with activities and budget
- **Personalized Recommendations**: Based on preferences and eco-score
- **Budget Planning**: Track expenses across accommodation, transport, and activities
- **Multi-category Search**: Unified search across all travel services

## 📱 App Screens

### Main Navigation Screens

1. **Explore Screen** (Main Hub) - **ENHANCED**
   - Personalized greeting with quick stats (Eco Score, Trips, CO₂ Saved)
   - Interactive notification bell with badge
   - Modern search bar with filter options
   - Promotional banner for special offers
   - Categorized travel services
   - Planning & tools horizontal scroll
   - Support & safety shortcuts
   - Popular destinations with "See all" navigation

2. **Transportation Hub**
   - Multi-modal transport (Flights, Trains, Buses, EVs)
   - Carbon emission comparison
   - Eco-friendly filter toggle
   - Real-time pricing
   - Transport mode switching

3. **Hotels Screen**
   - Search by location and dates
   - Eco-friendly certification filter
   - Green hotel ratings (Gold/Silver/Bronze)
   - Amenities and reviews
   - Price comparison

4. **Restaurants Screen**
   - Cuisine filters
   - Vegan & organic options
   - Distance and ratings
   - Local dining discovery
   - Dietary preferences

5. **Travel Guides Screen**
   - Certified local experts
   - Multi-language support
   - Specialization filters
   - Reviews and experience
   - Day-rate booking

6. **Experiences & Activities**
   - Adventure, cultural, nature activities
   - Eco-friendly experiences
   - Grid layout with categories
   - Duration and pricing
   - Rating system

7. **Trip Planner**
   - Day-wise itinerary builder
   - Budget breakdown by category
   - Activity timeline
   - Expense tracking
   - Save and share trips

8. **Emergency Support**
   - SOS button with hold-to-activate
   - Emergency contacts management
   - Local emergency numbers by location
   - Nearby hospitals
   - Safety tips

9. **Language Helper**
   - Common phrases translation
   - Category-based phrases (Food, Directions, Emergency)
   - Pronunciation guide
   - Text-to-speech
   - Multiple languages

10. **Book Ride Screen** (Enhanced)
    - Location picker
    - Ride type selection (Solo/Pool/EV)
    - Passenger count
    - Schedule options
    - Carbon savings preview

11. **Bookings History**
    - All bookings (rides, hotels, experiences)
    - Tabbed interface (Upcoming/Completed/Cancelled)
    - Detailed booking cards
    - Quick actions

12. **Sustainability Dashboard**
    - Total impact metrics
    - Monthly trends
    - Achievement badges
    - Eco score ranking
    - Social comparison

13. **Profile Screen**
    - User information
    - Preferences and settings
    - Eco champion status
    - Account management

### New Planning & Utility Screens

14. **Notifications Screen** - **NEW**
    - All app notifications and alerts
    - Categorized by type (Bookings, Offers, Achievements, Reminders, Reviews)
    - Read/unread status indicators
    - "Mark all read" functionality
    - Timestamp for each notification

15. **Destinations Screen** - **NEW**
    - Browse popular destinations with category filters
    - Filter by: All, Beach, Mountains, Cities, Nature, Historical
    - 12+ pre-populated destinations with eco ratings
    - Grid view with destination cards
    - Activity counts and eco scores
    - Search functionality

16. **Budget Tracker Screen** - **NEW**
    - Total budget overview with spent/remaining breakdown
    - Expense tracking by category (Transport, Hotels, Food, Activities)
    - Progress bars showing spending percentages
    - Recent transactions list with icons and dates
    - Add new expenses with floating action button

17. **Documents/Checklist Screen** - **NEW**
    - Interactive travel preparation checklist
    - 12+ essential items across 6 categories
    - Progress tracker with completion percentage
    - Category-based organization (Essential, Travel, Health, Safety, Finance, Electronics)
    - Custom item addition capability

18. **Carbon Tracker Screen** (Detailed) - **NEW**
    - Total CO₂ saved with yearly statistics
    - Trees equivalent and driving distance saved
    - Monthly trend chart (6-month visualization)
    - Transport mode breakdown with color coding
    - Eco tips and educational content
    - Beautiful data visualization using fl_chart

19. **Reviews Screen** - **NEW**
    - Your reviews tab with star ratings
    - Received reviews from other travelers
    - Category badges (Hotel, Restaurant, Experience, Transport)
    - Write and edit reviews functionality
    - Timestamp and rating display

20. **Settings Screen** - **NEW**
    - Account settings (Personal info, Payment methods, Preferences)
    - App preferences (Notifications, Eco Mode, Dark Mode toggles)
    - Language selection (English, Spanish, French, German, Japanese)
    - Currency selection (USD, EUR, GBP, JPY)
    - Support section (Help, Terms, Privacy Policy, About)
    - Logout with confirmation dialog

**Total Screens**: 20 fully functional screens

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
```bash
git clone https://github.com/punithsai18/sePro.git
cd sePro
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## 📦 Dependencies

- `cupertino_icons: ^1.0.8` - iOS style icons
- `provider: ^6.1.1` - State management
- `font_awesome_flutter: ^10.7.0` - Icon library
- `fl_chart: ^0.66.2` - Chart visualization
- `animate_do: ^3.3.4` - Animation effects

## 🎨 Design System

### Color Palette
- **Primary Green**: #2E7D32 - Eco and sustainability theme
- **Light Green**: #4CAF50 - Accents and highlights
- **Transport Blue**: #1976D2 - Transportation services
- **Hotel Purple**: #7B1FA2 - Accommodation
- **Food Orange**: #E65100 - Dining and restaurants
- **Experience Red**: #C62828 - Activities and tours
- **Guide Green**: #388E3C - Travel guides
- **Eco Gold**: #F9A825 - Green certifications
- **Info Blue**: #0288D1 - Information and support
- **Error Red**: #D32F2F - Emergency and warnings

### Typography
- Material Design 3 default typography
- Custom font weights for hierarchy

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point & navigation
├── models/                            # Data models
│   └── ride_models.dart              # All travel-related models
├── screens/                           # Main app screens
│   ├── explore_screen.dart           # Main hub with all services
│   ├── transportation_screen.dart    # Multi-modal transport
│   ├── hotels_screen.dart            # Hotel booking
│   ├── restaurants_screen.dart       # Restaurant discovery
│   ├── travel_guides_screen.dart     # Guide booking
│   ├── experiences_screen.dart       # Activities & tours
│   ├── trip_planner_screen.dart      # Itinerary planning
│   ├── emergency_screen.dart         # Emergency support
│   ├── language_helper_screen.dart   # Translation helper
│   ├── book_ride_screen.dart         # Ride booking
│   ├── rides_history_screen.dart     # Bookings history
│   ├── sustainability_screen.dart    # Eco dashboard
│   ├── profile_screen.dart           # User profile
│   ├── home_screen.dart              # Original home (legacy)
│   └── new_home_screen.dart          # Alternative home (legacy)
├── widgets/                           # Reusable components
│   ├── common_widgets.dart           # Stats, badges, buttons
│   └── ride_card.dart                # Booking display cards
└── theme/                             # App theming
    └── app_theme.dart                # Colors, gradients & theme config
```

## 🔮 Future Enhancements

- **Map Integration**: Real-time maps and route visualization
- **Backend Integration**: REST API and real-time data sync
- **Payment Gateway**: Secure booking payments
- **Push Notifications**: Real-time updates and alerts
- **Social Features**: Share trips and reviews with friends
- **ML-based Recommendations**: AI-powered suggestions
- **Offline Mode**: Access saved data without internet
- **Multi-language Support**: Full app localization
- **Augmented Reality**: AR navigation and exploration
- **Blockchain**: Secure credential storage

## 🤝 Contributing

This is a university project for demonstrating sustainable mobility concepts.

## 📄 License

This project is part of an academic assignment.

## 👥 Authors

- Software Engineering Project Team

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for design guidelines
- Open-source community for various packages

---

**Note**: Map integration and real-time features are planned for future updates. Current version focuses on UI/UX implementation.
