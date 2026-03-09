import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// 4️⃣ Location Permission & Privacy Page
class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _locationEnabled = false;
  bool _backgroundLocation = false;
  bool _dataSharingConsent = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Location & Privacy', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(FontAwesomeIcons.locationDot, color: AppTheme.primaryGreen, size: 48),
            const SizedBox(height: 16),
            Text('Location Permissions', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Control how EcoRide accesses your location', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            const SizedBox(height: 32),
            _buildPermissionCard('Enable Location', 'Required for ride booking and tracking', _locationEnabled, (val) => setState(() => _locationEnabled = val)),
            const SizedBox(height: 16),
            _buildPermissionCard('Background Location', 'For better ride tracking and driver features', _backgroundLocation, (val) => setState(() => _backgroundLocation = val)),
            const SizedBox(height: 16),
            _buildPermissionCard('Data Sharing Consent', 'Help improve our services', _dataSharingConsent, (val) => setState(() => _dataSharingConsent = val)),
            const SizedBox(height: 32),
            Text('Privacy Notice', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPrivacyInfo(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Your location data is encrypted and used only for ride services. We never share your personal information with third parties without consent.',
        style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
      ),
    );
  }
}
