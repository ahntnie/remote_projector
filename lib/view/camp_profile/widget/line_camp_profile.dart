import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';

class LineCampProfile extends StatelessWidget {
  final String label;
  final String? content;
  final int? maxLine;
  final TextStyle? labelStyle;
  final TextStyle? contentStyle;

  const LineCampProfile({
    super.key,
    required this.label,
    this.content,
    this.maxLine = 1,
    this.labelStyle,
    this.contentStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        maxLines: maxLine,
        text: TextSpan(
          text: label,
          style: labelStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColor.navUnSelect,
              ),
          children: [
            TextSpan(
              text: content,
              style: contentStyle ??
                  const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: AppColor.navUnSelect,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
