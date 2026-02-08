import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _ecoMode = true;
  String _language = 'English';
  String _currency = 'USD';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
        title: Text(
          'Settings',
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
      ),
      body: ListView(
        children: [
          // Account Section
          FadeInDown(
            child: _buildSectionHeader('Account', isDark),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: _buildSettingsTile(
              'Personal Information',
              'Update your profile details',
              Icons.person,
              () {},
              isDark,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            child: _buildSettingsTile(
              'Payment Methods',
              'Manage your payment options',
              Icons.payment,
              () {},
              isDark,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildSettingsTile(
              'Preferences',
              'Travel and booking preferences',
              Icons.tune,
              () {},
              isDark,
            ),
          ),

          // App Settings
          FadeInDown(
            delay: const Duration(milliseconds: 250),
            child: _buildSectionHeader('App Settings', isDark),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildSwitchTile(
              'Notifications',
              'Receive booking and travel updates',
              Icons.notifications,
              _notifications,
              (value) {
                setState(() {
                  _notifications = value;
                });
              },
              isDark,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 350),
            child: _buildSwitchTile(
              'Eco Mode',
              'Prioritize eco-friendly options',
              Icons.eco,
              _ecoMode,
              (value) {
                setState(() {
                  _ecoMode = value;
                });
              },
              isDark,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildSwitchTile(
              'Dark Mode',
              'Use dark theme',
              Icons.dark_mode,
              isDark,
              (value) {
                themeProvider.toggleTheme();
              },
              isDark,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 450),
            child: _buildSelectTile(
              'Language',
              _language,
              Icons.language,
              () {
                _showLanguageDialog(isDark);
              },
              isDark,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: _buildSelectTile(
              'Currency',
              _currency,
              Icons.attach_money,
              () {
                _showCurrencyDialog(isDark);
              },
              isDark,
            ),
          ),

          // Support
          FadeInDown(
            delay: const Duration(milliseconds: 550),
            child: _buildSectionHeader('Support', isDark),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildSettingsTile(
              'Help Center',
              'Get help and support',
              Icons.help,
              () {},
              isDark,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 650),
            child: _buildSettingsTile(
              'Terms & Conditions',
              'Read our terms',
              Icons.description,
              () {},
              isDark,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: _buildSettingsTile(
              'Privacy Policy',
              'Your privacy matters',
              Icons.privacy_tip,
              () {},
              isDark,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 750),
            child: _buildSettingsTile(
              'About',
              'Version 1.0.0',
              Icons.info,
              () {},
              isDark,
            ),
          ),

          // Logout
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: Container(
              margin: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey[400] : AppTheme.textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.grey[400] : AppTheme.textLight,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey.shade600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildSelectTile(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : AppTheme.textLight,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[400] : AppTheme.textLight,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        title: Text(
          'Select Language',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', isDark),
            _buildLanguageOption('Spanish', isDark),
            _buildLanguageOption('French', isDark),
            _buildLanguageOption('German', isDark),
            _buildLanguageOption('Japanese', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isDark) {
    return RadioListTile<String>(
      title: Text(
        language,
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.textDark,
        ),
      ),
      value: language,
      groupValue: _language,
      activeColor: AppTheme.primaryGreen,
      onChanged: (value) {
        setState(() {
          _language = value!;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showCurrencyDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        title: Text(
          'Select Currency',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption('USD', isDark),
            _buildCurrencyOption('EUR', isDark),
            _buildCurrencyOption('GBP', isDark),
            _buildCurrencyOption('JPY', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String currency, bool isDark) {
    return RadioListTile<String>(
      title: Text(
        currency,
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.textDark,
        ),
      ),
      value: currency,
      groupValue: _currency,
      activeColor: AppTheme.primaryGreen,
      onChanged: (value) {
        setState(() {
          _currency = value!;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showLogoutDialog() {
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
              // Perform logout
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
