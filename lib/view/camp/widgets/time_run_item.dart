import 'package:flutter/material.dart';
import 'package:remote_projector_2024/models/camp/camp_model.dart';

import '../../../app/utils.dart';
import '../../../models/camp/time_run_model.dart';
import 'camp_icon_box.dart';
import 'camp_time_box.dart';

class TimeRunItem extends StatelessWidget {
  final TimeRunModel time;
  final int index;
  final ValueChanged<int> onSubtractTap;
  final Function(TimeRunModel, int)? onTimeTap;

  const TimeRunItem({
    super.key,
    required this.time,
    required this.index,
    required this.onSubtractTap,
    this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CampTimeBox(
          centerText:
              '${convertStringTime(time.fromTime)} - ${convertStringTime(time.toTime)}',
          onTap: onTimeTap != null ? () => onTimeTap?.call(time, index) : null,
        ),
        const SizedBox(width: 10),
        CampIconBox(
          icon: 'assets/images/ic_subtract.png',
          onTap: onTimeTap == null ? null : () => onSubtractTap.call(index),
        ),
      ],
    );
  }
}
