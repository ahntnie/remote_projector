import 'dart:convert';

import 'package:dio/dio.dart';

import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../constants/app_api.dart';
import '../../models/response/response_result.dart';
import '../../models/user/get_user_response_model.dart';
import '../../models/user/user.dart';

class AccountRequest {
  final Dio _dio = Dio();

  Future<User?> getCustomer() async {
    try {
      var storedUserInfo = await AppSP.retrieveItem(AppSPKey.userInfo);
      if (storedUserInfo != null) {
        final User userData = User.fromJson(storedUserInfo);

        final response = await _dio.get(
          '${Api.hostApi}${Api.getCustomer}/${userData.customerId}',
        );

        final responseData = jsonDecode(response.data);
        UserResponseModel customerResponse =
            UserResponseModel.fromJson(responseData);

        if (customerResponse.userList.isNotEmpty) {
          var updatedUser = customerResponse.userList.first;
          updatedUser.customerId = userData.customerId;
          return updatedUser;
        } else {
          return userData;
        }
      }
    } catch (_) {}

    return null;
  }

  Future<User?> getCustomerById(String id) async {
    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.getCustomer}/$id',
      );

      final responseData = jsonDecode(response.data);
      UserResponseModel customerResponse =
          UserResponseModel.fromJson(responseData);

      if (customerResponse.userList.isNotEmpty) {
        User updatedUser = customerResponse.userList.first;
        updatedUser.customerId = id;
        return updatedUser;
      }
    } catch (_) {}

    return null;
  }

  Future<User?> getCustomerByEmail(String email) async {
    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.getCustomerByEmail}/$email',
      );

      final responseData = jsonDecode(response.data);
      UserResponseModel customerResponse =
          UserResponseModel.fromJson(responseData);

      if (customerResponse.userList.isNotEmpty) {
        User updatedUser = customerResponse.userList.first;
        updatedUser.email = email;
        return updatedUser;
      }
    } catch (_) {}

    return null;
  }

  Future<ResponseResult<bool>> changePassword(
      String oldPassword, String newPassword) async {
    try {
      User user = User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
      FormData formData = FormData.fromMap({
        'email': user.email,
        'password_old': oldPassword,
        'password_new': newPassword,
      });

      final response = await _dio.post(
        '${Api.hostApi}${Api.changePassword}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);
      int status = responseData['status'];

      if (status == -2) {
        return ResponseResult.error(responseData['msg']);
      } else if (status == 1) {
        user.password = newPassword;
        AppSP.set(AppSPKey.userInfo, user.toJson());
        AppSP.set(AppSPKey.token, user.password);

        return ResponseResult.success(true);
      }

      return ResponseResult.error('Đổi mật khẩu không thành công');
    } catch (e) {
      return getErrorFromException(error: e);
    }
  }

  Future<bool> updateCustomer(User user) async {
    FormData formData = FormData.fromMap({
      'email': user.email,
      'customer_name': user.customerName,
      'date_of_birth': user.dateOfBirth,
      'address': user.address,
      'phone_number': user.phoneNumber,
      'sex': user.sex,
    });
    try {
      final response = await _dio.post(
        '${Api.hostApi}${Api.updateCustomer}/${user.customerId}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);

      return responseData['status'] == 1;
    } catch (e) {
      return false;
    }
  }
}
