import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../constants/app_constants.dart';
import '../../view_models/account.vm.dart';
import '../../widget/base_page.dart';
import '../../widget/button_custom.dart';
import '../../widget/pop_up.dart';
import 'widgets/account_list_title.dart';
import 'widgets/birth_date_picker.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AccountViewModel>.reactive(
      viewModelBuilder: () => AccountViewModel(context: context),
      onViewModelReady: (viewModel) {
        viewModel.initialise();
      },
      builder: (context, viewModel, child) {
        return BasePage(
          isBusy: viewModel.isBusy,
          body: SingleChildScrollView(
            child: Column(
              children: [
                AccountListTile(
                  isCenter: true,
                  title: 'Đăng xuất',
                  leadingIcon: const Icon(
                    Icons.power_settings_new_rounded,
                    size: 24,
                    color: Color(0xff797979),
                  ),
                  onTap: () {
                    showPopupTwoButton(
                      title: 'Bạn có chắc chắn muốn đăng xuất không?',
                      leftText: 'Đăng xuất',
                      context: context,
                      onLeftTap: viewModel.signOut,
                    );
                  },
                ),
                AccountListTile(
                  customTitle: Row(
                    children: [
                      const Text('Hỗ trợ hotline: '),
                      Text(
                        '${viewModel.configModel?.hotline}',
                        style: const TextStyle(
                          color: AppColor.appBarStart,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  leadingIcon: Image.asset(
                    'assets/images/ic_phone.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () =>
                      copyToClipboard(viewModel.configModel?.hotline, context),
                ),
                AccountListTile(
                  leadingIcon: const Icon(Icons.apps_rounded),
                  trailingWidget: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 20,
                    color: Color(0xffA4A4A4),
                  ),
                  title: 'Hướng dẫn sử dụng',
                  onTap: viewModel.toWebViewPage,
                ),
                AccountListTile(
                  title: 'Giới thiệu',
                  leadingIcon: const Icon(Icons.info_outline_rounded),
                  trailingWidget: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 20,
                    color: Color(0xffA4A4A4),
                  ),
                  onTap: viewModel.toIntroducePage,
                ),
                const SizedBox(height: 20),
                AccountListTile(
                  title: 'Quản lý tài nguyên',
                  leadingIcon: Image.asset(
                    'assets/images/ic_folder.png',
                    width: 24,
                    height: 24,
                  ),
                  trailingWidget: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 20,
                    color: Color(0xffA4A4A4),
                  ),
                  onTap: viewModel.toResourceManagerPage,
                ),
                AccountListTile(
                  title: 'Vòng quay may mắn',
                  leadingIcon: Image.asset(
                    'assets/images/ic_fortune_wheel.png',
                    width: 24,
                    height: 24,
                  ),
                  trailingWidget: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 20,
                    color: Color(0xffA4A4A4),
                  ),
                  onTap: viewModel.toLuckyWheelPage,
                ),
                if (AppSP.get(AppSPKey.loginWith) != 'google')
                  AccountListTile(
                    title: 'Đổi mật khẩu',
                    leadingIcon: Image.asset(
                      'assets/images/ic_password.png',
                      width: 24,
                      height: 24,
                    ),
                    trailingWidget: const Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                      color: Color(0xffA4A4A4),
                    ),
                    onTap: viewModel.toChangePasswordPage,
                  ),
                AccountListTile(
                  title: 'Xóa tài khoản',
                  trailingWidget: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 20,
                    color: Color(0xffA4A4A4),
                  ),
                  onTap: viewModel.toRemoveAccountPage,
                ),
                const SizedBox(height: 20),
                AccountListTile(
                  title: 'Họ & tên',
                  leadingIcon: Image.asset(
                    'assets/images/ic_profile.png',
                    width: 24,
                    height: 24,
                  ),
                  customTitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Họ & tên',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xff797979)),
                      ),
                      Text(
                        viewModel.currentUser?.customerName ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                BirthDatePicker(
                  currentUser: viewModel.currentUser,
                  onDatePicked: (DateTime? pickedDate) {
                    if (pickedDate != null) {
                      viewModel.currentUser?.dateOfBirth =
                          pickedDate.toString();
                      viewModel.notifyListeners();
                    }
                  },
                ),
                AccountListTile(
                  leadingIcon: Image.asset(
                    'assets/images/ic_sex.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    showBottomChoseGender(
                      gender: AppConstants.genderList,
                      position: (position) {
                        viewModel.changeGender(position == 0
                            ? null
                            : AppConstants.genderList[position]);
                      },
                    );
                  },
                  customTitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giới tính',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff797979),
                        ),
                      ),
                      Text(
                        viewModel.currentUser != null &&
                                viewModel.currentUser!.sex != null &&
                                viewModel.currentUser!.sex!.isNotEmpty
                            ? viewModel.currentUser!.sex!
                            : 'Thêm thông tin giới tính',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColor.navUnSelect,
                        ),
                      ),
                    ],
                  ),
                ),
                if (AppSP.get(AppSPKey.loginWith) != 'google')
                  AccountListTile(
                    leadingIcon: Image.asset(
                      'assets/images/ic_phone_number.png',
                      width: 24,
                      height: 24,
                    ),
                    customTitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Số điện thoại',
                          style: TextStyle(
                              fontSize: 12, color: AppColor.navUnSelect),
                        ),
                        Text(
                          viewModel.currentUser?.phoneNumber ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                AccountListTile(
                  leadingIcon: Image.asset(
                    'assets/images/ic_email.png',
                    width: 24,
                    height: 24,
                  ),
                  customTitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Địa chỉ email',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.navUnSelect,
                        ),
                      ),
                      Text(
                        viewModel.currentUser?.email ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 70,
                    vertical: 20,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: ButtonCustom(
                      onPressed: viewModel.handleUpdateCustomer,
                      title: 'Lưu thông tin',
                      textSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showBottomChoseGender(
      {required List<String> gender,
      required ValueChanged<int> position}) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade100,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Chọn giới tính',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                ...gender.mapIndexed((item, index) {
                  return ListTile(
                    title: Text(gender[index]),
                    onTap: () {
                      position.call(index);
                      Navigator.of(context).pop();
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}

//  function doLogin() {
//     // Lấy dữ liệu từ POST
//     $email = $this->getPOST('email');
//     $password = $this->getPOST('password');
//     $customer_token = $this->getPOST('customer_token'); // Token từ thiết bị đăng nhập

//     // Kiểm tra dữ liệu đầu vào
//     if (empty($email) || empty($password)) {
//         echo json_encode([
//             "status" => -1,
//             "msg" => "Vui lòng nhập email/số điện thoại và mật khẩu!"
//         ]);
//         return;
//     }

//     // Kiểm tra thông tin đăng nhập
//     $sql = "SELECT customer_id, customer_name, address, phone_number, email, date_of_birth, sex, chu_tk, stk, nganhang, chinhanh, password, customer_token 
//             FROM customer_list 
//             WHERE (email = ? OR phone_number = ?) AND password = ? AND IFNULL(deleted, 'n') != 'y'";
//     $user = $this->executeResult($sql);

//     if (count($user) >= 1) {
//         $user = $user[0]; // Lấy bản ghi đầu tiên
//         $customer_id = $user['customer_id'];

//         // Xử lý customer_token (thêm token mới nếu có)
//         if (!empty($customer_token)) {
//             // Lấy danh sách token hiện tại
//             $current_tokens = json_decode($user['customer_token'] ?: '[]', true) ?: [];
            
//             // Kiểm tra và thêm token mới nếu chưa tồn tại
//             if (!in_array($customer_token, $current_tokens)) {
//                 $current_tokens[] = $customer_token;
//                 // Giới hạn số lượng token (ví dụ: tối đa 10)
//                 if (count($current_tokens) > 10) {
//                     array_shift($current_tokens); // Xóa token cũ nhất
//                 }
//                 $new_token_json = json_encode($current_tokens);

//                 // Cập nhật customer_token trong DB
//                 $update_sql = "UPDATE customer_list SET customer_token = ? WHERE customer_id = ?";
//                 $success = $this->execute($update_sql, [$new_token_json, $customer_id], $errortext);

//                 if (!$success) {
//                     echo json_encode([
//                         "status" => -1,
//                         "msg" => "Lỗi khi cập nhật token: " . ($errortext ?: "Không xác định")
//                     ]);
//                     return;
//                 }
//             }
//         }

//         $res = [
//             "status" => 1,
//             "msg" => "Đăng nhập thành công!!!",
//             "info" => $user
//         ];
//     } else {
//         // Kiểm tra tài khoản bị vô hiệu hóa
//         $sql = "SELECT customer_id, customer_name FROM customer_list 
//                 WHERE (email = ? OR phone_number = ?) AND IFNULL(deleted, 'n') = 'y'";
//         $user = $this->executeResult($sql, [$email, $email]);

//         if (count($user) >= 1) {
//             $res = [
//                 "status" => -1,
//                 "msg" => "Tài khoản đã bị vô hiệu hóa!!!",
//                 "info" => count($user)
//             ];
//         } else {
//             $res = [
//                 "status" => -1,
//                 "msg" => "Email, số điện thoại hoặc mật khẩu không đúng!!!",
//                 "info" => 0
//             ];
//         }
//     }

//     echo json_encode($res);
// }