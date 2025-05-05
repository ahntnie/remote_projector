import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';

class LineInfoDevice extends StatelessWidget {
  final String leftText;
  final String rightText;
  final TextStyle? leftTextStyle;
  final TextStyle? rightTextStyle;
  final EdgeInsets? margin;

  const LineInfoDevice({
    super.key,
    required this.leftText,
    required this.rightText,
    this.leftTextStyle,
    this.rightTextStyle,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Row(
        children: [
          Text(
            leftText,
            style: leftTextStyle ??
                const TextStyle(
                  color: AppColor.unSelectedLabel,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              rightText,
              maxLines: 1,
              style: rightTextStyle ??
                  const TextStyle(
                      color: AppColor.unSelectedLabel, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
