import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Emergency Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.errorRed,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSOSButton(context),
            const SizedBox(height: 24),
            _buildEmergencyContacts(context),
            const SizedBox(height: 24),
            _buildLocalEmergencyNumbers(context),
            const SizedBox(height: 24),
            _buildSafetyTips(context),
            const SizedBox(height: 24),
            _buildNearbyHospitals(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton(BuildContext context) {
    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.errorRed, Colors.red.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorRed.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Emergency SOS',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Press and hold for 3 seconds to alert emergency contacts',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onLongPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emergency alert sent to your contacts'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'PRESS & HOLD SOS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.errorRed,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: _buildContactCard(
            context,
            'John Doe',
            'Father',
            '+1 234 567 8900',
            Icons.call,
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 250),
          child: _buildContactCard(
            context,
            'Jane Smith',
            'Emergency Contact',
            '+1 234 567 8901',
            Icons.call,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    String name,
    String relation,
    String phone,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  relation,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(icon, color: AppTheme.primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLocalEmergencyNumbers(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Local Emergency Numbers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          delay: const Duration(milliseconds: 350),
          child: _buildEmergencyNumberCard(
            context,
            'Police',
            '112',
            FontAwesomeIcons.shieldHalved,
            Colors.blue.shade700,
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: _buildEmergencyNumberCard(
            context,
            'Ambulance',
            '15',
            FontAwesomeIcons.truckMedical,
            Colors.red.shade600,
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 450),
          child: _buildEmergencyNumberCard(
            context,
            'Fire Department',
            '18',
            FontAwesomeIcons.fireFlameCurved,
            Colors.orange.shade700,
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 500),
          child: _buildEmergencyNumberCard(
            context,
            'Tourist Police',
            '+33 1 53 71 53 71',
            FontAwesomeIcons.locationDot,
            Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyNumberCard(
    BuildContext context,
    String service,
    String number,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTips(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 550),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Safety Tips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          delay: const Duration(milliseconds: 600),
          child: _buildSafetyTipCard(
            context,
            'Stay Alert',
            'Always be aware of your surroundings, especially in crowded tourist areas',
            Icons.visibility,
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 650),
          child: _buildSafetyTipCard(
            context,
            'Keep Copies',
            'Save digital copies of important documents (passport, visa, insurance)',
            Icons.copy_all,
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 700),
          child: _buildSafetyTipCard(
            context,
            'Share Location',
            'Share your location with trusted contacts when traveling alone',
            Icons.location_on,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyTipCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.infoBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.infoBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyHospitals(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 750),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Nearby Hospitals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          delay: const Duration(milliseconds: 800),
          child: _buildHospitalCard(
            context,
            'Paris General Hospital',
            '123 Rue de Paris, 75001',
            '2.3 km',
            '+33 1 40 27 40 27',
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 850),
          child: _buildHospitalCard(
            context,
            'International Medical Center',
            '456 Avenue Champs-Élysées',
            '3.1 km',
            '+33 1 47 23 80 80',
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalCard(
    BuildContext context,
    String name,
    String address,
    String distance,
    String phone,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: AppTheme.errorRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.directions, size: 16, color: AppTheme.primaryGreen),
              const SizedBox(width: 4),
              Text(
                distance,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppTheme.textLight,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.phone, size: 16, color: AppTheme.infoBlue),
              const SizedBox(width: 4),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppTheme.textLight,
                ),
              ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Get Directions')),
            ],
          ),
        ],
      ),
    );
  }
}
