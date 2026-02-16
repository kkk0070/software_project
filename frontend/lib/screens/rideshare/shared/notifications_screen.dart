import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../services/notification_service.dart';
import '../../../services/storage_service.dart';
import '../../../models/notification_models.dart';
import 'chat_conversation_screen.dart';

/// 17️⃣ Notifications Page
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with WidgetsBindingObserver {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh notifications when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await NotificationService.getNotifications();
      
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> notificationsData = result['data'];
        setState(() {
          _notifications = notificationsData
              .map((json) => NotificationModel.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load notifications';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading notifications: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllNotifications() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Notifications'),
          content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final result = await NotificationService.deleteAllNotifications();
        
        if (result['success'] == true) {
          setState(() {
            _notifications.clear();
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'All notifications cleared'),
                backgroundColor: AppTheme.primaryGreen,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Failed to clear notifications'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing notifications: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications', style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_all, color: colorScheme.onSurface),
              tooltip: 'Clear All',
              onPressed: _clearAllNotifications,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        color: AppTheme.primaryGreen,
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadNotifications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.bell,
                    size: 64,
                    color: isDark ? Colors.grey[700] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll see notifications here',
                    style: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    // Navigate to chat conversation if it's a message notification
    if (notification.category == 'Message' && 
        notification.conversationId != null && 
        notification.senderId != null) {
      
      final currentUserId = await StorageService.getUserId();
      if (currentUserId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User session not found. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Navigate to chat conversation
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationScreen(
              conversationId: notification.conversationId!,
              otherUserId: notification.senderId!,
              otherUserName: _extractSenderName(notification.message),
              currentUserId: currentUserId,
            ),
          ),
        ).then((_) {
          // Reload notifications when coming back
          _loadNotifications();
        });
      }
    }
  }

  String _extractSenderName(String message) {
    // Message format is "SenderName: message..."
    final colonIndex = message.indexOf(':');
    if (colonIndex > 0) {
      return message.substring(0, colonIndex).trim();
    }
    return 'User';
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine icon and color based on category and type
    IconData icon;
    Color color;
    
    if (notification.category == 'Message') {
      icon = FontAwesomeIcons.message;
      color = AppTheme.primaryGreen;
    } else {
      switch (notification.type) {
        case 'Success':
          icon = FontAwesomeIcons.circleCheck;
          color = Colors.green;
          break;
        case 'Warning':
          icon = FontAwesomeIcons.triangleExclamation;
          color = Colors.orange;
          break;
        case 'Error':
          icon = FontAwesomeIcons.circleXmark;
          color = Colors.red;
          break;
        default:
          icon = FontAwesomeIcons.circleInfo;
          color = colorScheme.primary;
      }
    }

    final timeAgo = _formatTimeAgo(notification.createdAt);
    final isMessageNotification = notification.category == 'Message' && 
        notification.conversationId != null && 
        notification.senderId != null;
    
    return InkWell(
      onTap: isMessageNotification ? () => _handleNotificationTap(notification) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.read
              ? (isDark ? AppTheme.cardDark : Colors.white)
              : (isDark
                  ? AppTheme.cardDark.withOpacity(0.95)
                  : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.read
                ? (isDark ? Colors.grey[800]! : colorScheme.outline.withOpacity(0.1))
              : AppTheme.primaryGreen.withOpacity(0.3),
          width: notification.read ? 1 : 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: notification.read ? FontWeight.w600 : FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (!notification.read)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}
