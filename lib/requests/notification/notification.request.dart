import 'dart:convert';

import 'package:dio/dio.dart';

import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../constants/app_api.dart';
import '../../models/notification/notification_model.dart';
import '../../models/user/user.dart';

class NotificationRequest {
  final Dio _dio = Dio();

  Future<List<NotificationModel>> getMyNotification() async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
      final response = await _dio.get(
        '${Api.hostApi}${Api.getNotificationByCustomerId}/${currentUser.customerId}',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Nofity_list'];
      List<NotificationModel> listNotification = list.isNotEmpty
          ? list.map((e) => NotificationModel.fromJson(e)).toList()
          : [];

      return listNotification;
    } catch (_) {}

    return [];
  }

  Future<int> getNewNotificationCount() async {
    int count = 0;

    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

      final response = await _dio.get(
        '${Api.hostApi}${Api.getNewNotificationByCustomerId}/${currentUser.customerId}',
      );

      final responseData = jsonDecode(response.data);

      count = responseData['count'] ?? 0;
    } catch (_) {}

    return count;
  }

  Future<void> updateNotificationById(String notifyId) async {
    try {
      await _dio.get('${Api.hostApi}${Api.updateNotification}/$notifyId');
    } catch (_) {}
  }

  Future<void> createNotification(
      NotificationModel notification, String customerIdTo) async {
    final formData = FormData.fromMap({
      'customer_id': customerIdTo,
      'title': notification.title,
      'descript': notification.description,
      'detail': notification.detail,
      'picture': notification.picture,
    });

    try {
      await _dio.post(
        '${Api.hostApi}${Api.createNotification}',
        data: formData,
      );
    } catch (_) {}
  }

  Future<void> createAdminNotification(NotificationModel notification) async {
    try {
      List<String> listAdminId = await getListAdminId();

      for (var id in listAdminId) {
        await _dio.post(
          '${Api.hostApi}${Api.createAdminNotification}',
          data: FormData.fromMap({
            'account_id': id,
            'title': notification.detail,
            'descript': notification.description,
            'detail': notification.detail,
            'picture': notification.picture,
          }),
        );
      }
    } catch (_) {}
  }

  Future<List<String>> getListAdminId() async {
    List<String> listAdminId = [];

    try {
      final response = await _dio.get('${Api.hostApi}${Api.getListAdminId}');

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['accountList'];

      listAdminId = list.map((json) => json['account_id'].toString()).toList();
    } catch (_) {}

    return listAdminId;
  }
}
