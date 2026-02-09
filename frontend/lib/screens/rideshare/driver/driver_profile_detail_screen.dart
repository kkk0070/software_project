import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../services/storage_service.dart';
import '../../../services/chat_service.dart';
import '../shared/chat_conversation_screen.dart';

class DriverProfileDetailScreen extends StatefulWidget {
  final Map<String, dynamic> driver;
  final String? pickupLocation;
  final String? destinationLocation;

  const DriverProfileDetailScreen({
    super.key,
    required this.driver,
    this.pickupLocation,
    this.destinationLocation,
  });

  @override
  State<DriverProfileDetailScreen> createState() => _DriverProfileDetailScreenState();
}

class _DriverProfileDetailScreenState extends State<DriverProfileDetailScreen> {
  bool _isCreatingChat = false;
  bool _isBooking = false;

  Future<void> _startChat() async {
    setState(() {
      _isCreatingChat = true;
    });

    try {
      final currentUserId = await StorageService.getUserId();
      final currentUserRole = await StorageService.getUserRole();

      if (currentUserId == null) {
        _showError('User not logged in');
        return;
      }

      // Determine rider and driver IDs based on current user role
      int riderId;
      int driverId;

      if (currentUserRole == 'Driver') {
        // Current user is driver, so they are chatting with a rider
        driverId = currentUserId;
        riderId = widget.driver['id'];
      } else {
        // Current user is rider, chatting with driver
        riderId = currentUserId;
        driverId = widget.driver['id'];
      }

      // Create or get conversation
      final result = await ChatService.getOrCreateConversation(
        riderId: riderId,
        driverId: driverId,
      );

      setState(() {
        _isCreatingChat = false;
      });

      if (result['success'] == true && result['data'] != null) {
        final conversation = result['data'];
        
        // Navigate to chat conversation screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationScreen(
              conversationId: conversation['id'],
              otherUserId: widget.driver['id'],
              otherUserName: widget.driver['name'] ?? 'User',
              currentUserId: currentUserId,
            ),
          ),
        );
      } else {
        _showError(result['message'] ?? 'Failed to start chat');
      }
    } catch (e) {
      setState(() {
        _isCreatingChat = false;
      });
      _showError('Error starting chat: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  Future<void> _bookRide() async {
    // Check if booking context is provided
    if (widget.pickupLocation == null || widget.destinationLocation == null) {
      _showError('Please provide pickup and destination locations');
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final currentUserId = await StorageService.getUserId();
      if (currentUserId == null) {
        _showError('User not logged in');
        return;
      }

      // Simulate booking API call (replace with actual implementation)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _isBooking = false;
      });

      final isDark = Theme.of(context).brightness == Brightness.dark;

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Booking Confirmed!',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your ride with ${widget.driver['name']} has been booked successfully.',
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.backgroundDark : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBookingDetail('From', widget.pickupLocation!),
                    const SizedBox(height: 8),
                    _buildBookingDetail('To', widget.destinationLocation!),
                    const SizedBox(height: 8),
                    _buildBookingDetail('Driver', widget.driver['name']),
                    const SizedBox(height: 8),
                    _buildBookingDetail('Vehicle', widget.driver['vehicle_model'] ?? 'N/A'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to booking screen
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isBooking = false;
      });
      _showError('Error booking ride: $e');
    }
  }

  Widget _buildBookingDetail(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final driver = widget.driver;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Driver Profile',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                      border: Border.all(
                        color: AppTheme.primaryGreen,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      FontAwesomeIcons.user,
                      color: AppTheme.primaryGreen,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name
                  Text(
                    driver['name'] ?? 'Driver',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (driver['rating'] ?? 0.0).toString(),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${driver['total_rides'] ?? 0} rides)',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  // Verification Status
                  if (driver['verified'] == true || driver['verification_status'] == 'Verified')
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            color: AppTheme.primaryGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Verified Driver',
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Details Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Information',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Vehicle Model
                  if (driver['vehicle_model'] != null)
                    _buildInfoRow(
                      icon: FontAwesomeIcons.car,
                      label: 'Vehicle',
                      value: driver['vehicle_model'],
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Vehicle Type
                  if (driver['vehicle_type'] != null)
                    _buildInfoRow(
                      icon: FontAwesomeIcons.leaf,
                      label: 'Type',
                      value: driver['vehicle_type'],
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // License Plate
                  if (driver['license_plate'] != null)
                    _buildInfoRow(
                      icon: FontAwesomeIcons.idCard,
                      label: 'License Plate',
                      value: driver['license_plate'],
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Book Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (_isBooking || _isCreatingChat) ? null : _bookRide,
                          icon: _isBooking
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(FontAwesomeIcons.calendarCheck, size: 18),
                          label: Text(
                            _isBooking ? 'Booking...' : 'Book Ride',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Chat Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (_isCreatingChat || _isBooking) ? null : _startChat,
                          icon: _isCreatingChat
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(FontAwesomeIcons.message, size: 18),
                          label: Text(
                            _isCreatingChat ? 'Starting...' : 'Chat',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
                            foregroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppTheme.primaryGreen, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryGreen.withOpacity(0.2),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 18,
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
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
