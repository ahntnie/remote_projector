import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../view_models/authentication.view_model/forgot_password.vm.dart';
import '../../widget/base_page.dart';
import '../../widget/button_custom.dart';
import '../../widget/my_text_field.dart';

class CreateNewPasswordPage extends StatefulWidget {
  final ForgotPasswordViewModel forgotPasswordViewModel;

  const CreateNewPasswordPage({
    super.key,
    required this.forgotPasswordViewModel,
  });

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? errorMessage;

  @override
  void initState() {
    emailController.text = widget.forgotPasswordViewModel.emailController.text;

    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  void sendRequest() {
    if (!formKey.currentState!.validate()) {
      return;
    }
  }

  void setErrorMessage(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ForgotPasswordViewModel>.reactive(
      disposeViewModel: false,
      viewModelBuilder: () => widget.forgotPasswordViewModel,
      builder: (context, viewModel, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          isBusy: viewModel.isBusy,
          body: Container(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffE5E5E5),
                        borderRadius: BorderRadius.circular(50.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 68, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xffEB6E2C),
                          borderRadius: BorderRadius.circular(50.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          "Quên mật khẩu",
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email đã đăng ký',
                                ),
                                readOnly: true,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Xin hãy nhập email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: codeController,
                                decoration:
                                    const InputDecoration(labelText: 'Code'),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Xin vui lòng nhập Code';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              MyTextField(
                                controller: passwordController,
                                labelText: 'Mật khẩu',
                                isPasswordFields: true,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) =>
                                    viewModel.resetPassword(
                                  context,
                                  formKey,
                                  emailController.text,
                                  codeController.text,
                                  passwordController.text,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Xin hãy nhập mật khẩu';
                                  }
                                  if (!validatePassword(value)) {
                                    return 'Mật khẩu phải từ 8 ký tự, bao gồm chữ, số và ký tự đặc biệt';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Mật khẩu từ 8 ký tự, bao gồm chữ, số và ký tự đặc biệt',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColor.unSelectedLabel2,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 32.0),
                              if (errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              const SizedBox(height: 16.0),
                              ButtonCustom(
                                onPressed: () => viewModel.resetPassword(
                                  context,
                                  formKey,
                                  emailController.text,
                                  codeController.text,
                                  passwordController.text,
                                ),
                                title: "Đặt lại mật khẩu",
                                textSize: 27,
                                margin: const EdgeInsets.only(
                                  left: 40,
                                  right: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
