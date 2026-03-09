import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/active_ride_provider.dart';
import '../services/auth_service.dart';
import 'rideshare/shared/landing_screen.dart';

class DeactivateAccountScreen extends StatefulWidget {
  const DeactivateAccountScreen({super.key});

  @override
  State<DeactivateAccountScreen> createState() => _DeactivateAccountScreenState();
}

class _DeactivateAccountScreenState extends State<DeactivateAccountScreen> {
  bool _isDeactivating = false;

  Future<void> _deactivateAccount() async {
    setState(() {
      _isDeactivating = true;
    });

    final result = await AuthService.deactivateAccount();

    if (!mounted) return;

    setState(() {
      _isDeactivating = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deactivated successfully')),
      );
      // Clear active ride state if any
      if (context.mounted) {
        Provider.of<ActiveRideProvider>(context, listen: false).clearRide();
      }
      
      // Auth service automatically calls logout(), redirect to landing
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LandingScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to deactivate account')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Deactivate Account',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
        ),
        backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppTheme.textDark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 24),
            Text(
              'Are you sure you want to deactivate your account?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Deactivating your account will hide your profile and log you out immediately across all devices. You can reactivate your account by contacting support.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 48),
            _isDeactivating
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _deactivateAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Deactivate My Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
