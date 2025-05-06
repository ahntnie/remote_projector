// import 'dart:io';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:remote_projector_2024/constants/firebase_api.dart';
// import 'package:remote_projector_2024/firebase_options.dart';
// import 'package:responsive_builder/responsive_builder.dart';
// import 'package:stacked_services/stacked_services.dart';
// import 'package:window_size/window_size.dart';

// import 'app/app.locator.dart';
// import 'app/app.router.dart';
// import 'app/di.dart';
// import 'constants/app_color.dart';
// import 'service/google_sign_in_api.service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     // Khởi tạo Firebase một lần duy nhất
//     await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform);
//     print('🔥 Firebase initialized successfully');
//   } catch (e) {
//     print('❌ Error initializing Firebase: $e');
//   }
//   // await FirebaseApi().initNotifications();
//   await DependencyInjection.init();
//   await setupLocator();
//   GoogleSignInService.initialize();
//   ResponsiveSizingConfig.instance.setCustomBreakpoints(
//     const ScreenBreakpoints(desktop: 750, tablet: 600, watch: 200),
//   );
//   runApp(const MyApp());

//   if (!kIsWeb && !(Platform.isIOS || Platform.isAndroid)) {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       setWindowMinSize(const Size(400, 600));
//     });
//   }
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   static String FCM_TOPIC_ALL = "tsgt";
//   @override
//   void initState() {
//     super.initState();
//     FirebaseApi firebaseApi = FirebaseApi();
//     firebaseApi.initNotifications();
//     FirebaseMessaging.instance.subscribeToTopic(FCM_TOPIC_ALL);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'TS Screen',
//       navigatorKey: StackedService.navigatorKey,
//       onGenerateRoute: StackedRouter().onGenerateRoute,
//       initialRoute: Routes.splashPage,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: AppColor.appBarStart),
//         popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
//         useMaterial3: true,
//       ),
//     );
//   }
// }
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:remote_projector_2024/firebase_options.dart';

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
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _log = '';

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      setState(() => _log += 'Initializing Firebase...\n');
      await Firebase.initializeApp();
      setState(() => _log += 'Firebase initialized successfully\n');

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      setState(() => _log += 'Requesting notification permission...\n');
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      setState(() =>
          _log += 'Authorization Status: ${settings.authorizationStatus}\n');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        setState(
            () => _log += 'User granted permission, fetching APNs token...\n');
        String? apnsToken = await messaging.getAPNSToken();
        setState(() => _log += 'APNs Token: $apnsToken\n');

        if (apnsToken == null) {
          setState(() =>
              _log += 'APNs token is null, retrying after 2 seconds...\n');
          await Future.delayed(Duration(seconds: 2));
          apnsToken = await messaging.getAPNSToken();
          setState(() => _log += 'APNs Token after retry: $apnsToken\n');
        }

        setState(() => _log += 'Fetching FCM token...\n');
        String? fcmToken = await messaging.getToken();
        setState(() => _log += 'FCM Token: $fcmToken\n');
      } else {
        setState(() => _log += 'User did not grant full permission\n');
      }
    } catch (e, stackTrace) {
      setState(() => _log += 'Error: $e\n');
      setState(() => _log += 'StackTrace: $stackTrace\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Firebase Push Notification')),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(_log),
          ),
        ),
      ),
    );
  }
}
