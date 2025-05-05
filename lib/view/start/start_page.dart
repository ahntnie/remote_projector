import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.locator.dart';
import '../../app/app.router.dart';
import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../constants/app_color.dart';
import '../../models/config/config_model.dart';
import '../../models/user/authentication/request/login_request_model.dart';
import '../../models/user/authentication/request/sign_up_request_model.dart';
import '../../models/user/user.dart';
import '../../requests/account/account.request.dart';
import '../../requests/authentication/authentication.request.dart';
import '../../service/google_sign_in_api.service.dart';
import '../../widget/button_custom.dart';
import '../../widget/logo.dart';

class StartPage extends StatefulWidget {
  final bool animated;

  const StartPage({super.key, this.animated = false});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  final _navigationService = appLocator<NavigationService>();
  final AuthenticationRequest _authenticationRequest = AuthenticationRequest();
  String? errorMessage;

  @override
  void initState() {
    if (widget.animated) {
      _controller = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );

      _animation = CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      );

      _controller!.forward();
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.appBarEnd, AppColor.appBarStart],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'TS Screen',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Hero(tag: 'logo', child: LogoWidget(size: 150)),
              Column(
                children: [
                  ButtonCustom(
                    textSize: 27,
                    onPressed: () => navigateLoginScreen(0),
                    title: "ĐĂNG NHẬP",
                    isSplashScreen: true,
                  ),
                  ButtonCustom(
                    isSplashScreen: true,
                    onPressed: signIn,
                    customTitle: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Image(
                            image: AssetImage('assets/images/ic_google.png'),
                            width: 20,
                            height: 20,
                          ),
                        ),
                        Text(
                          "Đăng nhập với Google",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(top: 20),
                    textSize: 27,
                  ),
                ],
              ),
              SizedBox(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bạn chưa có tài khoản?',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => navigateLoginScreen(1),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Text(
                            'ĐĂNG KÍ TẠI ĐÂY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 110),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                        child:
                            const SizedBox(height: 5, width: double.infinity),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateLoginScreen(int page) {
    if (!widget.animated || _animation!.isCompleted) {
      _navigationService.navigateToAuthenticationPage(index: page);
    }
  }

  Future signIn() async {
    final user = await GoogleSignInService.login();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập google thất bại')));
    } else {
      AccountRequest accountRequest = AccountRequest();
      User? userModel = await accountRequest.getCustomerByEmail(user.email);
      if (userModel != null) {
        final userLogin = LoginRequestModel(
          email: user.email,
          password: '',
          fcm_token: AppSP.get(AppSPKey.fcm_token),
        );
        final error = await _authenticationRequest.login(userLogin);
        if (error != null) {
          errorMessage = error;
          await GoogleSignInService.logout();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Tài khoản của bạn đã được đăng ký trước đó bằng phương thức thông thường. Vui lòng đăng nhập bằng email và mật khẩu của bạn.')));
        } else if (context.mounted) {
          await AppSP.set(AppSPKey.loginWith, 'google');
          _navigationService.clearStackAndShow(Routes.homePage);
        }
      } else {
        final userSignUp = SignUpRequestModel(
          email: user.email,
          password: '',
          name: user.displayName!,
          phone: '',
          fcm_token: AppSP.get(AppSPKey.fcm_token),
        );
        final error = await _authenticationRequest.signUp(userSignUp);
        if (error != null) {
          ConfigModel configModel =
              ConfigModel.fromJson(jsonDecode(AppSP.get(AppSPKey.config)));
          errorMessage = error;
          await GoogleSignInService.logout();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Tài khoản đã bị xóa trước đó. Hãy liên hệ ${configModel.hotline} để được hỗ trợ')));
        } else if (context.mounted) {
          await AppSP.set(AppSPKey.loginWith, 'google');
          _navigationService.clearStackAndShow(Routes.homePage);
        }
      }
    }
  }
}
