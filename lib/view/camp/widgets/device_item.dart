import 'package:flutter/material.dart';

import '../../../app/utils.dart';
import '../../../constants/app_color.dart';
import '../../../models/device/device_model.dart';
import '../../device/widget/line_info_device.dart';

class DeviceItem extends StatelessWidget {
  final Device data;
  final bool showTitleName;
  final List<String?> computerId;
  final ValueChanged<String?>? onDeviceTap;

  const DeviceItem({
    super.key,
    required this.data,
    this.showTitleName = false,
    this.computerId = const <String>[],
    this.onDeviceTap,
  });

  @override
  Widget build(BuildContext context) {
    bool checkAlive = checkIfWithinFiveMinutes(data.lastedAliveTime);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onDeviceTap != null
            ? () => onDeviceTap!.call(data.computerId)
            : null,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            if (showTitleName)
                              const TextSpan(
                                text: 'Tên thiết bị: ',
                                style: TextStyle(
                                  color: AppColor.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            TextSpan(
                              text: data.computerName ?? '',
                              style: const TextStyle(
                                color: AppColor.navSelected,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: LineInfoDevice(
                          leftText: 'Loại:',
                          rightText: data.type ?? '',
                        ),
                      ),
                      Text(
                        checkAlive ? 'Đang kết nối' : 'Ngắt kết nối',
                        style: TextStyle(
                          color: checkAlive
                              ? AppColor.statusRunning
                              : AppColor.statusDisable,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
