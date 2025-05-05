import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../view_models/remove_account.vm.dart';
import '../../widget/base_page.dart';
import '../../widget/button_custom.dart';
import '../../widget/my_text_field.dart';
import 'remove_account_page.form.dart';

@FormView(fields: [
  FormTextField(name: 'email'),
  FormTextField(name: 'password'),
  FormTextField(name: 'code'),
])
class RemoveAccountPage extends StackedView<RemoveAccountViewModel>
    with $RemoveAccountPage {
  const RemoveAccountPage({super.key});

  @override
  Widget builder(
      BuildContext context, RemoveAccountViewModel viewModel, Widget? child) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Xóa tài khoản',
      isBusy: viewModel.isBusy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: AppColor.bgDir,
            child: const Text(
              'Bạn không thể khôi phục dữ liệu của tài khoản cũ khi đăng ký tài khoản mới bằng email / số điện thoại này',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColor.black),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(maxWidth: 550),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpandablePanel(
                    controller: viewModel.enterPasswordController,
                    collapsed: const Text(
                      'Để xóa tài khoản này, hãy nhập email / số điện thoại:',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.unSelectedLabel,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    expanded: const SizedBox.shrink(),
                  ),
                  Form(
                    key: viewModel.formKeyAccount,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextField(
                          controller: emailController,
                          focusNode: emailFocusNode,
                          readOnly: viewModel.isAccountChecked,
                          labelText: 'Email/SĐT',
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: viewModel.isAccountChecked
                              ? null
                              : (_) async {
                                  await viewModel.continueTaped();
                                  print(viewModel.isAccountChecked);
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    if (viewModel.isAccountChecked) {
                                      passwordFocusNode.requestFocus();
                                    } else {
                                      emailFocusNode.requestFocus();
                                    }
                                  });
                                },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Xin hãy nhập email / số điện thoại';
                            }

                            if (isAllDigits(value)) {
                              if (value != viewModel.currentUser.phoneNumber) {
                                return 'Số điện thoại không hợp lệ, vui lòng kiểm tra và thử lại';
                              }
                            } else if (value != viewModel.currentUser.email) {
                              return 'Email không hợp lệ, vui lòng kiểm tra và thử lại';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  ExpandablePanel(
                    controller: viewModel.enterPasswordController,
                    collapsed: const SizedBox(),
                    expanded: Form(
                      key: viewModel.formKeyPassword,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          ExpandablePanel(
                            controller: viewModel.enterCodeController,
                            collapsed: Text(
                              'Để tiếp tục xóa tài khoản với ${isAllDigits(emailController.text) ? 'số điện thoại' : 'email'} ${emailController.text}, hãy nhập mật khẩu:',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColor.unSelectedLabel,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            expanded: const SizedBox.shrink(),
                          ),
                          MyTextField(
                            controller: passwordController,
                            focusNode: passwordFocusNode,
                            isPasswordFields: true,
                            readOnly: viewModel.isPasswordChecked,
                            onFieldSubmitted: (_) async {
                              await viewModel.continueTaped();
                              print(viewModel.isPasswordChecked);
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                if (viewModel.isPasswordChecked) {
                                  codeFocusNode.requestFocus();
                                } else {
                                  passwordFocusNode.requestFocus();
                                }
                              });
                            },
                            labelText: 'Mật khẩu',
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  ExpandablePanel(
                    controller: viewModel.enterCodeController,
                    collapsed: const SizedBox(),
                    expanded: Form(
                      key: viewModel.formKeyCode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Đã gửi mã xác nhận đến email đăng ký của bạn, hãy nhập mã nhận được:',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.unSelectedLabel,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          MyTextField(
                            controller: codeController,
                            focusNode: codeFocusNode,
                            onFieldSubmitted: (_) => viewModel.continueTaped(),
                            labelText: 'Mã xác nhận',
                            textInputAction: TextInputAction.done,
                            suffixIcon: ButtonCustom(
                              onPressed: viewModel.isActiveResendCode
                                  ? viewModel.resendCodeTaped
                                  : null,
                              title:
                                  'Gửi lại${viewModel.isActiveResendCode ? '' : ' sau ${viewModel.countdown}'}',
                              borderRadius: 5,
                              textSize: 12,
                              height: 40,
                              width: viewModel.isActiveResendCode ? 70 : 100,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mã xác nhận';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topCenter,
                    child: ButtonCustom(
                      onPressed: viewModel.continueTaped,
                      title: 'Tiếp tục'.toUpperCase(),
                      textSize: 14,
                      height: 40,
                      width: 200,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  RemoveAccountViewModel viewModelBuilder(BuildContext context) {
    return RemoveAccountViewModel(context: context);
  }

  @override
  void onViewModelReady(RemoveAccountViewModel viewModel) {
    syncFormWithViewModel(viewModel);
    emailFocusNode.requestFocus();
  }

  @override
  void onDispose(RemoveAccountViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }
}
