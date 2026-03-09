import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// 🔟 Location Accuracy Monitoring (System Feature Page)
class LocationAccuracyScreen extends StatelessWidget {
  const LocationAccuracyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('Location Accuracy', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGreen),
              ),
              child: const Row(
                children: [
                  Icon(FontAwesomeIcons.circleCheck, color: AppTheme.primaryGreen, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GPS Status: Good', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Location accuracy is within acceptable range', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Monitoring Features', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFeatureCard(context, 'GPS Jump Detection', 'Detects sudden location changes', FontAwesomeIcons.personWalking, AppTheme.accentBlue),
            const SizedBox(height: 12),
            _buildFeatureCard(context, 'Speed Validation', 'Identifies unrealistic speed changes', FontAwesomeIcons.gaugeHigh, AppTheme.warningOrange),
            const SizedBox(height: 12),
            _buildFeatureCard(context, 'Path Smoothing', 'Corrects location using recent data', FontAwesomeIcons.route, AppTheme.primaryGreen),
            const SizedBox(height: 12),
            _buildFeatureCard(context, 'Event Logging', 'Records accuracy issues for review', FontAwesomeIcons.fileLines, AppTheme.accentPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String description, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? AppTheme.cardDark : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
