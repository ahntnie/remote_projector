import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';
import '../../../models/dir/dir_shared_model.dart';

class DirSharedItem extends StatelessWidget {
  final DirSharedModel data;
  final Function(DirSharedModel)? onCancelTaped;
  final Function(DirSharedModel)? onTaped;

  const DirSharedItem({
    super.key,
    required this.data,
    this.onTaped,
    this.onCancelTaped,
  });

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
                            Image.asset(
                              'assets/images/img_folder_owner.png',
                              width: 25,
                              height: 25,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              data.nameDir ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColor.black,
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
                              const TextSpan(text: 'Chia sẻ đến: '),
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
