import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';
import '../../../models/camp/camp_profile_model.dart';

class NewResponseItem extends StatelessWidget {
  final CampProfileModel data;

  const NewResponseItem({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 3),
          child: Divider(height: 1, color: Colors.black),
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                data.runTimeServer ?? '',
                maxLines: 3,
                style: const TextStyle(color: AppColor.black, fontSize: 12),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 3,
              child: Text(
                data.computerName ?? '',
                maxLines: 3,
                style: const TextStyle(
                  color: AppColor.navSelected,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 4,
              child: Text(
                data.url ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColor.black, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
