import 'dart:async';
import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../app/app.locator.dart';
import '../app/app.router.dart';
import '../app/app_sp.dart';
import '../app/app_sp_key.dart';
import '../app/utils.dart';
import '../models/user/authentication/request/login_request_model.dart';
import '../models/user/user.dart';
import '../requests/authentication/authentication.request.dart';
import '../service/google_sign_in_api.service.dart';
import '../view/remove_account/remove_account_page.form.dart';
import '../widget/pop_up.dart';

class RemoveAccountViewModel extends FormViewModel {
  RemoveAccountViewModel({required this.context});

  final BuildContext context;

  final AuthenticationRequest _authenticationRequest = AuthenticationRequest();
  final _navigationService = appLocator<NavigationService>();

  final formKeyAccount = GlobalKey<FormState>();
  final formKeyPassword = GlobalKey<FormState>();
  final formKeyCode = GlobalKey<FormState>();

  final ExpandableController enterPasswordController = ExpandableController();
  final ExpandableController enterCodeController = ExpandableController();

  final User _currentUser =
      User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
  User get currentUser => _currentUser;

  bool _isAccountChecked = false;
  bool get isAccountChecked => _isAccountChecked;

  bool _isPasswordChecked = false;
  bool get isPasswordChecked => _isPasswordChecked;

  bool _isActiveResendCode = true;
  bool get isActiveResendCode => _isActiveResendCode;

  int _countdown = 60;
  int get countdown => _countdown;

  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();

    super.dispose();
  }

  Future<void> resendCodeTaped() async {
    setBusy(true);

    final checkSendCode =
        await _authenticationRequest.sendCode(currentUser.email ?? emailValue!);

    if (checkSendCode != null) {
      _isPasswordChecked = false;
      if (enterCodeController.expanded) {
        enterCodeController.toggle();
      }

      if (context.mounted) {
        showPopupSingleButton(
          title: 'Mã xác thực chưa được gửi, vui lòng thử lại sau',
          context: context,
          isError: true,
          onButtonTap: () {},
        );
      }
    } else {
      _isActiveResendCode = false;
      _countdown = 60;
      _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _isActiveResendCode = true;
          timer.cancel();
        }
        notifyListeners();
      });
    }

    setBusy(false);
  }

  Future<void> continueTaped() async {
    setBusy(true);

    if (_isAccountChecked) {
      if (_isPasswordChecked) {
        if (formKeyCode.currentState?.validate() == true) {
          showPopupTwoButton(
            title: 'Bạn có chắc chắn xóa tài khoản $emailValue không?',
            isError: true,
            context: context,
            onLeftTap: _handleRemoveAccount,
          );
        }
      } else {
        if (formKeyPassword.currentState?.validate() == true) {
          final password = convertToMD5(passwordValue!);
          final user = LoginRequestModel(
            email: emailValue!,
            password: password,
            fcm_token: AppSP.get(AppSPKey.fcm_token),
          );
          final error = await _authenticationRequest.login(user);
          String? checkSendCode;

          if (error == null) {
            checkSendCode = await _authenticationRequest
                .sendCode(currentUser.email ?? emailValue!);
          }

          if (error != null || checkSendCode != null) {
            if (context.mounted) {
              showPopupSingleButton(
                title: error != null
                    ? 'Mật khẩu không khớp, vui lòng nhập lại mật khẩu'
                    : 'Mã xác thực chưa được gửi, vui lòng thử lại sau',
                context: context,
                isError: true,
                onButtonTap: () {
                  if (error != null) {
                    passwordValue = null;
                  }
                },
              );
            }
          } else if (context.mounted) {
            _isPasswordChecked = true;
            if (!enterCodeController.expanded) {
              enterCodeController.toggle();
            }

            _isActiveResendCode = false;
            _countdown = 60;
            _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (_countdown > 0) {
                _countdown--;
              } else {
                _isActiveResendCode = true;
                timer.cancel();
              }
              notifyListeners();
            });
          }
        }
      }
    } else {
      if (formKeyAccount.currentState?.validate() == true) {
        _isAccountChecked = true;
        if (!enterPasswordController.expanded) {
          enterPasswordController.toggle();
        }
      }
    }

    setBusy(false);
  }

  Future<void> _handleRemoveAccount() async {
    setBusy(true);

    bool removed = await _authenticationRequest.deleteAccount(
      currentUser.email ?? emailValue!,
      codeValue!,
      passwordValue!,
    );

    if (removed) {
      if (context.mounted) {
        await showPopupSingleButton(
          title: 'Tài khoản đã được xóa thành công',
          context: context,
        );
      }

      if (AppSP.get(AppSPKey.loginWith) == 'google') {
        await GoogleSignInService.logout();
      }
      await AppSP.set(AppSPKey.token, '');
      await AppSP.set(AppSPKey.userInfo, '');
      await AppSP.set(AppSPKey.loginWith, '');
      await AppSP.set(AppSPKey.fcm_token, '');

      if (context.mounted) {
        _navigationService.clearStackAndShow(Routes.startPage);
      }
    } else if (context.mounted) {
      showPopupTwoButton(
        title: 'Đã có lỗi xảy ra, vui lòng thử lại sau',
        context: context,
      );
    }

    setBusy(false);
  }
}
