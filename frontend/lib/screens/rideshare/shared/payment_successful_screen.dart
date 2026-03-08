import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../../theme/app_theme.dart';
import 'rideshare_home_screen.dart';

class PaymentSuccessfulScreen extends StatelessWidget {
  final double amount;
  final String pickup;
  final String dropoff;
  final String driverName;

  const PaymentSuccessfulScreen({
    super.key,
    required this.amount,
    required this.pickup,
    required this.dropoff,
    required this.driverName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryGreen,
                      size: 80,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                child: Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Your ride has been confirmed.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Ride Details Summary
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        icon: FontAwesomeIcons.locationDot,
                        label: 'Pickup',
                        value: pickup,
                        isDark: isDark,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      _buildSummaryRow(
                        icon: FontAwesomeIcons.locationCrosshairs,
                        label: 'Dropoff',
                        value: dropoff,
                        isDark: isDark,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      _buildSummaryRow(
                        icon: FontAwesomeIcons.car,
                        label: 'Driver',
                        value: driverName,
                        isDark: isDark,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      _buildSummaryRow(
                        icon: FontAwesomeIcons.moneyBill,
                        label: 'Paid Amount',
                        value: '\$${amount.toStringAsFixed(2)}',
                        isDark: isDark,
                        valueColor: AppTheme.primaryGreen,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Return to Rideshare Home Screen
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RideshareHomeScreen(userRole: 'rider'),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Return to Home',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
