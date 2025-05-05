import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.locator.dart';
import '../../app/app.router.dart';
import '../../app/utils.dart';
import '../../requests/authentication/authentication.request.dart';
import '../../widget/pop_up.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  late BuildContext _context;

  final AuthenticationRequest _authenticationRequest = AuthenticationRequest();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _navigationService = appLocator<NavigationService>();

  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> sendRequest(String email) async {
    setBusy(true);
    final checkSendCode = await _authenticationRequest.sendCode(email);
    errorMessage = checkSendCode ?? '';

    if (checkSendCode == null) {
      if (_context.mounted) {
        showPopupSingleButton(
          title:
              'Đã gửi code xác nhận đến email của bạn, vui lòng vào email để lấy mã!',
          context: _context,
          barrierDismissible: false,
          onButtonTap: () {
            _navigationService.navigateToCreateNewPasswordPage(
              forgotPasswordViewModel: this,
            );
          },
        );
      }
    } else if (_context.mounted) {
      showPopupSingleButton(
        title: 'Đã có lỗi xảy ra, vui lòng thử lại sau!',
        isError: true,
        context: _context,
      );
    }
    setBusy(false);
  }

  Future<void> resetPassword(BuildContext context, GlobalKey<FormState> key,
      String email, String code, String password) async {
    if (key.currentState!.validate()) {
      setBusy(true);

      final String mdPassword = convertToMD5(password);
      final checkResetPassword =
          await _authenticationRequest.resetPassword(email, code, mdPassword);

      if (checkResetPassword == null) {
        if (context.mounted) {
          showPopupSingleButton(
            title: 'Đổi mật khẩu thành công',
            context: context,
            onButtonTap: () {
              _navigationService.clearStackAndShow(Routes.startPage);
            },
          );
        }
      } else if (context.mounted) {
        showPopupSingleButton(
          title: 'Đã có lỗi xảy ra, vui lòng thử lại sau!',
          isError: true,
          context: context,
        );
      }

      setBusy(false);
    }
  }
}
