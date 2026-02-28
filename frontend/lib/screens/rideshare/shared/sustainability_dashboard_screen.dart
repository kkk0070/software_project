import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../theme/app_theme.dart';
import 'rewards_screen.dart';
import 'green_route_screen.dart';
import 'eco_leaderboard_screen.dart';
import 'impact_history_screen.dart';

/// Vehicle type filter options
enum VehicleFilter { all, car, ev, motorcycle, bicycle }

/// Data model for vehicle-specific impact data
class _VehicleData {
  final String label;
  final IconData icon;
  final int ecoScore;
  final int totalRides;
  final String co2Saved;
  final String rankText;
  final List<FlSpot> chartSpots;
  final Color accentColor;

  const _VehicleData({
    required this.label,
    required this.icon,
    required this.ecoScore,
    required this.totalRides,
    required this.co2Saved,
    required this.rankText,
    required this.chartSpots,
    required this.accentColor,
  });
}

/// 14️⃣ Sustainability Dashboard (User)
class SustainabilityDashboardScreen extends StatefulWidget {
  const SustainabilityDashboardScreen({super.key});

  @override
  State<SustainabilityDashboardScreen> createState() =>
      _SustainabilityDashboardScreenState();
}

class _SustainabilityDashboardScreenState
    extends State<SustainabilityDashboardScreen> {
  VehicleFilter _selectedFilter = VehicleFilter.all;

  static const Map<VehicleFilter, _VehicleData> _vehicleData = {
    VehicleFilter.all: _VehicleData(
      label: 'All Vehicles',
      icon: FontAwesomeIcons.chartBar,
      ecoScore: 850,
      totalRides: 28,
      co2Saved: '42 kg',
      rankText: 'Top 10% of riders',
      chartSpots: [
        FlSpot(0, 2), FlSpot(1, 3), FlSpot(2, 1.5),
        FlSpot(3, 4), FlSpot(4, 3.5), FlSpot(5, 5), FlSpot(6, 4.5),
      ],
      accentColor: AppTheme.primaryGreen,
    ),
    VehicleFilter.car: _VehicleData(
      label: 'Car',
      icon: FontAwesomeIcons.car,
      ecoScore: 620,
      totalRides: 15,
      co2Saved: '18 kg',
      rankText: 'Top 35% of car riders',
      chartSpots: [
        FlSpot(0, 1.2), FlSpot(1, 1.8), FlSpot(2, 1.0),
        FlSpot(3, 2.2), FlSpot(4, 1.9), FlSpot(5, 2.5), FlSpot(6, 2.0),
      ],
      accentColor: AppTheme.accentBlue,
    ),
    VehicleFilter.ev: _VehicleData(
      label: 'Electric Vehicle',
      icon: FontAwesomeIcons.bolt,
      ecoScore: 950,
      totalRides: 8,
      co2Saved: '20 kg',
      rankText: 'Top 5% of EV riders',
      chartSpots: [
        FlSpot(0, 2.5), FlSpot(1, 3.2), FlSpot(2, 2.8),
        FlSpot(3, 3.8), FlSpot(4, 4.2), FlSpot(5, 4.8), FlSpot(6, 5.0),
      ],
      accentColor: Color(0xFF00E5FF),
    ),
    VehicleFilter.motorcycle: _VehicleData(
      label: 'Motorcycle',
      icon: FontAwesomeIcons.motorcycle,
      ecoScore: 710,
      totalRides: 3,
      co2Saved: '3 kg',
      rankText: 'Top 20% of moto riders',
      chartSpots: [
        FlSpot(0, 0.5), FlSpot(1, 0.8), FlSpot(2, 0.4),
        FlSpot(3, 1.0), FlSpot(4, 0.7), FlSpot(5, 1.1), FlSpot(6, 0.9),
      ],
      accentColor: AppTheme.warningOrange,
    ),
    VehicleFilter.bicycle: _VehicleData(
      label: 'Bicycle',
      icon: FontAwesomeIcons.bicycle,
      ecoScore: 990,
      totalRides: 2,
      co2Saved: '1 kg',
      rankText: 'Top 1% — Carbon Hero!',
      chartSpots: [
        FlSpot(0, 0.1), FlSpot(1, 0.2), FlSpot(2, 0.1),
        FlSpot(3, 0.3), FlSpot(4, 0.2), FlSpot(5, 0.4), FlSpot(6, 0.3),
      ],
      accentColor: AppTheme.primaryGreen,
    ),
  };

  _VehicleData get _current => _vehicleData[_selectedFilter]!;

  Future<void> _downloadImpact() async {
    final data = _current;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('4CAF50'),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Eco Impact Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      data.label,
                      style: const pw.TextStyle(fontSize: 14, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              // Summary section
              pw.Text(
                'Summary',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  _pdfTableRow('Eco Score', '${data.ecoScore}', isHeader: true),
                  _pdfTableRow('Total Rides', '${data.totalRides}'),
                  _pdfTableRow('CO₂ Saved', data.co2Saved),
                  _pdfTableRow('Rank', data.rankText),
                ],
              ),
              pw.SizedBox(height: 24),
              // Weekly breakdown
              pw.Text(
                'Carbon Saved — Last 7 Days',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  _pdfTableRow('Day', 'Carbon Saved (kg)', isHeader: true),
                  _pdfTableRow('Monday', data.chartSpots[0].y.toStringAsFixed(1)),
                  _pdfTableRow('Tuesday', data.chartSpots[1].y.toStringAsFixed(1)),
                  _pdfTableRow('Wednesday', data.chartSpots[2].y.toStringAsFixed(1)),
                  _pdfTableRow('Thursday', data.chartSpots[3].y.toStringAsFixed(1)),
                  _pdfTableRow('Friday', data.chartSpots[4].y.toStringAsFixed(1)),
                  _pdfTableRow('Saturday', data.chartSpots[5].y.toStringAsFixed(1)),
                  _pdfTableRow('Sunday', data.chartSpots[6].y.toStringAsFixed(1)),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'Thank you for making eco-friendly choices!',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColor.fromHex('4CAF50'),
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    try {
      await Printing.sharePdf(bytes: bytes, filename: 'eco_impact_${data.label.replaceAll(' ', '_')}.pdf');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share PDF. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  pw.TableRow _pdfTableRow(String label, String value, {bool isHeader = false}) {
    final style = isHeader
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)
        : const pw.TextStyle(fontSize: 11);
    final bg = isHeader ? PdfColor.fromHex('E8F5E9') : PdfColors.white;
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bg),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: style),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, style: style),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Your Impact',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            color: AppTheme.primaryGreen,
            tooltip: 'Download Impact Report',
            onPressed: _downloadImpact,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVehicleFilter(context),
            const SizedBox(height: 20),
            _buildScoreCard(context),
            const SizedBox(height: 24),
            _buildCarbonChart(context),
            const SizedBox(height: 24),
            _buildStatGrid(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleFilter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Vehicle',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: VehicleFilter.values.map((filter) {
              final data = _vehicleData[filter]!;
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? data.accentColor : (isDark ? AppTheme.cardDark : Colors.white),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? data.accentColor : (isDark ? Colors.white24 : Colors.black12),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          data.icon,
                          size: 14,
                          color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black54),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    final data = _current;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [data.accentColor, data.accentColor.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, color: Colors.black, size: 24),
              const SizedBox(width: 12),
              Text(
                'Eco Score — ${data.label}',
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _downloadImpact,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download_rounded, color: Colors.black, size: 16),
                      SizedBox(width: 4),
                      Text('Download', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${data.ecoScore}',
            style: const TextStyle(color: Colors.black, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          Text(data.rankText, style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCarbonChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = _current;
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Carbon Saved — ${data.label}',
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text('Last 7 Days', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
                        return Text(days[idx], style: TextStyle(color: Colors.grey[500], fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.chartSpots,
                    isCurved: true,
                    color: data.accentColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: data.accentColor.withOpacity(0.15)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context) {
    final data = _current;
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, '${data.totalRides}', 'Rides', data.icon)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, data.co2Saved, 'CO₂ Saved', FontAwesomeIcons.leaf)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _current.accentColor, size: 24),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildActionButton(context, 'View Rewards', FontAwesomeIcons.trophy, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RewardsScreen()));
        }),
        const SizedBox(height: 12),
        _buildActionButton(context, 'Green Routes', FontAwesomeIcons.route, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GreenRouteScreen()));
        }),
        const SizedBox(height: 12),
        _buildActionButton(context, 'Eco Leaderboard', FontAwesomeIcons.rankingStar, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EcoLeaderboardScreen()));
        }),
        const SizedBox(height: 12),
        _buildActionButton(context, 'Impact History', FontAwesomeIcons.clockRotateLeft, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ImpactHistoryScreen()));
        }),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
