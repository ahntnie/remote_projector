import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:remote_projector_2024/app/app_sp.dart';
import 'package:remote_projector_2024/app/app_sp_key.dart';

// Top-level function để xử lý thông báo background
Future<void> _handleBackground(RemoteMessage message) async {
  print('Background Notification:');
  print("Data: ${message.data}");

  // Lấy title và body từ data
  final title = message.data['title'];
  final body = message.data['body'];
  if (title != null && body != null) {
    await _showLocalNotification(title, body, message.data);
  }
}

// Top-level function để hiển thị thông báo cục bộ
Future<void> _showLocalNotification(
    String title, String body, Map<String, dynamic> data) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'tsgt_notification_channel_id',
    'TS Screen Notifications',
    channelDescription: 'Thông báo TS Screen',
    importance: Importance.high,
    priority: Priority.high,
    largeIcon: DrawableResourceAndroidBitmap('ic_notification'),
    icon: '@drawable/notification',
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );

  final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await localNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    platformDetails,
    payload: jsonEncode(data),
  );
}

class FirebaseApi {
  final firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String FCM_TOPIC_ALL = "tsgt";
  String? token;

  Future<void> initNotifications() async {
    // Yêu cầu quyền thông báo
    await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    // token = await firebaseMessaging.getToken();
    // AppSP.set(AppSPKey.customer_token, token);
    // print('FCM Token: $token');

    // Đăng ký topic
    await firebaseMessaging.subscribeToTopic(FCM_TOPIC_ALL);

    // Thiết lập xử lý background và foreground
    FirebaseMessaging.onBackgroundMessage(_handleBackground);
    FirebaseMessaging.onMessage.listen(_handleForeground);

    await _initializeLocalNotifications();
  }

  String? getToken() {
    return token;
  }

  Future<void> _handleForeground(RemoteMessage message) async {
    print('Foreground Notification:');
    print("Data: ${message.data}");

    // Lấy title và body từ data
    final title = message.data['title'];
    final body = message.data['body'];
    if (title != null && body != null) {
      await _showLocalNotification(title, body, message.data);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );

    // Tạo kênh thông báo cho Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'tsgt_notification_channel_id',
      'TS Screen Notifications',
      description: 'Thông báo TS Screen',
      importance: Importance.high,
    );
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void onNotificationTap(NotificationResponse response) async {
    final data = jsonDecode(response.payload!);
    print('Notification tapped: $data');
    // Xử lý khi nhấn thông báo
  }
}
