import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// 8️⃣ Driver Navigation Page
class DriverNavigationScreen extends StatelessWidget {
  const DriverNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Container(color: isDark ? AppTheme.surfaceDarker : Colors.grey[200], child: Center(child: Icon(FontAwesomeIcons.map, color: Colors.grey[700], size: 80))),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.cardDark : Colors.white).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(12)),
                      child: Icon(FontAwesomeIcons.arrowRight, color: Colors.black, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('300 ft', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),
                          Text('Turn right onto Market St', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: _InfoCard(icon: FontAwesomeIcons.clock, label: 'ETA', value: '8 min')),
                        const SizedBox(width: 12),
                        const Expanded(child: _InfoCard(icon: FontAwesomeIcons.route, label: 'Distance', value: '2.5 mi')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.call, size: 20),
                            label: const Text('Call Rider'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.cancel, size: 20),
                            label: const Text('Cancel'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorRed,
                              side: const BorderSide(color: AppTheme.errorRed),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }
}
