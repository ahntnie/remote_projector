import 'package:flutter/material.dart';

import '../../models/notification/notification_model.dart';
import '../../widget/base_page.dart';

class NotificationDetailPage extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailPage({
    super.key,
    required this.notification,
  });

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Thông báo'.toUpperCase(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.notification.title ?? '',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.notification.description ?? '',
              style: const TextStyle(color: Colors.black, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Text(
              'Thời gian: ${widget.notification.createdDate ?? ''}',
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Text(
              widget.notification.detail ?? '',
              textAlign: TextAlign.justify,
              style: const TextStyle(color: Colors.black, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
