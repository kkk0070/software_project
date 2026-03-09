import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class TransportationScreen extends StatefulWidget {
  const TransportationScreen({super.key});

  @override
  State<TransportationScreen> createState() => _TransportationScreenState();
}

class _TransportationScreenState extends State<TransportationScreen> {
  String selectedMode = 'Flights';
  bool showEcoOptionsOnly = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Transportation Hub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          _buildEcoToggle(),
          _buildTransportModes(),
          Expanded(
            child: _buildTransportList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    final theme = Theme.of(context);
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: theme.cardColor,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildLocationField('From', 'New York', Icons.flight_takeoff),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    icon: const Icon(Icons.swap_horiz, color: AppTheme.transportBlue),
                    onPressed: () {},
                  ),
                ),
                Expanded(
                  child: _buildLocationField('To', 'London', Icons.flight_land),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField('Departure', 'Dec 15'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField('Return', 'Dec 22'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField('Passengers', '2 Adults'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.transportBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoToggle() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 100),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.ecoGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.leaf,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eco-Friendly Options',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Electric, Hybrid & Low Emission',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: showEcoOptionsOnly,
              onChanged: (value) {
                setState(() {
                  showEcoOptionsOnly = value;
                });
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportModes() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 200),
      child: SizedBox(
        height: 60,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildModeCard('Flights', FontAwesomeIcons.plane, Colors.blue.shade600),
            _buildModeCard('Trains', FontAwesomeIcons.train, Colors.green.shade600),
            _buildModeCard('Buses', FontAwesomeIcons.bus, Colors.orange.shade600),
            _buildModeCard('EV Rides', FontAwesomeIcons.carSide, Colors.teal.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(String mode, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isSelected = selectedMode == mode;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : theme.dividerColor,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              FaIcon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 8),
              Text(
                mode,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransportList() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildTransportCard(index);
        },
      ),
    );
  }

  Widget _buildTransportCard(int index) {
    final theme = Theme.of(context);
    // Different data based on selected mode
    final flightData = [
      {
        'provider': 'Air France',
        'from': 'JFK',
        'to': 'CDG',
        'departure': '08:30 AM',
        'arrival': '10:45 PM',
        'duration': '7h 15m',
        'price': '\$650',
        'carbonEmission': 245.5,
        'isEcoFriendly': false,
        'class': 'Economy',
      },
      {
        'provider': 'EcoAir',
        'from': 'JFK',
        'to': 'CDG',
        'departure': '11:00 AM',
        'arrival': '01:15 AM',
        'duration': '7h 15m',
        'price': '\$720',
        'carbonEmission': 180.0,
        'isEcoFriendly': true,
        'class': 'Economy',
      },
    ];

    final trainData = [
      {
        'provider': 'Eurostar',
        'from': 'London St Pancras',
        'to': 'Paris Gare du Nord',
        'departure': '09:31 AM',
        'arrival': '12:47 PM',
        'duration': '2h 16m',
        'price': '€89',
        'carbonEmission': 15.5,
        'isEcoFriendly': true,
        'class': 'Standard',
      },
      {
        'provider': 'TGV',
        'from': 'Paris',
        'to': 'Lyon',
        'departure': '07:00 AM',
        'arrival': '09:00 AM',
        'duration': '2h 00m',
        'price': '€95',
        'carbonEmission': 12.0,
        'isEcoFriendly': true,
        'class': 'Standard',
      },
    ];

    final busData = [
      {
        'provider': 'FlixBus',
        'from': 'Berlin',
        'to': 'Prague',
        'departure': '08:00 AM',
        'arrival': '12:30 PM',
        'duration': '4h 30m',
        'price': '€19',
        'carbonEmission': 8.5,
        'isEcoFriendly': true,
        'class': 'Standard',
      },
      {
        'provider': 'MegaBus',
        'from': 'London',
        'to': 'Edinburgh',
        'departure': '23:30 PM',
        'arrival': '08:15 AM',
        'duration': '8h 45m',
        'price': '£25',
        'carbonEmission': 10.2,
        'isEcoFriendly': false,
        'class': 'Sleeper',
      },
    ];

    final evData = [
      {
        'provider': 'Tesla Ride',
        'from': 'Downtown',
        'to': 'Airport',
        'departure': 'Now',
        'arrival': 'Est. 25 min',
        'duration': '25 min',
        'price': '\$35',
        'carbonEmission': 0.0,
        'isEcoFriendly': true,
        'class': 'Model 3',
      },
      {
        'provider': 'EV Pool',
        'from': 'City Center',
        'to': 'Business District',
        'departure': 'Now',
        'arrival': 'Est. 18 min',
        'duration': '18 min',
        'price': '\$22',
        'carbonEmission': 0.0,
        'isEcoFriendly': true,
        'class': 'Pooled',
      },
    ];

    Map<String, dynamic> transport;
    if (selectedMode == 'Flights') {
      transport = flightData[index % flightData.length];
    } else if (selectedMode == 'Trains') {
      transport = trainData[index % trainData.length];
    } else if (selectedMode == 'Buses') {
      transport = busData[index % busData.length];
    } else {
      transport = evData[index % evData.length];
    }

    final isEcoFriendly = transport['isEcoFriendly'] as bool;
    final carbonEmission = transport['carbonEmission'] as double;

    if (showEcoOptionsOnly && !isEcoFriendly) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transport['provider'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (isEcoFriendly)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.eco,
                          color: AppTheme.successGreen,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          carbonEmission == 0 ? 'Zero Emission' : 'Low Emission',
                          style: const TextStyle(
                            color: AppTheme.successGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Route and Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transport['departure'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transport['from'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        selectedMode == 'Flights'
                            ? Icons.flight
                            : selectedMode == 'Trains'
                                ? Icons.train
                                : selectedMode == 'Buses'
                                    ? Icons.directions_bus
                                    : Icons.electric_car,
                        color: AppTheme.transportBlue,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transport['duration'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        transport['arrival'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transport['to'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_outlined,
                          size: 16,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${carbonEmission.toStringAsFixed(1)} kg CO₂',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          transport['class'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transport['price'] as String,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.transportBlue,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.transportBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
