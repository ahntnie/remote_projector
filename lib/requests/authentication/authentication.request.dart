import 'dart:convert';

import 'package:dio/dio.dart';

import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../app/app_utils.dart';
import '../../constants/app_api.dart';
import '../../models/user/authentication/request/login_request_model.dart';
import '../../models/user/authentication/request/sign_up_request_model.dart';
import '../../models/user/authentication/response/login_response_model.dart';
import '../../models/user/authentication/response/signup_response_model.dart';
import '../../models/user/user.dart';
import '../account/account.request.dart';

class AuthenticationRequest {
  final Dio _dio = Dio();

  Future<String?> login(LoginRequestModel user) async {
    final formData = FormData.fromMap({
      'email': user.email.trim(),
      'password': user.password.trim(),
      'fcm_token': AppSP.get(AppSPKey.fcm_token),
    });

    try {
      final response = await _dio.post(
        AppUtils.createUrl(Api.login),
        data: formData,
        options: AppUtils.createOptionsNoCookie(),
      );
      final responseData = jsonDecode(response.data);
      final loginResponse = LoginResponseModel.fromJson(responseData);

      if (loginResponse.status == 1 && loginResponse.info.isNotEmpty) {
        await onLoginSuccess(response, loginResponse);

        return null;
      } else {
        return loginResponse.msg ?? 'Đăng nhập không thành công';
      }
    } catch (_) {
      return 'Có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  Future<String?> logout() async {
    final formData = FormData.fromMap({
      // 'email': user.email.trim(),
      // 'password': user.password.trim(),
      'fcm_token': AppSP.get(AppSPKey.fcm_token),
    });

    try {
      final response = await _dio.post(
        AppUtils.createUrl(Api.logout),
        data: formData,
        options: AppUtils.createOptionsNoCookie(),
      );
      print('responseData $response');
      final responseData = jsonDecode(response.data);
      print('responseData $responseData');
      final loginResponse = LoginResponseModel.fromJson(responseData);

      if (loginResponse.status == 1 && loginResponse.info.isNotEmpty) {
        await onLoginSuccess(response, loginResponse);

        return null;
      } else {
        return 'loginResponse.msg' ?? 'Đăng xuất không thành công';
      }
    } catch (e) {
      print(e);
      return 'Có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  Future<void> onLoginSuccess(
      Response<dynamic> response, LoginResponseModel loginResponse) async {
    if (loginResponse.info.isNotEmpty) {
      Map<String, dynamic> userJson = loginResponse.info.first.toJson();

      await AppSP.set(AppSPKey.token, userJson['password']);
      await AppSP.set(AppSPKey.userInfo, jsonEncode(userJson));
    }
  }

  Future<String?> signUp(SignUpRequestModel user) async {
    final formData = FormData.fromMap({
      'customer_name': user.name.trim(),
      'phone_number': user.phone.trim(),
      'email': user.email.trim(),
      'password': user.password.trim(),
      'fcm_token': AppSP.get(AppSPKey.fcm_token),
    });

    try {
      final response = await _dio.post(
        AppUtils.createUrl(Api.signUp),
        data: formData,
        options: AppUtils.createOptionsNoCookie(),
      );
      final responseData = jsonDecode(response.data);
      final signUpResponse = SignUpResponseModel.fromJson(responseData);

      if (signUpResponse.status == '1') {
        await onSignUpSuccess(response, signUpResponse);
        return null;
      } else {
        return signUpResponse.msg ?? 'Đăng ký không thành công';
      }
    } catch (e) {
      return 'Có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  Future<void> onSignUpSuccess(
      Response<dynamic> response, SignUpResponseModel signUpResponse) async {
    AccountRequest accountRequest = AccountRequest();
    User? user = await accountRequest.getCustomerById(signUpResponse.id!);

    if (user != null) {
      await AppSP.set(AppSPKey.token, user.password);
      await AppSP.set(AppSPKey.userInfo, jsonEncode(user.toJson()));
    }
  }

  Future<String?> sendCode(String email) async {
    final formData = FormData.fromMap({
      'email': email,
    });

    try {
      final response = await _dio.post(
        AppUtils.createUrl(Api.sendCode),
        data: formData,
        options: AppUtils.createOptionsNoCookie(),
      );

      final responseData = jsonDecode(response.data);

      return responseData['status'] != -1 ? null : responseData['msg'];
    } catch (e) {
      return 'Có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  Future<String?> resetPassword(
      String email, String code, String password) async {
    final formData = FormData.fromMap({
      'email': email,
      'code_authen': code,
      'password': password,
    });

    try {
      final response = await _dio.post(
        AppUtils.createUrl(Api.resetPassword),
        data: formData,
        options: AppUtils.createOptionsNoCookie(),
      );

      final responseData = jsonDecode(response.data);

      return responseData['status'] == 1 ? null : responseData['msg'];
    } catch (e) {
      return 'Có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  Future<bool> deleteAccount(String email, String code, String password) async {
    final formData = FormData.fromMap({
      'email': email,
      'code_authen': code,
      'password': password,
    });

    try {
      final response = await _dio.post(
        AppUtils.createUrl(Api.deleteAccount),
        data: formData,
        options: AppUtils.createOptionsNoCookie(),
      );

      print(response);
      final responseData = jsonDecode(response.data);

      return responseData['status'] == 1;
    } catch (e) {
      return false;
    }
  }
}
