import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';
import '../../../models/device/device_shared_model.dart';

class DeviceSharedItem extends StatelessWidget {
  final DeviceSharedModel data;
  final bool isOwner;
  final Function(DeviceSharedModel)? onCancelTaped;
  final Function(DeviceSharedModel)? onShareTaped;
  final Function(DeviceSharedModel)? onTaped;

  const DeviceSharedItem(
      {super.key,
      required this.data,
      this.isOwner = false,
      this.onTaped,
      this.onCancelTaped,
      this.onShareTaped});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTaped?.call(data),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                  Colors.black, BlendMode.srcIn),
                              child: Image.asset(
                                'assets/images/ic_projector.png',
                                height: 25,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              data.computerName ?? '',
                              style: const TextStyle(
                                color: AppColor.navSelected,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColor.black,
                            ),
                            children: [
                              TextSpan(
                                  text: 'Chia sẻ ${isOwner ? 'đến' : 'từ'}: '),
                              TextSpan(
                                text: data.customerName ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwner)
                    InkWell(
                      onTap: () => onCancelTaped?.call(data),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Center(
                          child: Text(
                            'Hủy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (isOwner || (data.isShareOwner ?? false))
                    InkWell(
                      onTap: () => onShareTaped?.call(data),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Center(
                          child: Text(
                            'Chia sẻ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 0.5),
          ],
        ),
      ),
    );
  }
}
