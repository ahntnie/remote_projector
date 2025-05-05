import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../view_models/change_password.vm.dart';
import '../../widget/base_page.dart';
import '../../widget/button_custom.dart';
import '../../widget/my_text_field.dart';
import 'change_password_page.form.dart';

@FormView(fields: [
  FormTextField(name: 'oldPassword'),
  FormTextField(name: 'newPassword'),
  FormTextField(name: 'confirmNewPassword'),
])
class ChangePasswordPage extends StackedView<ChangePasswordViewModel>
    with $ChangePasswordPage {
  const ChangePasswordPage({super.key});

  @override
  Widget builder(context, viewModel, child) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      isBusy: viewModel.isBusy,
      body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(5),
                  width: double.infinity,
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
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
                      "Đổi mật khẩu",
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 40,
                      ),
                      child: Form(
                        key: viewModel.formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyTextField(
                              isPasswordFields: true,
                              controller: oldPasswordController,
                              focusNode: oldPasswordFocusNode,
                              onFieldSubmitted: (_) =>
                                  newPasswordFocusNode.requestFocus(),
                              labelText: 'Mật khẩu cũ',
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Xin hãy nhập mật khẩu cũ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            MyTextField(
                              isPasswordFields: true,
                              controller: newPasswordController,
                              focusNode: newPasswordFocusNode,
                              labelText: 'Mật khẩu mới',
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  confirmNewPasswordFocusNode.requestFocus(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Xin vui lòng nhập mật khẩu mới';
                                }
                                if (!validatePassword(value)) {
                                  return 'Mật khẩu phải từ 8 ký tự, bao gồm chữ, số và ký tự đặc biệt';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            MyTextField(
                              controller: confirmNewPasswordController,
                              focusNode: confirmNewPasswordFocusNode,
                              labelText: 'Nhập lại mật khẩu',
                              isPasswordFields: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  viewModel.onChangePasswordTaped(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Xin hãy nhập lại mật khẩu';
                                }
                                if (value != newPasswordController.text) {
                                  return 'Mật khẩu chưa giống nhau';
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
                            ButtonCustom(
                              onPressed: viewModel.onChangePasswordTaped,
                              title: "XÁC NHẬN",
                              textSize: 27,
                              margin: const EdgeInsets.only(
                                top: 32,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  ChangePasswordViewModel viewModelBuilder(BuildContext context) {
    ChangePasswordViewModel viewModel =
        ChangePasswordViewModel(context: context);
    return viewModel;
  }

  @override
  void onViewModelReady(ChangePasswordViewModel viewModel) {
    syncFormWithViewModel(viewModel);
  }

  @override
  void onDispose(ChangePasswordViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }
}
