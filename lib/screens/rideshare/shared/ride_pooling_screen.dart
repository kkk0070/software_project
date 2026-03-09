import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import 'live_tracking_screen.dart';

/// 6️⃣ Ride Pooling Page
class RidePoolingScreen extends StatelessWidget {
  const RidePoolingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Available Pool Rides', style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildPoolOption(context, 'Solo Ride', '\$12.50', '5 min', '2.1 kg CO₂', false),
          const SizedBox(height: 16),
          _buildPoolOption(context, 'Shared Ride', '\$8.75', '8 min', '1.2 kg CO₂', true, recommended: true),
          const SizedBox(height: 16),
          _buildPoolOption(context, 'EV Pool', '\$9.50', '10 min', '0.8 kg CO₂', true, isEv: true),
        ],
      ),
    );
  }

  Widget _buildPoolOption(BuildContext context, String title, String price, String eta, String carbon, bool isPooled, {bool recommended = false, bool isEv = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveTrackingScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: recommended ? AppTheme.primaryGreen : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3)), width: recommended ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isPooled ? FontAwesomeIcons.users : FontAwesomeIcons.car, color: AppTheme.primaryGreen, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                      if (recommended) const Text('Recommended', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
                    ],
                  ),
                ),
                Text(price, style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(context, FontAwesomeIcons.clock, eta),
                const SizedBox(width: 12),
                _buildInfoChip(context, FontAwesomeIcons.leaf, carbon),
                if (isEv) ...[const SizedBox(width: 12), _buildInfoChip(context, FontAwesomeIcons.bolt, 'EV')],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark : Colors.grey[200], borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[700], size: 12), const SizedBox(width: 6), Text(label, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12))]),
    );
  }
}
