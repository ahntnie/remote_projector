import 'package:flutter/material.dart';
import 'package:remote_projector_2024/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.locator.dart';
import '../../constants/app_color.dart';
import '../../widget/base_page.dart';
import '../../widget/button_custom.dart';
import 'widgets/line_alert_info.dart';

class AlertRemoveAccountPage extends StatefulWidget {
  const AlertRemoveAccountPage({super.key});

  @override
  State<AlertRemoveAccountPage> createState() => _AlertRemoveAccountPageState();
}

class _AlertRemoveAccountPageState extends State<AlertRemoveAccountPage> {
  final _navigationService = appLocator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Xóa tài khoản',
      showAppBar: true,
      showLeadingAction: true,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Xóa tài khoản sẽ:',
                        style: TextStyle(
                          color: AppColor.black,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const LineAlertInfo(
                        text:
                            'Toàn bộ dữ liệu sẽ bị xóa và không thể khôi phục lại',
                      ),
                      const LineAlertInfo(
                        text:
                            'Thiết bị đã kết nối sẽ không còn đăng nhập vào được tài khoản nữa',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: ButtonCustom(
                          onPressed:
                              _navigationService.navigateToRemoveAccountPage,
                          title: 'Xóa tài khoản'.toUpperCase(),
                          height: 35,
                          textSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
