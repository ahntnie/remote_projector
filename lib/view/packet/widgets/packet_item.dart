import 'package:flutter/material.dart';

import '../../../app/utils.dart';
import '../../../models/packet/packet_model.dart';

class PackageItem extends StatelessWidget {
  final PacketModel data;
  final String buttonLabel;
  final Widget? badgeImage;
  final bool showExpireDate;
  final ValueChanged<PacketModel>? onBuyTap;
  final bool showBuyPacket;
  const PackageItem({
    super.key,
    required this.data,
    required this.buttonLabel,
    this.showExpireDate = false,
    this.badgeImage,
    required this.showBuyPacket,
    this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  "assets/images/img_package.png",
                  height: 120,
                  width: 120,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gói cước ${data.namePacket}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // RichText(
                      //   text: TextSpan(
                      //     style: const TextStyle(
                      //         fontSize: 14.0, color: Colors.black),
                      //     children: [
                      //       const TextSpan(
                      //         text: 'Thời hạn: ',
                      //         style: TextStyle(
                      //           fontSize: 14.0,
                      //           color: Colors.black,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //       TextSpan(
                      //         text:
                      //             '${(int.tryParse(data.yearQty ?? '0') ?? 0) > 0 ? '${data.yearQty} năm ' : ''}'
                      //             '${(int.tryParse(data.monthQty ?? '0') ?? 0) > 0 ? '${data.monthQty} tháng ' : ''}'
                      //             '${(int.tryParse(data.dayQty ?? '0') ?? 0) > 0 ? '${data.dayQty} ngày ' : ''}',
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Thông tin: ',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'kết nối ${data.limitQty} thiết bị và dung lượng lưu trữ ${formatBytes(int.tryParse(data.limitCapacity ?? '0') ?? 0, decimals: 0)}',
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${formatNumber(data.price)}đ',
                        style: const TextStyle(color: Color(0xffEB6E2C)),
                      ),
                      Text(data.detail ?? '', maxLines: 3),
                    ],
                  ),
                ),
              ],
            ),
            if (data.isTrial != '1')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Row(
                    children: [
                      if (showExpireDate) Text('Thời hạn: ${data.expireDate}'),
                      const Spacer(),
                      if (showBuyPacket)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onBuyTap?.call(data),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    buttonLabel,
                                    style: const TextStyle(
                                      color: Color(0xff027800),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Image.asset("assets/images/ic_pay.png"),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
