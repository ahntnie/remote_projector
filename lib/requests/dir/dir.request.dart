import 'dart:convert';

import 'package:dio/dio.dart';

import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../app/app_utils.dart';
import '../../constants/app_api.dart';
import '../../models/dir/dir_model.dart';
import '../../models/dir/dir_shared_model.dart';
import '../../models/user/user.dart';

class DirRequest {
  final Dio _dio = Dio();

  Future<List<Dir>> getMyDir() async {
    String userInfo = AppSP.get(AppSPKey.userInfo);
    final userJson = jsonDecode(userInfo);
    User currentUser = User.fromJson(userJson);

    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.getCustomerDir}/${currentUser.customerId}',
      );
      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Dir_list'];

      List<Dir> listDir = [];
      if (list.isNotEmpty) {
        listDir = list.map((e) => Dir.fromJson(e)).toList();
      }

      return listDir;
    } catch (_) {}

    return [];
  }

  Future<List<Dir>> getShareDir() async {
    String userInfo = AppSP.get(AppSPKey.userInfo);
    final userJson = jsonDecode(userInfo);
    User currentUser = User.fromJson(userJson);

    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.getShareDir}/${currentUser.customerId}',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> dirList = responseData['Dir_list'];
      List<Dir> lstDir = dirList.map((e) => Dir.fromJson(e)).toList();
      for (int i = 0; i < lstDir.length; i++) {
        if (dirList[i]['is_owner'] == '1') {
          lstDir[i].isShareOwner = true;
        } else {
          lstDir[i].isShareOwner = false;
        }
      }
      return lstDir;
    } catch (_) {}

    return [];
  }

  Future<String?> createDir(String? dirName, String? dirType) async {
    String userInfo = AppSP.get(AppSPKey.userInfo);
    final userJson = jsonDecode(userInfo);
    User currentUser = User.fromJson(userJson);

    final formData = FormData.fromMap({
      'name_dir': dirName,
      'customer_id': currentUser.customerId,
      'type_dir': dirType,
    });
    try {
      final response = await _dio.post(
        '${Api.hostApi}${Api.createDir}',
        data: formData,
        options: AppUtils.createOptionsNoCookie(),
      );
      final responseData = jsonDecode(response.data);

      if (responseData['status'] == 1) {
        return responseData['msg'];
      }
    } catch (_) {}

    return null;
  }

  Future<bool> updateDir(Dir dir) async {
    String userInfo = AppSP.get(AppSPKey.userInfo);
    final userJson = jsonDecode(userInfo);
    User currentUser = User.fromJson(userJson);

    final formData = FormData.fromMap({
      'name_dir': dir.dirName,
      'customer_id': currentUser.customerId,
      'type_dir': dir.dirType,
    });

    try {
      final response = await _dio.post(
        '${Api.hostApi}${Api.updateDir}/${dir.dirId}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);

      return responseData['status'] == 1;
    } catch (_) {}

    return false;
  }

  Future<bool> updateOnOffDeviceByIdDir(int? dirId,
      {String? turnOnTime, String? turnOffTime}) async {
    String userInfo = AppSP.get(AppSPKey.userInfo);
    final userJson = jsonDecode(userInfo);
    User currentUser = User.fromJson(userJson);

    final formData = FormData.fromMap({
      'turnon_time': turnOnTime,
      'turnoff_time': turnOffTime,
      'customer_id': currentUser.customerId,
    });

    try {
      final response = await _dio.post(
        '${Api.hostApi}${Api.upDateOnOffDeviceDirById}/$dirId',
        data: formData,
      );

      final responseData = jsonDecode(response.data);
      return responseData['status'] == 1;
    } catch (_) {}

    return false;
  }

  Future<bool> deleteDir(String dirID) async {
    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.deleteDir}/$dirID',
      );

      final responseData = jsonDecode(response.data);

      return responseData['status'] == 1;
    } catch (_) {}

    return false;
  }

  Future<String?> shareDir(String idDir, String customerIDFrom,
      String customerIDTo, bool checkOwner) async {
    FormData formData = FormData.fromMap({
      'id_dir': idDir,
      'customer_idfrom': customerIDFrom,
      'customer_idto': customerIDTo,
      'checkOwner': checkOwner ? '1' : '0',
    });

    try {
      final response = await _dio.post(
        '${Api.hostApi}${Api.shareDir}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);

      return responseData['status'] == 1 ? null : responseData.toString();
    } catch (_) {
      return 'Có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  Future<bool> deleteDirShared(int? idDir, String customerId) async {
    try {
      final response = await _dio.get(AppUtils.createUrl(
          '${Api.deleteDirectoryShared}/$idDir/$customerId'));

      print(response);

      final responseData = jsonDecode(response.data);

      return responseData['status'] == 1;
    } catch (_) {}

    return false;
  }

  Future<List<User>> getShareCustomerList(String idDir) async {
    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.getSharedCustomerListByDirId}/$idDir',
      );

      final responseData = jsonDecode(response.data);

      List<User> listUser = [];
      if (responseData['status'] == 1) {
        List<User> list = List<User>.from(
            responseData['userList'].map((e) => User.fromJson(e)));
        Set<String?> setId = {};

        for (User user in list) {
          if (!setId.contains(user.customerId)) {
            listUser.add(user);
            setId.add(user.customerId);
          }
        }
      }

      return listUser;
    } catch (_) {}

    return [];
  }

  Future<List<DirSharedModel>> getDirectoriesSharedFromCustomerId() async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

      final response = await _dio.get(
        '${Api.hostApi}${Api.getDirectoriesSharedFromCustomerId}/${currentUser.customerId}',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Dir_list'];
      List<DirSharedModel> listDir =
          list.map((e) => DirSharedModel.fromJson(e)).toList();

      return listDir;
    } catch (_) {}

    return [];
  }
}
