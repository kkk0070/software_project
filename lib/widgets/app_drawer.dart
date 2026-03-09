import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../screens/hotels_screen.dart';
import '../screens/restaurants_screen.dart';
import '../screens/travel_guides_screen.dart';
import '../screens/experiences_screen.dart';
import '../screens/transportation_screen.dart';
import '../screens/trip_planner_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/language_helper_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/destinations_screen.dart';
import '../screens/budget_tracker_screen.dart';
import '../screens/documents_screen.dart';
import '../screens/carbon_tracker_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/about_screen.dart';
import '../screens/feedback_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Configurable navigation delay for smoother drawer closing
  static const Duration _navigationDelay = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FA), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(context),
            _buildSection(
              context,
              title: 'Travel Services',
              icon: FontAwesomeIcons.plane,
              items: [
                _DrawerItem(
                  icon: FontAwesomeIcons.train,
                  title: 'Transportation',
                  subtitle: 'Flights, trains & buses',
                  gradient: AppTheme.transportGradient,
                  onTap: () => _navigate(context, const TransportationScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.hotel,
                  title: 'Hotels',
                  subtitle: 'Eco-friendly stays',
                  gradient: AppTheme.hotelGradient,
                  onTap: () => _navigate(context, const HotelsScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.utensils,
                  title: 'Restaurants',
                  subtitle: 'Local dining',
                  gradient: AppTheme.foodGradient,
                  onTap: () => _navigate(context, const RestaurantsScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.compass,
                  title: 'Experiences',
                  subtitle: 'Tours & activities',
                  gradient: AppTheme.experienceGradient,
                  onTap: () => _navigate(context, const ExperiencesScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.userTie,
                  title: 'Travel Guides',
                  subtitle: 'Local experts',
                  gradient: AppTheme.ecoGradient,
                  onTap: () => _navigate(context, const TravelGuidesScreen()),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildSection(
              context,
              title: 'Planning & Tools',
              icon: FontAwesomeIcons.clipboardCheck,
              items: [
                _DrawerItem(
                  icon: FontAwesomeIcons.calendarDays,
                  title: 'Trip Planner',
                  subtitle: 'Build itineraries',
                  gradient: AppTheme.accentGradient,
                  onTap: () => _navigate(context, const TripPlannerScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.mapLocationDot,
                  title: 'Destinations',
                  subtitle: 'Explore places',
                  gradient: AppTheme.sunsetGradient,
                  onTap: () => _navigate(context, const DestinationsScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.dollarSign,
                  title: 'Budget Tracker',
                  subtitle: 'Manage expenses',
                  gradient: AppTheme.oceanGradient,
                  onTap: () => _navigate(context, const BudgetTrackerScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.fileLines,
                  title: 'Documents',
                  subtitle: 'Travel checklist',
                  gradient: AppTheme.transportGradient,
                  onTap: () => _navigate(context, const DocumentsScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.leaf,
                  title: 'Carbon Tracker',
                  subtitle: 'Environmental impact',
                  gradient: AppTheme.ecoGradient,
                  onTap: () => _navigate(context, const CarbonTrackerScreen()),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildSection(
              context,
              title: 'Support & More',
              icon: FontAwesomeIcons.circleInfo,
              items: [
                _DrawerItem(
                  icon: FontAwesomeIcons.bell,
                  title: 'Notifications',
                  subtitle: 'Updates & alerts',
                  gradient: AppTheme.accentGradient,
                  onTap: () => _navigate(context, const NotificationsScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.star,
                  title: 'Reviews',
                  subtitle: 'Your feedback',
                  gradient: AppTheme.sunsetGradient,
                  onTap: () => _navigate(context, const ReviewsScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.triangleExclamation,
                  title: 'Emergency SOS',
                  subtitle: 'Get help quickly',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => _navigate(context, const EmergencyScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.language,
                  title: 'Language Helper',
                  subtitle: 'Translations',
                  gradient: AppTheme.hotelGradient,
                  onTap: () => _navigate(context, const LanguageHelperScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.circleQuestion,
                  title: 'Help & FAQ',
                  subtitle: 'Get support',
                  gradient: AppTheme.accentGradient,
                  onTap: () => _navigate(context, const FAQScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.message,
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts',
                  gradient: AppTheme.experienceGradient,
                  onTap: () => _navigate(context, const FeedbackScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.circleInfo,
                  title: 'About',
                  subtitle: 'Learn more',
                  gradient: AppTheme.oceanGradient,
                  onTap: () => _navigate(context, const AboutScreen()),
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.gear,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  gradient: AppTheme.transportGradient,
                  onTap: () => _navigate(context, const SettingsScreen()),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Version 1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return FadeInDown(
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const FaIcon(
                FontAwesomeIcons.earthAmericas,
                color: AppTheme.primaryGreen,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'TravelHub',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Explore the world sustainably',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<_DrawerItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              FaIcon(
                icon,
                size: 16,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        ...items,
      ],
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer first
    // Delay to allow drawer close animation - configurable constant
    Future.delayed(_navigationDelay, () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    });
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: FaIcon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textLight,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}
