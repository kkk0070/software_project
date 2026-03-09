import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/theme_provider.dart';

/// Preferences Screen
/// Features:
/// - Theme selection (Light/Dark)
/// - Additional user preferences
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
        elevation: 0,
        title: Text(
          'Preferences',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text(
                  'Customize your experience',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Appearance Section
              FadeInUp(
                child: _buildSectionHeader(
                  'Appearance',
                  isDark,
                ),
              ),
              const SizedBox(height: 12),

              // Theme Toggle
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: _buildThemeToggle(themeProvider, isDark),
              ),

              const SizedBox(height: 32),

              // Notifications Section
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildSectionHeader(
                  'Notifications',
                  isDark,
                ),
              ),
              const SizedBox(height: 12),

              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _buildPreferenceItem(
                  icon: FontAwesomeIcons.bell,
                  title: 'Push Notifications',
                  subtitle: 'Receive ride updates',
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notification preferences persistence
                  },
                  isDark: isDark,
                ),
              ),

              const SizedBox(height: 32),

              // Ride Preferences Section
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildSectionHeader(
                  'Ride Preferences',
                  isDark,
                ),
              ),
              const SizedBox(height: 12),

              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: _buildPreferenceItem(
                  icon: FontAwesomeIcons.leaf,
                  title: 'Eco-Friendly Priority',
                  subtitle: 'Prefer electric vehicles',
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement eco-friendly preference persistence
                  },
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppTheme.textDark,
      ),
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  FontAwesomeIcons.palette,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDark ? 'Dark Mode' : 'Light Mode',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  icon: FontAwesomeIcons.sun,
                  label: 'Light',
                  isSelected: !isDark,
                  onTap: () {
                    if (isDark) {
                      themeProvider.toggleTheme();
                    }
                  },
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOption(
                  icon: FontAwesomeIcons.moon,
                  label: 'Dark',
                  isSelected: isDark,
                  onTap: () {
                    if (!isDark) {
                      themeProvider.toggleTheme();
                    }
                  },
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.2)
              : (isDark
                  ? AppTheme.backgroundDark
                  : Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryGreen
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryGreen
                  : (isDark ? Colors.grey[600] : Colors.grey[500]),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryGreen
                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        value: value,
        activeColor: AppTheme.primaryGreen,
        onChanged: onChanged,
      ),
    );
  }
}
