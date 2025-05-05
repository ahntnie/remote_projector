import 'package:flutter/material.dart';

import '../../../models/notification/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel data;
  final ValueChanged<NotificationModel>? onNotificationTap;

  const NotificationItem({
    super.key,
    required this.data,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: data.seen != '0'
          ? Colors.grey.withOpacity(0.1)
          : Colors.grey.withOpacity(0.4),
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: InkWell(
        onTap: () => onNotificationTap?.call(data),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/ic_projector.png',
                width: 30,
                height: 30,
                color: Colors.black,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.createdDate ?? '',
                      maxLines: 1,
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      data.title ?? '',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data.description ?? '',
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
