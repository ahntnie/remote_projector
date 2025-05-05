import 'package:remote_projector_2024/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../app/app.locator.dart';
import '../models/notification/notification_model.dart';
import '../requests/notification/notification.request.dart';

class NotificationViewModel extends BaseViewModel {
  final NotificationRequest _notificationRequest = NotificationRequest();
  final _navigationService = appLocator<NavigationService>();

  final List<NotificationModel> _listNotification = [];
  List<NotificationModel> get listNotification => _listNotification;

  void initialise() {
    _fetchNotification();
  }

  @override
  void dispose() {
    _listNotification.clear();

    super.dispose();
  }

  Future<void> refreshNotification() async {
    await _fetchNotification();
  }

  Future<void> updateAllNotification() async {
    setBusy(true);

    for (var notification in _listNotification) {
      if (notification.seen == '0' && notification.idNotify != null) {
        await _notificationRequest
            .updateNotificationById(notification.idNotify!);
      }
    }
    await _fetchNotification();

    setBusy(false);
  }

  Future<void> onNotificationTaped(NotificationModel notification) async {
    if (notification.seen == '0' && notification.idNotify != null) {
      _notificationRequest.updateNotificationById(notification.idNotify!);
    }
    await _navigationService.navigateToNotificationDetailPage(
        notification: notification);
    await _fetchNotification();
  }

  Future<void> _fetchNotification() async {
    setBusy(true);

    List<NotificationModel> list =
        await _notificationRequest.getMyNotification();
    _listNotification.clear();
    _listNotification.addAll(list);

    setBusy(false);
  }
}
