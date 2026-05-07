import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../features/auth/services/auth_controller.dart';
import '../../../features/shared/models/app_notification.dart';
import '../../../features/shared/services/noc_repository.dart';

class UserNotificationsScreen extends StatelessWidget {
  const UserNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final auth = context.watch<AuthController>();
    final profile = auth.currentProfile;
    final repository = context.read<NocRepository>();

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<AppNotification>>(
      stream: repository.watchNotifications(profile.id),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? const <AppNotification>[];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else if (notifications.isEmpty)
                const AppEmptyState(
                  icon: Icons.notifications_none_outlined,
                  title: 'No notifications yet',
                  message: 'You will see status updates here as officers review your applications.',
                )
              else
                Column(
                  children: notifications
                      .map(
                        (notification) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _NotificationTile(
                            colors: colors,
                            notification: notification,
                            onTap: notification.isRead
                                ? null
                                : () async {
                                    await repository.markNotificationRead(notification.id);
                                  },
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.colors, this.onTap});

  final AppNotification notification;
  final AppPalette colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: notification.isRead
                ? colors.border
                : colors.accent.withValues(alpha: 0.14),
            child: Icon(
              notification.isRead ? Icons.mark_email_read_outlined : Icons.notifications_active_outlined,
              color: notification.isRead ? colors.muted : colors.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (!notification.isRead)
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: AppBadge(
                          label: 'New',
                          color: colors.accent,
                          icon: Icons.fiber_manual_record,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(notification.message, style: const TextStyle(height: 1.5)),
                const SizedBox(height: 10),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(notification.createdAt),
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
