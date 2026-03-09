import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/rideshare/shared/landing_screen.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create theme provider and load saved theme preference
  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();
  
  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const EcoRideApp(),
    ),
  );
}

class EcoRideApp extends StatelessWidget {
  const EcoRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'EcoRide - Intelligent Ride-Sharing & Sustainable Mobility',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const LandingScreen(),
        );
      },
    );
  }
}
