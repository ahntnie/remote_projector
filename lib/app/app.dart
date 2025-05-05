import 'package:remote_projector_2024/view/lucky_wheel/lucky_wheel.page.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../view/account/change_password_page.dart';
import '../view/authentication/authentication_page.dart';
import '../view/authentication/create_new_password_page.dart';
import '../view/authentication/forgot_password_page.dart';
import '../view/camp/edit_camp_page.dart';
import '../view/camp/review_video_page.dart';
import '../view/camp_profile/camp_profile_page.dart';
import '../view/device/device_detail_page.dart';
import '../view/device/device_of_camp_page.dart';
import '../view/device/device_page.dart';
import '../view/dir/dir_setting_page.dart';
import '../view/home/home_page.dart';
import '../view/introduce/introduce_page.dart';
import '../view/notification/notification_detail_page.dart';
import '../view/notification/notification_page.dart';
import '../view/packet/packet_payment.dart';
import '../view/packet/viet_qr_payment_page.dart';
import '../view/remove_account/alert_remove_account_page.dart';
import '../view/remove_account/remove_account_page.dart';
import '../view/resource/resource_manager_page.dart';
import '../view/splash/splash_page.dart';
import '../view/start/start_page.dart';
import '../view/statistics/single_statistics_page.dart';
import '../view/web_view/my_web_view_page.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: SplashPage, initial: true),
    CustomRoute(
      page: HomePage,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    MaterialRoute(page: ChangePasswordPage),
    MaterialRoute(page: EditCampPage),
    MaterialRoute(page: DevicePage),
    MaterialRoute(page: DeviceDetailPage),
    MaterialRoute(page: AuthenticationPage),
    MaterialRoute(page: MyWebViewPage),
    MaterialRoute(page: IntroducePage),
    MaterialRoute(page: SingleStatisticsPage),
    CustomRoute(page: StartPage, durationInMilliseconds: 2000),
    MaterialRoute(page: CampProfilePage),
    MaterialRoute(page: ForgotPasswordPage),
    MaterialRoute(page: CreateNewPasswordPage),
    MaterialRoute(page: ReviewVideoPage),
    MaterialRoute(page: DeviceOfCampPage),
    MaterialRoute(page: NotificationPage),
    MaterialRoute(page: NotificationDetailPage),
    MaterialRoute(page: ResourceManagerPage),
    MaterialRoute(page: PacketPaymentPage),
    MaterialRoute(page: DirSettingPage),
    MaterialRoute(page: AlertRemoveAccountPage),
    MaterialRoute(page: RemoveAccountPage),
    MaterialRoute(page: VietQRPaymentPage),
    MaterialRoute(page: LuckyWheelPage),
  ],
  dependencies: [
    // Lazy singletons
    LazySingleton(classType: NavigationService),
    LazySingleton(
      classType: NavigationService,
      environments: {Environment.dev},
    ),
  ],
  logger: StackedLogger(),
  locatorName: 'appLocator',
  locatorSetupName: 'setupLocator',
)
class App {
  /// This class has no puporse besides housing the annotation that generates the required functionality
}
