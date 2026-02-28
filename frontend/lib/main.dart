// Core Flutter framework for building the UI
import 'package:flutter/material.dart';
// Provider package for state management across the app
import 'package:provider/provider.dart';
// Firebase core for push notifications
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
// Custom theme configuration for light and dark modes
import 'theme/app_theme.dart';
// Initial landing screen shown to users
import 'screens/rideshare/shared/landing_screen.dart';
// Theme provider for managing app theme state
import 'providers/theme_provider.dart';
// Active ride provider for tracking in-progress rides
import 'providers/active_ride_provider.dart';
// Push notification service
import 'services/push_notification_service.dart';

/// Main entry point of the EcoRide Flutter application
/// Initializes the app and sets up the theme provider
void main() async {
  // Ensures Flutter bindings are initialized before running async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Continue app initialization even if Firebase fails
  }
  
  // Create a new instance of the theme provider to manage app theme
  final themeProvider = ThemeProvider();
  // Load the user's previously saved theme preference from local storage
  await themeProvider.loadThemePreference();
  
  // Start the Flutter application with the theme provider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => ActiveRideProvider()),
      ],
      child: const EcoRideApp(),
    ),
  );
}

/// Root widget of the EcoRide application
/// Sets up MaterialApp with theme support and initial screen
class EcoRideApp extends StatefulWidget {
  const EcoRideApp({super.key});

  @override
  State<EcoRideApp> createState() => _EcoRideAppState();
}

class _EcoRideAppState extends State<EcoRideApp> {
  @override
  void initState() {
    super.initState();
    // Initialize push notifications after the app starts
    _initializePushNotifications();
  }

  Future<void> _initializePushNotifications() async {
    try {
      await PushNotificationService.initialize();
      print('Push notifications initialized in main app');
    } catch (e) {
      print('Error initializing push notifications in main: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumer listens to ThemeProvider changes and rebuilds when theme changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // MaterialApp is the root of the app widget tree
        return MaterialApp(
          // Application title shown in task switcher
          title: 'EcoRide - Intelligent Ride-Sharing & Sustainable Mobility',
          // Remove the debug banner from the top-right corner in debug mode
          debugShowCheckedModeBanner: false,
          // Light theme configuration for the app
          theme: AppTheme.lightTheme,
          // Dark theme configuration for the app
          darkTheme: AppTheme.darkTheme,
          // Current theme mode (light/dark/system) from theme provider
          themeMode: themeProvider.themeMode,
          // Initial screen shown when the app starts
          home: const LandingScreen(),
        );
      },
    );
  }
}
