import 'package:flutter/material.dart';
import 'package:remote_projector_2024/app/app_sp.dart';

import '../../../app/app_sp_key.dart';
import '../../../app/utils.dart';
import '../../../models/packet/my_packet_model.dart';

class MyPackageItem extends StatelessWidget {
  final MyPacketModel data;
  final ValueChanged<MyPacketModel>? onRenewalTap;
  final ValueChanged<MyPacketModel>? onPaymentTap;
  final ValueChanged<String?>? onCancelTap;

  const MyPackageItem({
    super.key,
    required this.data,
    this.onRenewalTap,
    this.onPaymentTap,
    this.onCancelTap,
  });

  int getTotalDay() {
    int totalDay = 0;

    if (data.expireDate != null) {
      DateTime validDate = DateTime.parse(data.validDate!);
      DateTime expireDate = DateTime.parse(data.expireDate!);
      totalDay = expireDate.difference(validDate).inDays;
    } else {
      DateTime createdDate = DateTime.parse(data.createdDate!);
      int dayOfMonth = DateTime.now().day;
      int statementDay = int.parse(AppSP.get(AppSPKey.statementDate));
      if (dayOfMonth < statementDay) {
        // Tính khoảng cách từ ngày hiện tại đến statementDay trong tháng hiện tại
        DateTime statementDate =
            DateTime(createdDate.year, createdDate.month, statementDay);
        totalDay = statementDate.difference(createdDate).inDays;
      } else {
        // Nếu statementDay đã qua, tính đến statementDay của tháng sau
        DateTime nextMonthFirstDay =
            DateTime(DateTime.now().year, DateTime.now().month + 1, 1);
        DateTime statementDate = DateTime(
            nextMonthFirstDay.year, nextMonthFirstDay.month, statementDay);
        totalDay = statementDate
            .difference(
                DateTime.parse(DateTime.now().toIso8601String().split('T')[0]))
            .inDays;
      }
    }

    return totalDay;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/images/img_package.png",
                          height: 120,
                          width: 120,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10, right: 10),
                          child: Image.asset(
                            'assets/images/ic_${data.deleted != 'y' ? 'checked_${!isDatePast(data.expireDate) && isValidDate(data.validDate) ? 'enable' : 'disable'}' : 'cancel'}.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Mã đơn hàng: ',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: data.regNumber ?? ''),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Thời hạn: ',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            data.isBusiness != '1'
                                ? TextSpan(text: "${data.payMonth} tháng")
                                : TextSpan(text: '${getTotalDay()} ngày'),
                          ],
                        ),
                      ),
                      // RichText(
                      //   text: TextSpan(
                      //     style: const TextStyle(
                      //       fontSize: 14.0,
                      //       color: Colors.black,
                      //     ),
                      //     children: [
                      //       const TextSpan(
                      //         text: 'Thông tin: ',
                      //         style: TextStyle(
                      //           fontSize: 14.0,
                      //           color: Colors.black,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //       TextSpan(
                      //         text:
                      //             'kết nối ${data.limitQty} thiết bị và dung lượng lưu trữ ${formatBytes(int.tryParse(data.limitCapacity ?? '0') ?? 0, decimals: 0)}',
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Text(
                        '${formatNumber(data.price)}đ',
                        style: const TextStyle(color: Color(0xffEB6E2C)),
                      ),
                      Text(
                        data.detail ?? '',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                data.expireDate != null && data.expireDate!.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Ngày hiệu lực: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: convertTimeString2(data.validDate) ??
                                      'chưa kích hoạt',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Ngày kết thúc: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: convertTimeString2(data.expireDate) ??
                                      'chưa kích hoạt',
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            const TextSpan(text: 'Trạng thái: '),
                            TextSpan(
                              text: isBeforeNow(data.paymentDueDate)
                                  ? 'chờ thanh toán'
                                  : 'hết hạn thanh toán',
                              style: TextStyle(
                                color: isBeforeNow(data.paymentDueDate)
                                    ? Colors.orangeAccent
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                const Spacer(),
                if (data.deleted != 'y')
                  Material(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isBeforeNow(data.paymentDueDate) &&
                            (data.expireDate == null ||
                                data.expireDate?.isEmpty == true))
                          InkWell(
                            onTap: () => onPaymentTap?.call(data),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Thanh toán',
                                    style: TextStyle(
                                      color: Color(0xff027800),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Image.asset('assets/images/ic_pay.png'),
                                ],
                              ),
                            ),
                          ),
                        // if (isCurrentDateBefore30Days(data.expireDate) &&
                        //     data.isTrial != '1')
                        if (((AppSP.get(AppSPKey.statementDate) ==
                                        DateTime.now().day &&
                                    data.paymentDate == null &&
                                    data.isBusiness == '1') ||
                                (isCurrentDateBefore30Days(data.expireDate) &&
                                    data.isBusiness != '1')) &&
                            data.isTrial != '1')
                          InkWell(
                            onTap: () => onRenewalTap?.call(data),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    data.isBusiness == '1'
                                        ? 'Thanh toán'
                                        : 'Gia hạn gói cước',
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
                        if (!isDatePast(data.expireDate) ||
                            (data.expireDate == null ||
                                data.expireDate?.isEmpty == true))
                          InkWell(
                            onTap: () => onCancelTap?.call(data.paidId),
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                'Hủy gói cước',
                                style: TextStyle(
                                  color: Color(0xffff0000),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
