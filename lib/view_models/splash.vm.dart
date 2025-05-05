import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:velocity_x/velocity_x.dart';

import '../app/app.locator.dart';
import '../app/app.router.dart';
import '../app/app_sp.dart';
import '../app/app_sp_key.dart';
import '../constants/app_api.dart';
import '../models/config/config_model.dart';
import '../models/user/authentication/request/login_request_model.dart';
import '../models/user/user.dart';
import '../requests/authentication/authentication.request.dart';
import '../requests/config/config.request.dart';
import '../service/google_sign_in_api.service.dart';

class SplashViewModel extends BaseViewModel {
  late BuildContext _context;

  final ConfigRequest _configRequest = ConfigRequest();
  final AuthenticationRequest _authenticationRequest = AuthenticationRequest();

  final _navigationService = appLocator<NavigationService>();

  bool _checkLogin = false;

  Future<void> initialise() async {
    ConfigModel? config = await _configRequest.getConfig();
    if (config != null) {
      AppSP.set(AppSPKey.config, jsonEncode(config));
      Api.hostApi = config.apiServer ?? Api.hostApi;
      AppSP.set(AppSPKey.statementDate, config.statementDate);
      await _handleCheckLoginUser();
    }
    if (_context.mounted) {
      if (_checkLogin == true) {
        _navigationService.clearStackAndShow(Routes.homePage);
      } else if (_checkLogin == false) {
        _navigationService.replaceWithStartPage(
          animated: true,
          transition: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      }
    }
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> _handleCheckLoginUser() async {
    String? cookieKey = AppSP.get(AppSPKey.token) ?? '';
    String? userJson = AppSP.get(AppSPKey.userInfo) ?? '';
    String? loginWith = AppSP.get(AppSPKey.loginWith) ?? '';
    if ((cookieKey.isNotBlank && userJson.isNotBlank) ||
        loginWith == 'google') {
      User user = User.fromJson(jsonDecode(userJson));
      print(userJson);
      if (loginWith == 'google') {
        if (await GoogleSignInService.signInSilently() != null) {
          final userRequest =
              LoginRequestModel(email: user.email!, password: user.password!);
          final error = await _authenticationRequest.login(userRequest);
          _checkLogin = error == null;
        }
      } else {
        if (user.email != null && user.password != null) {
          final userRequest =
              LoginRequestModel(email: user.email!, password: user.password!);
          final error = await _authenticationRequest.login(userRequest);
          _checkLogin = error == null;
        }
      }
    }
  }
}
