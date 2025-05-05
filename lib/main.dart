import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:remote_projector_2024/constants/firebase_api.dart';
import 'package:remote_projector_2024/firebase_options.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:window_size/window_size.dart';

import 'app/app.locator.dart';
import 'app/app.router.dart';
import 'app/di.dart';
import 'constants/app_color.dart';
import 'service/google_sign_in_api.service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Khởi tạo Firebase một lần duy nhất
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print('🔥 Firebase initialized successfully');
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
  }
  // await FirebaseApi().initNotifications();
  await DependencyInjection.init();
  await setupLocator();
  GoogleSignInService.initialize();
  ResponsiveSizingConfig.instance.setCustomBreakpoints(
    const ScreenBreakpoints(desktop: 750, tablet: 600, watch: 200),
  );
  runApp(const MyApp());

  if (!kIsWeb && !(Platform.isIOS || Platform.isAndroid)) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setWindowMinSize(const Size(400, 600));
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static String FCM_TOPIC_ALL = "tsgt";
  @override
  void initState() {
    super.initState();
    FirebaseApi firebaseApi = FirebaseApi();
    firebaseApi.initNotifications();
    FirebaseMessaging.instance.subscribeToTopic(FCM_TOPIC_ALL);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TS Screen',
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      initialRoute: Routes.splashPage,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.appBarStart),
        popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
        useMaterial3: true,
      ),
    );
  }
}
