import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../services/storage_service.dart';
import '../../../services/chat_service.dart';
import '../driver/driver_profile_detail_screen.dart';
import 'chat_conversation_screen.dart';

/// Carpool Detail Screen
/// Shows detailed information about a carpool ride including:
/// - Driver information with profile access
/// - Route details (pickup and drop-off)
/// - Fare information
/// - Seats available
/// - Date and time
/// - Carbon savings
/// - Option to chat with driver
/// - Accept carpool button
class CarpoolDetailScreen extends StatefulWidget {
  final Map<String, dynamic> carpoolData;

  const CarpoolDetailScreen({
    super.key,
    required this.carpoolData,
  });

  @override
  State<CarpoolDetailScreen> createState() => _CarpoolDetailScreenState();
}

class _CarpoolDetailScreenState extends State<CarpoolDetailScreen> {
  bool _isAccepting = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Carpool Details',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Section
            FadeInDown(
              child: _buildDriverSection(isDark),
            ),
            
            const SizedBox(height: 16),
            
            // Route Section
            FadeInLeft(
              delay: const Duration(milliseconds: 100),
              child: _buildRouteSection(isDark),
            ),
            
            const SizedBox(height: 16),
            
            // Fare and Details Section
            FadeInLeft(
              delay: const Duration(milliseconds: 200),
              child: _buildFareSection(isDark),
            ),
            
            const SizedBox(height: 16),
            
            // Additional Info Section
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildAdditionalInfoSection(isDark),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildActionButtons(isDark),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Driver Avatar
              GestureDetector(
                onTap: () => _navigateToDriverProfile(),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppTheme.primaryGreen,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Driver Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.carpoolData['driver'] ?? 'Unknown Driver',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Driver',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: AppTheme.ecoGold,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.carpoolData['rating'] ?? 0.0}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${widget.carpoolData['tripCount'] ?? 0} trips)',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Chat Button
              IconButton(
                onPressed: () => _startChat(),
                icon: Icon(
                  FontAwesomeIcons.message,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
                tooltip: 'Chat with driver',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // View Profile Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _navigateToDriverProfile(),
              icon: Icon(
                Icons.person,
                color: AppTheme.primaryGreen,
                size: 18,
              ),
              label: Text(
                'View Driver Profile',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // Pickup Location
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.carpoolData['pickup'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Route Line
          Padding(
            padding: const EdgeInsets.only(left: 19),
            child: Container(
              width: 2,
              height: 40,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
          ),
          
          // Drop-off Location
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.errorRed.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.flag,
                  color: AppTheme.errorRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drop-off',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.carpoolData['dropoff'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFareSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fare Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price per Seat',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.carpoolData['price'] ?? '\$0.00',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.userGroup,
                      color: AppTheme.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.carpoolData['seats'] ?? 0} seats',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'available',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildInfoRow(
            icon: FontAwesomeIcons.clock,
            label: 'Date & Time',
            value: widget.carpoolData['date'] ?? 'Not specified',
            isDark: isDark,
          ),
          const Divider(height: 32),
          
          _buildInfoRow(
            icon: FontAwesomeIcons.leaf,
            label: 'Carbon Savings',
            value: widget.carpoolData['carbonSaved'] ?? '0 kg CO₂',
            isDark: isDark,
            valueColor: AppTheme.primaryGreen,
          ),
          const Divider(height: 32),
          
          _buildInfoRow(
            icon: FontAwesomeIcons.route,
            label: 'Estimated Distance',
            value: widget.carpoolData['distance'] ?? 'N/A',
            isDark: isDark,
          ),
          const Divider(height: 32),
          
          _buildInfoRow(
            icon: FontAwesomeIcons.hourglass,
            label: 'Estimated Duration',
            value: widget.carpoolData['duration'] ?? 'N/A',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryGreen.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 16,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Accept Carpool Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isAccepting ? null : () => _acceptCarpool(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                disabledBackgroundColor: AppTheme.primaryGreen.withOpacity(0.5),
              ),
              child: _isAccepting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.black,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Accept Carpool',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Chat with Driver Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _startChat(),
              icon: Icon(
                FontAwesomeIcons.message,
                color: AppTheme.primaryGreen,
                size: 16,
              ),
              label: Text(
                'Chat with Driver',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDriverProfile() {
    // Navigate to driver profile screen
    // Pass the driver data from carpool
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverProfileDetailScreen(
          driver: {
            'id': widget.carpoolData['driverId'],
            'name': widget.carpoolData['driver'],
            'rating': widget.carpoolData['rating'],
            'totalTrips': widget.carpoolData['tripCount'],
          },
        ),
      ),
    );
  }

  Future<void> _startChat() async {
    try {
      final currentUserId = await StorageService.getUserId();
      if (currentUserId == null) {
        _showError('Please login to chat');
        return;
      }

      final driverId = widget.carpoolData['driverId'];
      if (driverId == null) {
        _showError('Driver information not available');
        return;
      }

      // Get or create conversation
      final result = await ChatService.getOrCreateConversation(
        riderId: currentUserId,
        driverId: driverId,
      );

      if (result['success'] == true && result['data'] != null) {
        final conversationId = result['data']['id'];
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatConversationScreen(
                conversationId: conversationId,
                otherUserId: driverId,
                otherUserName: widget.carpoolData['driver'] ?? 'Driver',
                currentUserId: currentUserId,
              ),
            ),
          );
        }
      } else {
        _showError(result['message'] ?? 'Failed to start chat');
      }
    } catch (e) {
      _showError('Error starting chat: $e');
    }
  }

  Future<void> _acceptCarpool() async {
    setState(() {
      _isAccepting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isAccepting = false;
      });

      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withOpacity(0.2),
              ),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Carpool Accepted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You have successfully joined this carpool ride. The driver will be notified.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }
}
