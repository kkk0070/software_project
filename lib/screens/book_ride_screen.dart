import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class BookRideScreen extends StatefulWidget {
  const BookRideScreen({super.key});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  bool _isPooled = true;
  int _passengers = 1;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Ride'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Enhanced Map placeholder with gradient
            FadeInDown(
              child: Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative overlay
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.mapLocationDot,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Live Map Coming Soon',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Select your locations below',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

              // Pickup Location
              FadeInLeft(
                delay: const Duration(milliseconds: 100),
                child: TextField(
                  controller: _pickupController,
                  decoration: InputDecoration(
                    labelText: 'Pickup Location',
                    hintText: 'Enter pickup address',
                    prefixIcon: const Icon(Icons.location_on, color: AppTheme.primaryGreen),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () {
                        // Use current location
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Drop Location
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: TextField(
                  controller: _dropController,
                  decoration: const InputDecoration(
                    labelText: 'Drop Location',
                    hintText: 'Enter destination',
                    prefixIcon: Icon(Icons.flag, color: AppTheme.errorRed),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Ride Type Selection
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ride Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _RideTypeOption(
                                icon: FontAwesomeIcons.users,
                                label: 'Pool Ride',
                                subtitle: 'Save 30% & reduce CO₂',
                                isSelected: _isPooled,
                                onTap: () {
                                  setState(() {
                                    _isPooled = true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RideTypeOption(
                                icon: FontAwesomeIcons.carSide,
                                label: 'Solo Ride',
                                subtitle: 'Just you',
                                isSelected: !_isPooled,
                                onTap: () {
                                  setState(() {
                                    _isPooled = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Passengers count
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.user, 
                              color: AppTheme.primaryGreen, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Passengers',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _passengers > 1
                                  ? () {
                                      setState(() {
                                        _passengers--;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppTheme.primaryGreen,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$_passengers',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _passengers < 4
                                  ? () {
                                      setState(() {
                                        _passengers++;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppTheme.primaryGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Schedule
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 30)),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _selectedDate = date;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, 
                                        color: AppTheme.primaryGreen, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                        style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: _selectedTime,
                                  );
                                  if (time != null) {
                                    setState(() {
                                      _selectedTime = time;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, 
                                        color: AppTheme.primaryGreen, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedTime.format(context),
                                        style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Estimated Impact
              if (_isPooled)
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.successGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.leaf,
                          color: AppTheme.successGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estimated Carbon Savings',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.successGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '~1.5 kg CO₂ by pooling this ride',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.successGreen.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Book Button
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: ElevatedButton(
                  onPressed: () {
                    // Book ride logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ride booked successfully!'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RideTypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RideTypeOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryGreen
                : theme.colorScheme.onSurface.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            FaIcon(
              icon,
              color: isSelected ? AppTheme.primaryGreen : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? AppTheme.primaryGreen : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
