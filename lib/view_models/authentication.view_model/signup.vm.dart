import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.locator.dart';
import '../../app/app.router.dart';
import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../app/utils.dart';
import '../../models/packet/packet_model.dart';
import '../../models/user/authentication/request/sign_up_request_model.dart';
import '../../requests/authentication/authentication.request.dart';
import '../../requests/packet/packet.request.dart';
import '../../view/authentication/sign_up_page.form.dart';
import '../../widget/pop_up.dart';

class SignUpViewModel extends FormViewModel {
  late BuildContext _context;

  final AuthenticationRequest _authenticationRequest = AuthenticationRequest();
  final PacketRequest _packetRequest = PacketRequest();
  final _navigationService = appLocator<NavigationService>();

  final formKey = GlobalKey<FormState>();
  bool _isTermsAccepted = false;
  String? errorMessage;
  bool get isTermsAccepted => _isTermsAccepted;
  void setContext(BuildContext context) {
    _context = context;
  }

  void setTermsAccepted(bool value) {
    _isTermsAccepted = value;
    notifyListeners(); // Cập nhật UI khi trạng thái thay đổi
  }

  void onSignupTaped() {
    if (formKey.currentState!.validate()) {
      _handleSignup();
    }
  }

  Future<void> _handleSignup() async {
    setBusy(true);
    final firebaseMessaging = FirebaseMessaging.instance;
    String? token;

    token = await firebaseMessaging.getToken();
    print('token: $token');
    AppSP.set(AppSPKey.fcm_token, token);
    final password = convertToMD5(passwordValue!);

    final user = SignUpRequestModel(
      email: emailValue!,
      password: password,
      name: nameValue!,
      phone: phoneValue!,
      fcm_token: AppSP.get(AppSPKey.fcm_token),
    );

    final error = await _authenticationRequest.signUp(user);

    if (error != null) {
      errorMessage = error;
    } else if (_context.mounted) {
      passwordValue = '';
      emailValue = '';
      phoneValue = '';
      nameValue = '';

      List<PacketModel> packets = await _packetRequest.getAllPacket();
      PacketModel? packetTrial =
          packets.where((e) => e.isTrial == '1').firstOrNull;

      if (packetTrial != null) {
        await _packetRequest.buyPacketByCustomerId(packetTrial, null);
      }

      showPopupTwoButton(
        context: _context,
        barrierDismissible: false,
        title: 'Đăng kí tài khoản thành công, chuyển đến trang chủ?',
        onLeftTap: () {
          AppSP.set(AppSPKey.loginWith, 'email');
          _navigationService.clearStackAndShow(Routes.homePage);
        },
      );
    }

    setBusy(false);
  }
}
