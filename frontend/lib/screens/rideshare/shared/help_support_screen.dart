import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// 18️⃣ Help & Support Page
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
        title: Text('Help & Support', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How can we help?', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildSupportCard('FAQs', 'Find answers to common questions', FontAwesomeIcons.circleQuestion, AppTheme.accentBlue),
            const SizedBox(height: 12),
            _buildSupportCard('Submit Ticket', 'Report an issue or request support', FontAwesomeIcons.ticket, AppTheme.primaryGreen),
            const SizedBox(height: 12),
            _buildSupportCard('Live Chat', 'Chat with our support team', FontAwesomeIcons.comments, AppTheme.accentPurple),
            const SizedBox(height: 12),
            _buildSupportCard('Call Support', 'Speak with a representative', FontAwesomeIcons.phone, AppTheme.warningOrange),
            const SizedBox(height: 32),
            Text('Popular Topics', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTopicCard('How to book a ride?'),
            _buildTopicCard('Payment methods'),
            _buildTopicCard('Cancellation policy'),
            _buildTopicCard('Safety features'),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(String title, String subtitle, IconData icon, Color color) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3)),
          ),
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
                    Text(subtitle, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[600]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopicCard(String topic) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(FontAwesomeIcons.circleQuestion, color: Colors.grey[500], size: 16),
              const SizedBox(width: 12),
              Expanded(child: Text(topic, style: TextStyle(color: isDark ? Colors.white : Colors.black))),
              Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
            ],
          ),
        );
      },
    );
  }
}
