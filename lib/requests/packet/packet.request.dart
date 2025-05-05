import 'dart:convert';

import 'package:dio/dio.dart';

import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../constants/app_api.dart';
import '../../constants/app_constants.dart';
import '../../models/notification/notification_model.dart';
import '../../models/packet/my_packet_model.dart';
import '../../models/packet/packet_model.dart';
import '../../models/response/response_result.dart';
import '../../models/transaction/transaction_model.dart';
import '../../models/user/user.dart';
import '../notification/notification.request.dart';

class PacketRequest {
  final Dio _dio = Dio();
  final NotificationRequest _notificationRequest = NotificationRequest();

  Future<List<PacketModel>> getAllPacket() async {
    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.getAllPacket}',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Packet_list'];
      List<PacketModel> listPacket = list.isNotEmpty
          ? list.map((e) => PacketModel.fromJson(e)).toList()
          : [];

      return listPacket;
    } catch (_) {}

    return [];
  }

  Future<List<MyPacketModel>> getPacketPurchased() async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
      final response = await _dio.get(
        '${Api.hostApi}${Api.getPacketByCustomerId}/${currentUser.customerId}',
      );
      print(
          '${Api.hostApi}${Api.getPacketByCustomerId}/${currentUser.customerId}');
      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Packet_list'];
      List<MyPacketModel> listPacket = list.isNotEmpty
          ? list.map((e) => MyPacketModel.fromJson(e)).toList()
          : [];

      return listPacket;
    } catch (_) {}

    return [];
  }

  Future<List<TransactionModel>> getTransaction() async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
      final response = await _dio.post(
        '${Api.hostApi}${Api.getTransactionByCustomerId}',
        data: FormData.fromMap({
          'customer_id': currentUser.customerId,
        }),
      );

      List<dynamic> list = response.data['transaction_list'];
      List<TransactionModel> listTransaction = list.isNotEmpty
          ? list.map((e) => TransactionModel.fromJson(e)).toList()
          : [];

      return listTransaction;
    } catch (_) {}

    return [];
  }

  Future<ResponseResult<bool>> cancelPacketById(String? paidId) async {
    dynamic error;
    try {
      final response =
          await _dio.get('${Api.hostApi}${Api.cancelPacketById}/$paidId');

      final responseData = jsonDecode(response.data);
      int status = responseData['status'];

      if (status == AppConstants.statusSuccess) {
        return ResponseResult.success(true);
      } else if (status == AppConstants.statusShowMessage) {
        return ResponseResult.error(responseData['msg']);
      }
    } catch (e) {
      error = e;
    }

    return getErrorFromException(error: error);
  }

  Future<ResponseResult<bool>> buyPacketByCustomerId(
      PacketModel packet, int? payMonth,
      {bool autoActive = false}) async {
    dynamic error;

    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
      final formData = FormData.fromMap({
        'packet_id': packet.packetId,
        'name_packet': packet.namePacket,
        'price': packet.price,
        'description': packet.description,
        'detail': packet.detail,
        'customer_id': currentUser.customerId,
        'is_trial': packet.isTrial != '1' ? '0' : '1',
        'pay_month': payMonth,
        'is_business': packet.isBusiness,
      });
      print({
        'packet_id': packet.packetId,
        'name_packet': packet.namePacket,
        'price': packet.price,
        'description': packet.description,
        'detail': packet.detail,
        'customer_id': currentUser.customerId,
        'is_trial': packet.isTrial != '1' ? '0' : '1',
        'pay_month': payMonth,
        'is_business': packet.isBusiness,
      });
      final response = await _dio.post(
        '${Api.hostApi}${Api.buyPacketByIdCustomer}',
        data: formData,
      );
      
      final responseData = jsonDecode(response.data);
      int status = responseData['status'];

      if (status == AppConstants.statusSuccess) {
        final NotificationModel notify = NotificationModel(
          title: 'Đơn hàng mới',
          description: 'Có đơn hàng mới từ ${currentUser.customerName}',
          detail:
              'Người dùng ${currentUser.customerName} đã mua gói cước ${packet.namePacket}, hãy xem trong mục "Danh sách đơn hàng mới" để kích hoạt',
        );
        _notificationRequest.createAdminNotification(notify);

        return ResponseResult.success(true);
      } else if (status == AppConstants.statusShowMessage) {
        return ResponseResult.error(responseData['msg']);
      }
    } catch (e) {
      error = e;
    }

    return getErrorFromException(error: error);
  }

  Future<ResponseResult<bool>> renewalPacketByCustomerId(
    MyPacketModel packet,
    int? payMonth,
  ) async {
    dynamic error;
    final formData = FormData.fromMap({
      'packet_id': packet.packetId,
      'name_packet': packet.namePacket,
      'price': packet.price,
      'description': packet.description,
      'detail': packet.detail,
      'customer_id': packet.customerId,
      'pay_month': payMonth,
      'is_business': packet.isBusiness,
    });
    try {
      final response = await _dio.post(
        '${Api.hostApi}${Api.buyPacketByIdCustomer}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);
      int status = responseData['status'];

      if (status == AppConstants.statusSuccess) {
        final User currentUser =
            User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

        final NotificationModel notify = NotificationModel(
          title: 'Đơn hàng mới',
          description: 'Có đơn hàng mới từ ${currentUser.customerName}',
          detail:
              'Người dùng ${currentUser.customerName} đã gia hạn gói cước ${packet.namePacket}, hãy xem trong mục "Gói cước mới" để kích hoạt',
        );
        _notificationRequest.createAdminNotification(notify);

        return ResponseResult.success(true);
      } else if (status == AppConstants.statusShowMessage) {
        return ResponseResult.error(responseData['msg']);
      }
    } catch (e) {
      error = e;
    }

    return getErrorFromException(error: error);
  }

  Future<ResponseResult<String?>> createPaymentUrl(MyPacketModel packet) async {
    dynamic error;
    final formData = FormData.fromMap({
      'paid_id': packet.paidId,
    });

    try {
      print({
        'paid_id': packet.paidId,
      });
      final response = await _dio.post(
        '${Api.hostApi}${Api.createPaymentVietQRUrl}',
        data: formData,
      );
      return ResponseResult.success(response.data['qrLink']);
    } catch (e) {
      error = e;
    }

    return getErrorFromException(error: error);
  }
}
