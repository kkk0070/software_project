import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// Impact History Screen – per-ride eco impact log
class ImpactHistoryScreen extends StatefulWidget {
  const ImpactHistoryScreen({super.key});

  @override
  State<ImpactHistoryScreen> createState() => _ImpactHistoryScreenState();
}

class _ImpactHistoryScreenState extends State<ImpactHistoryScreen> {
  String _selectedVehicle = 'All';
  final List<String> _vehicles = ['All', 'Car', 'EV', 'Motorcycle', 'Bicycle'];

  static const List<_RideImpact> _allRides = [
    _RideImpact('Feb 27', 'Home → Office', 'EV', 12.4, 3.2, 45, FontAwesomeIcons.bolt, Color(0xFF00E5FF)),
    _RideImpact('Feb 26', 'Mall → Home', 'Car', 8.2, 1.8, 28, FontAwesomeIcons.car, AppTheme.accentBlue),
    _RideImpact('Feb 25', 'Office → Gym', 'Bicycle', 3.1, 0.8, 99, FontAwesomeIcons.bicycle, AppTheme.primaryGreen),
    _RideImpact('Feb 24', 'Home → Airport', 'Car', 22.5, 4.5, 18, FontAwesomeIcons.car, AppTheme.accentBlue),
    _RideImpact('Feb 23', 'Station → Office', 'EV', 6.8, 2.1, 52, FontAwesomeIcons.bolt, Color(0xFF00E5FF)),
    _RideImpact('Feb 22', 'Home → Park', 'Bicycle', 4.2, 1.1, 99, FontAwesomeIcons.bicycle, AppTheme.primaryGreen),
    _RideImpact('Feb 21', 'Office → Home', 'Motorcycle', 11.3, 2.3, 35, FontAwesomeIcons.motorcycle, AppTheme.warningOrange),
    _RideImpact('Feb 20', 'Mall → Restaurant', 'Car', 5.0, 1.0, 22, FontAwesomeIcons.car, AppTheme.accentBlue),
    _RideImpact('Feb 19', 'Home → Office', 'EV', 12.4, 3.1, 50, FontAwesomeIcons.bolt, Color(0xFF00E5FF)),
    _RideImpact('Feb 18', 'Gym → Home', 'Bicycle', 3.1, 0.8, 99, FontAwesomeIcons.bicycle, AppTheme.primaryGreen),
  ];

  List<_RideImpact> get _filtered {
    if (_selectedVehicle == 'All') return _allRides;
    return _allRides.where((r) => r.vehicle == _selectedVehicle).toList();
  }

  void _downloadHistory() {
    final rides = _filtered;
    final lines = rides.map((r) =>
      '${r.date},${r.route},${r.vehicle},${r.distanceKm} km,${r.co2Saved} kg,${r.ecoScore}'
    ).join('\n');
    final csv = 'Date,Route,Vehicle,Distance,CO2 Saved,Eco Score\n$lines\n';
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Impact history copied to clipboard as CSV'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rides = _filtered;

    // Aggregate stats for filtered rides
    final totalCo2 = rides.fold(0.0, (s, r) => s + r.co2Saved);
    final totalDist = rides.fold(0.0, (s, r) => s + r.distanceKm);
    final avgScore = rides.isEmpty ? 0 : (rides.fold(0, (s, r) => s + r.ecoScore) / rides.length).round();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Impact History', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppTheme.primaryGreen),
            tooltip: 'Download as CSV',
            onPressed: _downloadHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Vehicle filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _vehicles.map((v) {
                  final selected = _selectedVehicle == v;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedVehicle = v),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primaryGreen : (isDark ? AppTheme.cardDark : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? AppTheme.primaryGreen : (isDark ? Colors.white24 : Colors.black12),
                          ),
                        ),
                        child: Text(
                          v,
                          style: TextStyle(
                            color: selected ? Colors.black : (isDark ? Colors.white70 : Colors.black54),
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Summary row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _summaryChip('${rides.length} Rides', FontAwesomeIcons.car, AppTheme.accentBlue, isDark),
                const SizedBox(width: 8),
                _summaryChip('${totalCo2.toStringAsFixed(1)} kg CO₂', FontAwesomeIcons.leaf, AppTheme.primaryGreen, isDark),
                const SizedBox(width: 8),
                _summaryChip('${totalDist.toStringAsFixed(0)} km', FontAwesomeIcons.route, AppTheme.warningOrange, isDark),
              ],
            ),
          ),
          // Ride list
          Expanded(
            child: rides.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FontAwesomeIcons.leaf, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('No rides for this vehicle type', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: rides.length,
                    itemBuilder: (ctx, i) => _buildRideCard(ctx, rides[i], isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
            Flexible(child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, _RideImpact ride, bool isDark) {
    final scoreColor = ride.ecoScore >= 80
        ? AppTheme.primaryGreen
        : ride.ecoScore >= 50
            ? AppTheme.warningOrange
            : AppTheme.errorRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ride.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(ride.icon, color: ride.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ride.route, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(ride.date, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: ride.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(ride.vehicle, style: TextStyle(color: ride.color, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 6),
                    Text('${ride.distanceKm} km', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${ride.ecoScore}', style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(height: 3),
              Text('${ride.co2Saved} kg CO₂', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RideImpact {
  final String date;
  final String route;
  final String vehicle;
  final double distanceKm;
  final double co2Saved;
  final int ecoScore;
  final IconData icon;
  final Color color;

  const _RideImpact(this.date, this.route, this.vehicle, this.distanceKm, this.co2Saved, this.ecoScore, this.icon, this.color);
}
