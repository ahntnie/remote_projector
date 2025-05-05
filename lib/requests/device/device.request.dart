import 'dart:convert';

import 'package:dio/dio.dart';

import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../app/app_utils.dart';
import '../../constants/app_api.dart';
import '../../models/device/device_model.dart';
import '../../models/device/device_shared_model.dart';
import '../../models/user/user.dart';

class DeviceRequest {
  final Dio _dio = Dio();

  Future<List<Device>> getDeviceOfCampByCampaignId(String? campaignId) async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

      final response = await _dio.get(
        '${Api.hostApi}${Api.getDeviceOfCampByCampId}/$campaignId',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Dir_list'];
      List<Device> listDevice =
          list.isNotEmpty ? list.map((e) => Device.fromJson(e)).toList() : [];

      for (var item in listDevice) {
        if (item.customerId == currentUser.customerId) {
          item.customerName = currentUser.customerName;
          item.isOwner = true;
        }

        item.type = item.customerId == currentUser.customerId
            ? 'chủ sở hữu'
            : 'chia sẻ';
      }

      return listDevice;
    } catch (_) {}

    return [];
  }

  Future<List<Device>> getDeviceByIdDir(int? idDir) async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

      final response = await _dio.get(
        '${Api.hostApi}${Api.getDeviceByIdDir}/$idDir',
      );
      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Device_list'];
      List<Device> listAllDevice =
          list.isNotEmpty ? list.map((e) => Device.fromJson(e)).toList() : [];

      for (var item in listAllDevice) {
        if (item.customerId == currentUser.customerId) {
          item.customerName = currentUser.customerName;
          item.isOwner = item.customerId == currentUser.customerId;
        }

        item.type = item.customerId == currentUser.customerId
            ? 'chủ sở hữu'
            : 'chia sẻ';
      }
      return listAllDevice;
    } catch (_) {}

    return [];
  }

  Future<List<Device>> getDeviceCustomerSharedById() async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

      final response = await _dio.get(
        '${Api.hostApi}${Api.getDeviceCustomerSharedById}/${currentUser.customerId}',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Device_list'];
      List<Device> listAllDevice =
          list.isNotEmpty ? list.map((e) => Device.fromJson(e)).toList() : [];

      for (var i = 0; i < listAllDevice.length; i++) {
        var item = listAllDevice[i];
        if (item.customerId == currentUser.customerId) {
          item.customerName = currentUser.customerName;
          item.isOwner = true;
        }
        item.isShareOwner = list[i]['is_owner'] == '1';
        item.type = item.customerId == currentUser.customerId
            ? 'chủ sở hữu'
            : 'chia sẻ';
      }

      return listAllDevice;
    } catch (_) {}

    return [];
  }

  Future<List<Device>> getExternalDeviceByCustomerId() async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

      final response = await _dio.get(
        '${Api.hostApi}${Api.getExternalDevices}/${currentUser.customerId}',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Device_list'];
      List<Device> listDevice = list.map((e) => Device.fromJson(e)).toList();

      for (Device device in listDevice) {
        device.isOwner = true;
        device.isOwner = device.customerId == currentUser.customerId;
      }

      return listDevice;
    } catch (_) {}

    return [];
  }

  Future<Device?> getSingleDeviceByComputerId(String? computerId) async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

      final response = await _dio.get(
        '${Api.hostApi}${Api.getDeviceByComputerId}/$computerId',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Device_list'];

      if (list.isNotEmpty) {
        Device device = Device.fromJson(list.first);
        device.isOwner = device.customerId == currentUser.customerId;
        if (device.customerId != currentUser.customerId) {
          device.type = 'chia sẻ';
        }

        return device;
      }
    } catch (_) {}

    return null;
  }

  Future<List<DeviceSharedModel>> getDeviceSharedFromCustomerId() async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

      final response = await _dio.get(
        '${Api.hostApi}${Api.getDeviceSharedFromCustomerId}/${currentUser.customerId}',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Device_list'];
      List<DeviceSharedModel> listDevice =
          list.map((e) => DeviceSharedModel.fromJson(e)).toList();

      return listDevice;
    } catch (_) {}

    return [];
  }

  Future<bool> updateDevice(Device device) async {
    final formData = FormData.fromMap({
      'computer_name': device.computerName,
      'seri_computer': device.serialComputer,
      'status': device.status,
      'provinces': device.provinces,
      'district': device.district,
      'wards': device.wards,
      'center_id': device.centerId,
      'location': device.location,
      'customer_id': device.customerId,
      'type': device.type,
      'id_dir': device.idDir,
      'time_end': device.timeEnd,
    });
    try {
      final response = await _dio.post(
        AppUtils.createUrl('${Api.updateDevice}/${device.computerId}'),
        data: formData,
      );

      final responseData = jsonDecode(response.data);

      return responseData['status'] == 1;
    } catch (_) {}

    return false;
  }

  Future<bool> deleteDevice(Device device) async {
    try {
      final response = await _dio
          .get(AppUtils.createUrl("${Api.deleteDevice}/${device.computerId}"));

      final responseData = jsonDecode(response.data);

      return responseData['status'] == 1;
    } catch (_) {}

    return false;
  }

  Future<bool> deleteDeviceShared(String? computerId, String customerId) async {
    try {
      final response = await _dio.get(AppUtils.createUrl(
          '${Api.deleteDeviceShared}/$computerId/$customerId'));

      final responseData = jsonDecode(response.data);

      return responseData['status'] == 1;
    } catch (_) {}

    return false;
  }

  Future<String?> shareDevice(String? computerId, String idDir,
      String customerIDFrom, String customerIDTo, bool checkOwner) async {
    FormData formData = FormData.fromMap({
      'computer_id': computerId,
      'customer_idfrom': customerIDFrom,
      'customer_idto': customerIDTo,
      'checkOwner': checkOwner ? '1' : '0',
    });
    try {
      final response = await _dio.post(
        '${Api.hostApi}${Api.shareDevice}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);

      return responseData['status'] == 1 ? null : responseData.toString();
    } catch (e) {
      return 'Có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  Future<List<User>> getShareCustomerList(String? computerId) async {
    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.getSharedCustomerListByComputerId}/$computerId',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['userList'];
      List<User> listUser = [];

      List<User> tempUser =
          list.isNotEmpty ? list.map((e) => User.fromJson(e)).toList() : [];
      Set<String?> setId = {};

      for (User user in tempUser) {
        if (!setId.contains(user.customerId)) {
          listUser.add(user);
          setId.add(user.customerId);
        }
      }

      return listUser;
    } catch (_) {}

    return [];
  }
}
