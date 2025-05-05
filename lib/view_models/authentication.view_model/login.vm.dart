import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.locator.dart';
import '../../app/app.router.dart';
import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../app/utils.dart';
import '../../models/user/authentication/request/login_request_model.dart';
import '../../requests/authentication/authentication.request.dart';
import '../../view/authentication/login_page.form.dart';

class LoginViewModel extends FormViewModel {
  late BuildContext _context;

  final AuthenticationRequest _authenticationRequest = AuthenticationRequest();
  final _navigationService = appLocator<NavigationService>();

  final formKey = GlobalKey<FormState>();

  String? errorMessage;

  void setContext(BuildContext context) {
    _context = context;
  }

  void onLoginTaped() {
    if (formKey.currentState!.validate()) {
      _handleLogin();
    }
  }

  void onForgotPasswordTaped() {
    _navigationService.navigateToForgotPasswordPage();
  }

  Future<void> _handleLogin() async {
    final firebaseMessaging = FirebaseMessaging.instance;
    String? token;

    token = await firebaseMessaging.getToken();
    print('token: $token');
    AppSP.set(AppSPKey.fcm_token, token);
    final password = convertToMD5(passwordValue!);

    final user = LoginRequestModel(
        email: emailValue!,
        password: password,
        fcm_token: AppSP.get(AppSPKey.fcm_token));
    final error = await _authenticationRequest.login(user);

    if (error != null) {
      errorMessage = error;
    } else if (_context.mounted) {
      await AppSP.set(AppSPKey.loginWith, 'email');
      _navigationService.clearStackAndShow(Routes.homePage);
    }
    notifyListeners();
  }
}
