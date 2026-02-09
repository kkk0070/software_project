import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import 'auth_screen.dart';
import 'rideshare_home_screen.dart';

/// 1️⃣ Landing / Home Page
/// Features:
/// - Platform overview & value proposition
/// - Quick ride booking entry
/// - Sustainability highlights
/// - Login / Register access
/// - Auto-redirect for logged-in users
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Check if user is already logged in
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn && mounted) {
      // Get user role from storage
      final userData = await StorageService.getUserData();
      final role = userData['role'] ?? 'rider';
      
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => RideshareHomeScreen(userRole: role.toLowerCase()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.leaf,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'EcoRide',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Value Proposition
                      Text(
                        'Intelligent Ride-Sharing &',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sustainable Mobility',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Smart, eco-friendly rides that reduce carbon emissions and save you money',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sustainability Highlights
              FadeInUp(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why Choose EcoRide?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        icon: FontAwesomeIcons.leaf,
                        title: 'Green Routes',
                        description: 'AI-powered routing to minimize carbon emissions',
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: FontAwesomeIcons.users,
                        title: 'Ride Pooling',
                        description: 'Share rides, reduce costs, and lower your carbon footprint',
                        color: AppTheme.accentBlue,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: FontAwesomeIcons.bolt,
                        title: 'EV Fleet',
                        description: 'Priority access to electric vehicles',
                        color: AppTheme.warningOrange,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: FontAwesomeIcons.shield,
                        title: 'Safe & Secure',
                        description: 'Real-time tracking and emergency SOS',
                        color: AppTheme.errorRed,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // CTA Buttons
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthScreen(isLogin: true),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryGreen,
                            side: const BorderSide(
                              color: AppTheme.primaryGreen,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
