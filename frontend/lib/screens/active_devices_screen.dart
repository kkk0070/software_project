import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';

class ActiveDevicesScreen extends StatefulWidget {
  const ActiveDevicesScreen({super.key});

  @override
  State<ActiveDevicesScreen> createState() => _ActiveDevicesScreenState();
}

class _ActiveDevicesScreenState extends State<ActiveDevicesScreen> {
  bool _isLoading = true;
  List<dynamic> _sessions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await AuthService.getSessions();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _sessions = result['sessions'] ?? [];
        } else {
          _error = result['message'];
        }
      });
    }
  }

  Future<void> _revokeSession(String sessionId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    final result = await AuthService.revokeSession(sessionId);
    if (!mounted) return;

    Navigator.pop(context); // Close loading dialog

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session revoked successfully')),
      );
      _fetchSessions(); // Refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to revoke session')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Active Devices',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
        ),
        backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppTheme.textDark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(color: isDark ? Colors.red[300] : Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchSessions,
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : _sessions.isEmpty
                  ? Center(
                      child: Text(
                        'No active sessions found.',
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        final isCurrentSession = false; // Logic can be improved to detect current session via refresh token matching
                        return Card(
                          color: isDark ? AppTheme.cardDark : Colors.white,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.devices,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            title: Text(
                              session['device_info'] ?? 'Unknown Device',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'IP: ${session['ip_address'] ?? 'Unknown'}',
                                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                ),
                                Text(
                                  'Last active: ${DateTime.parse(session['last_active']).toLocal().toString().split('.')[0]}',
                                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.logout, color: Colors.red),
                              onPressed: () => _revokeSession(session['id'].toString()),
                              tooltip: 'Revoke this session',
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
