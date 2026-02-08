import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../utils/user_profile_loader.dart';
import '../services/api_config.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with UserProfileLoader {
  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Profile',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditScreen(),
                ),
              );
              
              // Refresh profile if edit was successful
              if (result == true) {
                loadUserProfile();
              }
            },
          ),
        ],
      ),
      body: isLoadingProfile
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            )
          : SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            backgroundImage: userProfilePhoto != null && userProfilePhoto!.isNotEmpty
                                ? NetworkImage('${ApiConfig.baseUrl}$userProfilePhoto')
                                : null,
                            child: userProfilePhoto == null || userProfilePhoto!.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 65,
                                    color: AppTheme.primaryGreen,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName ?? 'Eco Rider',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail ?? 'No email',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Member since Jan 2024',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.crown,
                            color: AppTheme.ecoGold,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Eco Champion',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        icon: FontAwesomeIcons.route,
                        value: '156',
                        label: 'Total Rides',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        icon: FontAwesomeIcons.star,
                        value: '4.8',
                        label: 'Rating',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        icon: FontAwesomeIcons.leaf,
                        value: '850',
                        label: 'Eco Score',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Card(
                      color: isDark ? AppTheme.cardDark : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.person_outline,
                            title: 'Personal Information',
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileEditScreen(),
                                ),
                              );
                              if (result == true) {
                                loadUserProfile();
                              }
                            },
                            isDark: isDark,
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.phone_outlined,
                            title: 'Phone Number',
                            subtitle: userPhone ?? 'Not set',
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileEditScreen(),
                                ),
                              );
                              if (result == true) {
                                loadUserProfile();
                              }
                            },
                            isDark: isDark,
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.email_outlined,
                            title: 'Email Address',
                            subtitle: userEmail ?? 'Not set',
                            onTap: () {},
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      'Ride Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Card(
                      color: isDark ? AppTheme.cardDark : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          _SettingsSwitchTile(
                            icon: FontAwesomeIcons.users,
                            title: 'Prefer Pool Rides',
                            subtitle: 'Automatically suggest pooled rides',
                            value: true,
                            onChanged: (value) {},
                            isDark: isDark,
                          ),
                          const Divider(height: 1),
                          _SettingsSwitchTile(
                            icon: FontAwesomeIcons.leaf,
                            title: 'Eco Mode',
                            subtitle: 'Prioritize sustainable options',
                            value: true,
                            onChanged: (value) {},
                            isDark: isDark,
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.home_outlined,
                            title: 'Saved Addresses',
                            onTap: () {},
                            isDark: isDark,
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.dark_mode_outlined,
                            title: 'Theme',
                            subtitle: isDark ? 'Dark' : 'Light',
                            onTap: () {
                              _showThemeDialog(context, themeProvider, isDark);
                            },
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: Card(
                      color: isDark ? AppTheme.cardDark : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          _SettingsSwitchTile(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            subtitle: 'Ride updates and promotions',
                            value: true,
                            onChanged: (value) {},
                            isDark: isDark,
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.language,
                            title: 'Language',
                            subtitle: 'English',
                            onTap: () {},
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 800),
                    child: Text(
                      'Support & Legal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 900),
                    child: Card(
                      color: isDark ? AppTheme.cardDark : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            onTap: () {},
                            isDark: isDark,
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.description_outlined,
                            title: 'Terms & Conditions',
                            onTap: () {},
                            isDark: isDark,
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () {},
                            isDark: isDark,
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.info_outline,
                            title: 'About',
                            subtitle: 'Version 1.0.0',
                            onTap: () {},
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 1000),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showLogoutDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          side: const BorderSide(color: AppTheme.errorRed),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        title: Text(
          'Select Theme',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(
                'Light Mode',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              activeColor: AppTheme.primaryGreen,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              activeColor: AppTheme.primaryGreen,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : AppTheme.textDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Card(
      color: isDark ? AppTheme.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            FaIcon(icon, color: AppTheme.primaryGreen, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.textDark,
        ),
      ),
      subtitle: subtitle != null 
          ? Text(
              subtitle!,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : AppTheme.textLight,
              ),
            ) 
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? Colors.grey[400] : AppTheme.textLight,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.grey[400] : AppTheme.textLight,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGreen,
    );
  }
}
