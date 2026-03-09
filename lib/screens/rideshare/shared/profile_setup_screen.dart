import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:animate_do/animate_do.dart';
import '../../../theme/app_theme.dart';
import '../../../services/auth_service.dart';
import 'rideshare_home_screen.dart';
import '../driver/driver_profile_setup_screen.dart';
import 'location_picker_screen.dart';

/// Generic Profile Setup Screen
/// Shown after user signup (for both riders and drivers) to collect additional information
/// Can be skipped but encourages profile completion
class ProfileSetupScreen extends StatefulWidget {
  final String userRole;
  
  const ProfileSetupScreen({super.key, required this.userRole});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _skipSetup,
            child: Text(
              'Skip',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                FadeInDown(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: AppTheme.primaryGreen,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Complete Your Profile',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.userRole.toLowerCase() == 'driver'
                            ? 'Add your details to get started as a driver'
                            : 'Add your details to enhance your ride experience',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Phone field
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      prefixIcon: Icon(Icons.phone_outlined, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      filled: true,
                      fillColor: isDark ? AppTheme.cardDark : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        // Remove common formatting characters
                        final digitsOnly = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
                        
                        // Check if it contains only digits
                        if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
                          return 'Phone number should contain only digits';
                        }
                        
                        // Check minimum length
                        if (digitsOnly.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Location field
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: _openLocationPicker,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _locationController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Location',
                          labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          prefixIcon: Icon(Icons.location_on_outlined, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          suffixIcon: Icon(Icons.map, color: AppTheme.primaryGreen),
                          filled: true,
                          fillColor: isDark ? AppTheme.cardDark : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Info Card - Different message for driver vs rider
                if (widget.userRole.toLowerCase() == 'driver')
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'You\'ll need to upload documents and get verified before accepting rides',
                              style: TextStyle(
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Continue Button
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: isDark ? Colors.grey[700] : Colors.grey[400],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : Text(
                              widget.userRole.toLowerCase() == 'driver'
                                  ? 'Continue to Document Upload'
                                  : 'Complete Profile',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Skip Link
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Center(
                    child: TextButton(
                      onPressed: _skipSetup,
                      child: Text(
                        'I\'ll do this later',
                        style: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openLocationPicker() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPickerScreen(
            initialLocation: _locationController.text.trim(),
          ),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _locationController.text = result['address'] as String;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening location picker: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Update profile if fields are filled
        if (_phoneController.text.isNotEmpty || _locationController.text.isNotEmpty) {
          await AuthService.updateProfile(
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          );
        }

        // Mark profile setup as complete
        await AuthService.completeProfileSetup();

        if (!mounted) return;

        // Navigate based on role
        if (widget.userRole.toLowerCase() == 'driver') {
          // Drivers go to the driver-specific profile setup for vehicle details
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DriverProfileSetupScreen(),
            ),
          );
        } else {
          // Riders go directly to home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RideshareHomeScreen(userRole: widget.userRole.toLowerCase()),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _skipSetup() async {
    // Mark profile setup as complete when skipped to prevent banner from reappearing
    // Note: This sets the flag even though the user skipped, to indicate they've
    // been prompted. A future enhancement could add a separate 'skipped' status.
    try {
      await AuthService.completeProfileSetup();
    } catch (e) {
      // Log error but continue with navigation
      if (kDebugMode) {
        print('Warning: Failed to mark profile setup as complete: ${e.toString()}');
      }
    }

    if (!mounted) return;

    // Navigate to home based on role
    if (widget.userRole.toLowerCase() == 'driver') {
      // Drivers still go to driver-specific setup for vehicle details
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DriverProfileSetupScreen(),
        ),
      );
    } else {
      // Riders go to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RideshareHomeScreen(userRole: widget.userRole.toLowerCase()),
        ),
      );
    }
  }
}
