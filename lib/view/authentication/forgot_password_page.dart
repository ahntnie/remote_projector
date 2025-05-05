import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../view_models/authentication.view_model/forgot_password.vm.dart';
import '../../widget/base_page.dart';
import '../../widget/button_custom.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ForgotPasswordViewModel>.reactive(
      viewModelBuilder: () => ForgotPasswordViewModel(),
      onViewModelReady: (viewModel) {
        viewModel.setContext(context);
      },
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
                          horizontal: 68,
                          vertical: 16,
                        ),
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
                  const SizedBox(height: 32.0),
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: viewModel.formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: viewModel.emailController,
                              decoration: const InputDecoration(
                                  labelText: 'Email đã đăng ký'),
                              validator: (value) {
                                if (value.isEmptyOrNull) {
                                  return 'Xin hãy nhập email';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => viewModel
                                  .sendRequest(viewModel.emailController.text),
                            ),
                            ButtonCustom(
                              onPressed: () => viewModel
                                  .sendRequest(viewModel.emailController.text),
                              title: "Gửi",
                              textSize: 27,
                              margin: const EdgeInsets.only(
                                top: 32,
                                left: 64,
                                right: 64,
                              ),
                            ),
                          ],
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
