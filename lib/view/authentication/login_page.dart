import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import '../../view_models/authentication.view_model/login.vm.dart';
import '../../widget/button_custom.dart';
import '../../widget/my_text_field.dart';
import 'login_page.form.dart';

@FormView(fields: [
  FormTextField(name: 'email'),
  FormTextField(name: 'password'),
])
class LoginPage extends StackedView<LoginViewModel> with $LoginPage {
  const LoginPage({super.key});

  @override
  Widget builder(
      BuildContext context, LoginViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        labelText: 'Email / Số điện thoại'),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Xin hãy nhập email / số điện thoại';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  MyTextField(
                    controller: passwordController,
                    labelText: 'Mật khẩu',
                    isPasswordFields: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => viewModel.onLoginTaped(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Xin hãy nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  viewModel.errorMessage != null
                      ? const SizedBox(height: 16)
                      : const SizedBox(height: 16),
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: viewModel.onForgotPasswordTaped,
                      child: const Text(
                        'Quên mật khẩu',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  ButtonCustom(
                    onPressed: viewModel.onLoginTaped,
                    title: "ĐĂNG NHẬP",
                    textSize: 27,
                    margin: const EdgeInsets.only(top: 16, left: 40, right: 40),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) {
    LoginViewModel viewModel = LoginViewModel();
    viewModel.setContext(context);
    return viewModel;
  }

  @override
  void onViewModelReady(LoginViewModel viewModel) {
    syncFormWithViewModel(viewModel);
  }

  @override
  void onDispose(LoginViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }
}
