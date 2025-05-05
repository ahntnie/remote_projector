import 'package:flutter/material.dart';
import 'package:remote_projector_2024/constants/app_color.dart';

import '../../../app/utils.dart';
import '../../../models/transaction/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel data;

  const TransactionItem({
    super.key,
    required this.data,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.refTransactionId ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        convertDateTimeString2(data.paymentDate) ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${formatNumber(data.amount)}đ',
                  style: const TextStyle(
                    color: Color(0xffEB6E2C),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              color: AppColor.borderMemoryBar,
              height: 0.5,
              width: double.infinity,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Image.asset(
                    "assets/images/img_package.png",
                    height: 50,
                    width: 50,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.namePacket ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Mã đơn hàng: ${data.regNumber ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
                const Text(
                  'Hoàn thành',
                  style: TextStyle(
                    color: AppColor.statusRunning,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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
