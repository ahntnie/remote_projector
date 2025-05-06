import UIKit
import Flutter
import GoogleSignIn
import Firebase
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Khởi tạo Firebase
    FirebaseApp.configure()

    // Cấu hình Google Sign-In với clientID
    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "551379171312-qtfd1465t88lr3ghnt8nlqbrnbnqgemg.apps.googleusercontent.com")

    // Đăng ký Push Notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { granted, error in
          if let error = error {
            print("Error requesting notification permission: \(error)")
          } else {
            print("Notification permission granted: \(granted)")
          }
        })
    }
    application.registerForRemoteNotifications()

    // Đăng ký plugin Flutter
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Xử lý Google Sign-In URL
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }

  // Xử lý APNs token
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Gửi APNs token tới Firebase
    Messaging.messaging().setAPNSToken(deviceToken, type: .prod) // Dùng .sandbox nếu build Debug
    print("APNs token received: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
  }

  // Xử lý lỗi đăng ký APNs
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register for remote notifications: \(error)")
  }
}