import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:remote_projector_2024/requests/authentication/authentication.request.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../app/app.locator.dart';
import '../app/app.router.dart';
import '../app/app_sp.dart';
import '../app/app_sp_key.dart';
import '../models/config/config_model.dart';
import '../models/user/user.dart';
import '../requests/account/account.request.dart';
import '../requests/config/config.request.dart';
import '../service/google_sign_in_api.service.dart';
import '../widget/pop_up.dart';

class AccountViewModel extends BaseViewModel {
  AccountViewModel({required this.context});

  final BuildContext context;

  final ConfigRequest _configRequest = ConfigRequest();
  final AccountRequest _accountRequest = AccountRequest();

  final _navigationService = appLocator<NavigationService>();

  User? _currentUser;
  User? get currentUser => _currentUser;

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  Future<void> initialise() async {
    setBusy(true);

    await handleGetConfig();
    await handleGetCustomer();

    setBusy(false);
  }

  Future<void> handleGetConfig() async {
    String? configString = AppSP.get(AppSPKey.config);
    ConfigModel? config;
    if (configString != null) {
      config = ConfigModel.fromJson(jsonDecode(configString));
    } else {
      config = await _configRequest.getConfig();

      if (config == null) {
        toSplashPage();
      }
    }
    _configModel = config;
    notifyListeners();
  }

  Future<void> handleGetCustomer() async {
    _currentUser = await _accountRequest.getCustomer();
  }

  Future<void> signOut() async {
    if (AppSP.get(AppSPKey.loginWith) == 'google') {
      await GoogleSignInService.logout();
    }
    print('Logout nè');
    await AuthenticationRequest().logout();
    await AppSP.set(AppSPKey.token, '');
    await AppSP.set(AppSPKey.userInfo, '');
    await AppSP.set(AppSPKey.loginWith, '');
    await AppSP.set(AppSPKey.fcm_token, '');

    if (context.mounted) {
      _navigationService.clearStackAndShow(Routes.startPage);
    }
  }

  void changeGender(String? gender) {
    currentUser?.sex = gender;
    notifyListeners();
  }

  Future<void> handleUpdateCustomer() async {
    if (currentUser == null) return;
    setBusy(true);
    bool checkUpdated = await _accountRequest.updateCustomer(currentUser!);
    if (context.mounted) {
      showPopupSingleButton(
        context: context,
        title: checkUpdated
            ? 'Đã lưu thông tin thành công'
            : 'Đã có lỗi xảy ra, vui lòng thử lại sau',
        isError: !checkUpdated,
      );
    }
    setBusy(false);
  }

  void toWebViewPage() {
    String? url = configModel?.guideLink;
    if (url != null) {
      _navigationService.navigateToMyWebViewPage(
        url: 'https://docs.google.com/gview?embedded=true&url=$url',
      );
    }
  }

  void toSplashPage() {
    _navigationService.clearStackAndShow(Routes.splashPage);
  }

  void toChangePasswordPage() {
    _navigationService.navigateTo(Routes.changePasswordPage);
  }

  void toRemoveAccountPage() {
    _navigationService.navigateToAlertRemoveAccountPage();
  }

  void toIntroducePage() {
    _navigationService.navigateToIntroducePage(configModel: _configModel!);
  }

  void toResourceManagerPage() {
    _navigationService.navigateToResourceManagerPage();
  }

  void toLuckyWheelPage() {
    _navigationService.navigateToLuckyWheelPage();
  }
}
