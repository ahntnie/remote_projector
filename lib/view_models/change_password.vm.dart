import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../app/utils.dart';
import '../models/response/response_result.dart';
import '../requests/account/account.request.dart';
import '../view/account/change_password_page.form.dart';
import '../widget/pop_up.dart';

class ChangePasswordViewModel extends FormViewModel {
  ChangePasswordViewModel({required this.context});

  final BuildContext context;

  final formKey = GlobalKey<FormState>();

  final AccountRequest _accountRequest = AccountRequest();
  final _navigationService = appLocator<NavigationService>();

  void onChangePasswordTaped() {
    if (formKey.currentState!.validate()) {
      _handleChangePassword();
    }
  }

  Future<void> _handleChangePassword() async {
    setBusy(true);
    String oldPassword = convertToMD5(oldPasswordValue!);
    String newPassword = convertToMD5(newPasswordValue!);

    switch (await _accountRequest.changePassword(oldPassword, newPassword)) {
      case ResultSuccess success:
        _onChangePasswordSuccess(success);
        break;
      case ResultError error:
        showResultError(context: context, error: error);
        break;
    }

    setBusy(false);
  }

  void _onChangePasswordSuccess(ResultSuccess success) {
    showPopupSingleButton(
      title: 'Đổi mật khẩu thành công',
      context: context,
      barrierDismissible: false,
      onButtonTap: _navigationService.back,
    );
  }
}
