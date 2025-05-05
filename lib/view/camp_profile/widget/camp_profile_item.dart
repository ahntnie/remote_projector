import 'package:flutter/material.dart';

import '../../../models/camp/camp_profile_model.dart';
import 'line_camp_profile.dart';

class CampProfileItem extends StatelessWidget {
  final CampProfileModel data;

  const CampProfileItem({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LineCampProfile(
                  label: 'Tên video: ',
                  content: data.campaignName,
                  maxLine: 2,
                ),
                LineCampProfile(
                  label: 'Tên thiết bị: ',
                  content: data.computerName,
                ),
                LineCampProfile(
                  label: 'Link chạy: ',
                  content: data.url,
                  maxLine: 3,
                ),
                LineCampProfile(
                  label: 'Thời gian chạy: ',
                  content: data.runTime,
                ),
              ],
            ),
          ),
          const Divider(height: 0.5),
        ],
      ),
    );
  }
}
