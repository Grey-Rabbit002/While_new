import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/view_model/providers/user_notif_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    APIs.markAllNotificationsAsRead(APIs.me.id);
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsyncValue = ref.watch(myNotificationsProvider);
    const backgroundColor = Color(0xFFF0F0F3);
    const shadowColor = Color(0xFFD1D9E6);
    const lightShadowColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: notificationsAsyncValue.when(
        data: (List<Map<String, dynamic>> notifications) {
          // Updated to expect List<Map<String, dynamic>>
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> notification = notifications[index];
              final String notificationText = notification['notificationText'];
              final Timestamp timestamp = notification['timeStamp'];
              final DateTime notificationTime = timestamp.toDate();
              final String timeAgo =
                  timeago.format(notificationTime, allowFromNow: true);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: shadowColor,
                          offset: Offset(-6, -6),
                          blurRadius: 10),
                      BoxShadow(
                          color: lightShadowColor,
                          offset: Offset(6, 6),
                          blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // To separate text and timestamp
                    children: [
                      Expanded(
                          child: Text(notificationText,
                              style: const TextStyle(fontSize: 16))),
                      Text(timeAgo,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
