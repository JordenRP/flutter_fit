import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.get('/api/notifications');
      setState(() {
        notifications = List<Map<String, dynamic>>.from(response ?? []);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки уведомлений: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await ApiService.post('/api/notifications/mark-read?id=$notificationId', {});
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления уведомления: ${e.toString()}')),
        );
      }
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'training_reminder':
        return Colors.blue.shade100;
      case 'meal_reminder':
        return Colors.green.shade100;
      case 'progress_reminder':
        return Colors.orange.shade100;
      case 'general_tip':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'training_reminder':
        return Icons.fitness_center;
      case 'meal_reminder':
        return Icons.restaurant;
      case 'progress_reminder':
        return Icons.trending_up;
      case 'general_tip':
        return Icons.lightbulb;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'training_reminder':
        return 'Напоминание о тренировке';
      case 'meal_reminder':
        return 'Напоминание о питании';
      case 'progress_reminder':
        return 'Напоминание о прогрессе';
      case 'general_tip':
        return 'Полезный совет';
      default:
        return 'Уведомление';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Уведомления'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Text(
                    'Нет уведомлений',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final createdAt = DateTime.parse(notification['created_at']);
                      final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(createdAt);
                      
                      return Card(
                        color: _getNotificationColor(notification['type']),
                        child: ListTile(
                          leading: Icon(_getNotificationIcon(notification['type'])),
                          title: Text(_getNotificationTitle(notification['type'])),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification['message']),
                              Text(
                                formattedDate,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: notification['is_read']
                              ? Icon(Icons.done_all, color: Colors.green)
                              : TextButton(
                                  child: Text('Отметить'),
                                  onPressed: () => _markAsRead(notification['id']),
                                ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
} 