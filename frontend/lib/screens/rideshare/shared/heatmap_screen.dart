import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// Demand Heatmap screen.
///
/// Visualises high-demand zones using coloured [Circle] overlays.
/// Each circle is sized proportionally to demand intensity and uses a
/// heat-colour gradient (green → yellow → red) to indicate hotness.
///
/// In production, replace [_demandPoints] with real-time data fetched from
/// the backend (e.g. via WebSocket or REST polling).
class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  GoogleMapController? _mapController;

  /// Sample demand data: {position, intensity 0–1, label}.
  static const List<_DemandPoint> _demandPoints = [
    _DemandPoint(LatLng(37.7749, -122.4194), 1.0, 'Downtown SF'),
    _DemandPoint(LatLng(37.7849, -122.4094), 0.85, 'Union Square'),
    _DemandPoint(LatLng(37.7649, -122.4294), 0.7, 'Mission District'),
    _DemandPoint(LatLng(37.7949, -122.3994), 0.6, 'Financial District'),
    _DemandPoint(LatLng(37.7549, -122.4394), 0.55, 'Castro'),
    _DemandPoint(LatLng(37.8049, -122.4494), 0.45, 'North Beach'),
    _DemandPoint(LatLng(37.7449, -122.4494), 0.4, 'Noe Valley'),
    _DemandPoint(LatLng(37.8149, -122.3894), 0.3, 'Embarcadero'),
    _DemandPoint(LatLng(37.7349, -122.4594), 0.25, 'Glen Park'),
  ];

  Set<Circle> _circles = {};
  bool _showLegend = true;

  @override
  void initState() {
    super.initState();
    _buildCircles();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ── Heatmap Circles ───────────────────────────────────────────────────────

  void _buildCircles() {
    final circles = <Circle>{};
    for (int i = 0; i < _demandPoints.length; i++) {
      final p = _demandPoints[i];
      circles.add(
        Circle(
          circleId: CircleId('demand_$i'),
          center: p.position,
          radius: 300 + p.intensity * 500, // 300–800 metres
          fillColor: _heatColor(p.intensity).withOpacity(0.45),
          strokeColor: _heatColor(p.intensity).withOpacity(0.7),
          strokeWidth: 1,
          consumeTapEvents: true,
          onTap: () => _showDemandInfo(p),
        ),
      );
    }
    setState(() => _circles = circles);
  }

  /// Maps an intensity in [0, 1] to a heat colour:
  ///   0 → blue/green (low demand)
  ///   0.5 → yellow (medium demand)
  ///   1 → red (high demand)
  Color _heatColor(double intensity) {
    if (intensity < 0.5) {
      // green → yellow
      return Color.lerp(
        Colors.green,
        Colors.yellow,
        intensity * 2,
      )!;
    } else {
      // yellow → red
      return Color.lerp(
        Colors.yellow,
        Colors.red,
        (intensity - 0.5) * 2,
      )!;
    }
  }

  void _showDemandInfo(_DemandPoint p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.locationDot,
                    color: _heatColor(p.intensity), size: 20),
                const SizedBox(width: 10),
                Text(
                  p.label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DemandBar(intensity: p.intensity, color: _heatColor(p.intensity)),
            const SizedBox(height: 8),
            Text(
              'Demand: ${(p.intensity * 100).round()}%  •  '
              '${(p.intensity * 40).round()} pending requests',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Demand Heatmap',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showLegend ? Icons.layers : Icons.layers_outlined,
              color: AppTheme.primaryGreen,
            ),
            onPressed: () => setState(() => _showLegend = !_showLegend),
            tooltip: 'Toggle legend',
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 13,
            ),
            onMapCreated: (c) => _mapController = c,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),

          // ── Legend ───────────────────────────────────────────────────────
          if (_showLegend)
            Positioned(
              bottom: 24,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.cardDark.withOpacity(0.93)
                      : Colors.white.withOpacity(0.93),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ride Demand',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _LegendGradientBar(),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Low',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 11)),
                        const SizedBox(width: 60),
                        Text('High',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ── My location button ────────────────────────────────────────────
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                    const LatLng(37.7749, -122.4194), 13),
              ),
              backgroundColor: AppTheme.primaryGreen,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper types & widgets ────────────────────────────────────────────────────

class _DemandPoint {
  final LatLng position;
  final double intensity; // 0–1
  final String label;

  const _DemandPoint(this.position, this.intensity, this.label);
}

class _DemandBar extends StatelessWidget {
  final double intensity;
  final Color color;

  const _DemandBar({required this.intensity, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: intensity,
        minHeight: 8,
        backgroundColor: Colors.grey.withOpacity(0.2),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _LegendGradientBar extends StatelessWidget {
  const _LegendGradientBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.yellow, Colors.red],
        ),
      ),
    );
  }
}
