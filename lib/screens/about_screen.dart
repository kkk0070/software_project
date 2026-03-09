import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('About TravelHub'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.earthAmericas,
                        color: AppTheme.primaryGreen,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'TravelHub',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explore the World Sustainably',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Mission Statement
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppTheme.ecoGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const FaIcon(
                                FontAwesomeIcons.bullseye,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Our Mission',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'To revolutionize travel by making sustainable and eco-friendly choices accessible, convenient, and rewarding for everyone. We believe that exploring the world shouldn\'t come at the cost of our planet.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: isDark ? Colors.white70 : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const FaIcon(
                                FontAwesomeIcons.star,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'What We Offer',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildFeatureItem(
                          icon: FontAwesomeIcons.leaf,
                          title: 'Eco-Friendly Options',
                          description: 'Carbon tracking and sustainable choices',
                          color: AppTheme.successGreen,
                        ),
                        _buildFeatureItem(
                          icon: FontAwesomeIcons.route,
                          title: 'All-in-One Platform',
                          description: 'Transport, hotels, dining & activities',
                          color: AppTheme.transportBlue,
                        ),
                        _buildFeatureItem(
                          icon: FontAwesomeIcons.shield,
                          title: 'Safety First',
                          description: 'Emergency support & local assistance',
                          color: AppTheme.errorRed,
                        ),
                        _buildFeatureItem(
                          icon: FontAwesomeIcons.chartLine,
                          title: 'Smart Planning',
                          description: 'Budget tracking & itinerary tools',
                          color: AppTheme.accentBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Team
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppTheme.experienceGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const FaIcon(
                                FontAwesomeIcons.users,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Our Team',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Built by passionate developers and travel enthusiasts dedicated to creating a better, more sustainable future for travel. This project is part of our commitment to environmental responsibility.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: isDark ? Colors.white70 : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Contact & Social
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect With Us',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSocialButton(
                              icon: FontAwesomeIcons.globe,
                              label: 'Website',
                              gradient: AppTheme.accentGradient,
                            ),
                            _buildSocialButton(
                              icon: FontAwesomeIcons.twitter,
                              label: 'Twitter',
                              gradient: AppTheme.transportGradient,
                            ),
                            _buildSocialButton(
                              icon: FontAwesomeIcons.instagram,
                              label: 'Instagram',
                              gradient: AppTheme.experienceGradient,
                            ),
                            _buildSocialButton(
                              icon: FontAwesomeIcons.github,
                              label: 'GitHub',
                              gradient: AppTheme.oceanGradient,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),
                        _buildContactItem(
                          icon: FontAwesomeIcons.envelope,
                          text: 'support@travelhub.com',
                        ),
                        _buildContactItem(
                          icon: FontAwesomeIcons.phone,
                          text: '+1 (555) 123-4567',
                        ),
                        _buildContactItem(
                          icon: FontAwesomeIcons.locationDot,
                          text: 'San Francisco, CA',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '© 2024 TravelHub. All rights reserved.',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Privacy Policy'),
                      ),
                      const Text('•'),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Terms of Service'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    );
                  }
                ),
                const SizedBox(height: 4),
                Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : AppTheme.textLight,
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
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
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            );
          }
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          FaIcon(
            icon,
            size: 16,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 12),
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : AppTheme.textLight,
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}
