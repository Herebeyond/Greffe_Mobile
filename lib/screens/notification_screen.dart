import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/notification.dart';
import '../widgets/error_handler.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final auth = context.read<AuthService>();
      final api = ApiService(auth.token!);
      final items = await api.getNotifications();
      if (mounted) setState(() { _notifications = items; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        handleApiError(context, e);
        setState(() { _error = e.toString(); _isLoading = false; });
      }
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    try {
      final auth = context.read<AuthService>();
      final api = ApiService(auth.token!);
      await api.markNotificationRead(notification.id);
      _load(); // refresh
    } catch (e) {
      if (mounted) handleApiError(context, e);
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'access_granted':
        return Icons.lock_open;
      case 'access_revoked':
        return Icons.lock;
      case 'access_transferred':
        return Icons.swap_horiz;
      case 'donor_linked':
        return Icons.link;
      case 'patient_edited':
        return Icons.edit;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            FilledButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(child: Text('Aucune notification'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: n.isRead ? null : Theme.of(context).colorScheme.primaryContainer.withAlpha(60),
            child: ListTile(
              leading: Icon(
                _iconForType(n.type),
                color: n.isRead ? Colors.grey : Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                n.message,
                style: TextStyle(
                  fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${n.createdAt ?? ''}'
                '${n.triggeredByName != null ? ' — ${n.triggeredByName}' : ''}',
              ),
              trailing: n.isRead
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      tooltip: 'Marquer comme lu',
                      onPressed: () => _markAsRead(n),
                    ),
              onTap: () => _markAsRead(n),
            ),
          );
        },
      ),
    );
  }
}
