import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// 13️⃣ Emergency & Safety Page
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Emergency', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.errorRed, width: 4),
                ),
                child: const Icon(Icons.emergency, color: AppTheme.errorRed, size: 80),
              ),
              const SizedBox(height: 40),
              Text('Hold to Activate SOS', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Emergency services and contacts will be notified', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 200,
                child: ElevatedButton(
                  onPressed: () {},
                  onLongPress: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Emergency alert sent!'), backgroundColor: AppTheme.errorRed),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(32),
                  ),
                  child: const Text('SOS', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
              _buildQuickAction(context, 'Share Location', FontAwesomeIcons.locationDot),
              const SizedBox(height: 12),
              _buildQuickAction(context, 'Call Support', FontAwesomeIcons.phone),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
