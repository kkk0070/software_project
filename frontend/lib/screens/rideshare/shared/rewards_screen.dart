import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// 16️⃣ Rewards & Gamification Page
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

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
        title: Text('Rewards', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF8F00)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.trophy, color: Colors.black, size: 48),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Eco Points', style: TextStyle(color: Colors.black, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('1,250', style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Your Badges', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildBadge('Eco Warrior', FontAwesomeIcons.leaf, AppTheme.primaryGreen, true),
                _buildBadge('Pool Pro', FontAwesomeIcons.users, AppTheme.accentBlue, true),
                _buildBadge('EV Champion', FontAwesomeIcons.bolt, AppTheme.warningOrange, true),
                _buildBadge('Night Rider', FontAwesomeIcons.moon, Colors.grey, false),
                _buildBadge('Century', FontAwesomeIcons.star, Colors.grey, false),
                _buildBadge('Carbon Zero', FontAwesomeIcons.seedling, Colors.grey, false),
              ],
            ),
            const SizedBox(height: 32),
            Text('Milestones', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildMilestone('Complete 10 pooled rides', 7, 10),
            const SizedBox(height: 12),
            _buildMilestone('Save 100kg CO₂', 42, 100),
            const SizedBox(height: 12),
            _buildMilestone('50 EV rides', 28, 50),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color, bool unlocked) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: unlocked ? color : Colors.grey.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: unlocked ? color : Colors.grey, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: unlocked ? (isDark ? Colors.white : Colors.black) : Colors.grey,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestone(String label, int current, int total) {
    final progress = current / total;
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600))),
                  Text('$current/$total', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  color: AppTheme.primaryGreen,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
