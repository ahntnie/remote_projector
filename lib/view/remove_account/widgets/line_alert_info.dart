import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';

class LineAlertInfo extends StatelessWidget {
  final String? text;
  final double? space;
  final TextStyle? style;
  final Color? color;

  const LineAlertInfo({
    super.key,
    this.text,
    this.space,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            Icons.fiber_manual_record,
            size: 5,
            color: color ?? AppColor.navUnSelect,
          ),
          SizedBox(width: space ?? 5),
          Expanded(
            child: Text(
              text ?? '',
              style: style ??
                  const TextStyle(
                    color: AppColor.navUnSelect,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
