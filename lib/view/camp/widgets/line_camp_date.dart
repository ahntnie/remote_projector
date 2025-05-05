import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';

class LineCampDate extends StatelessWidget {
  final String label;
  final String? content;
  final int? maxLine;
  final bool readOnly;
  final TextStyle? labelStyle;
  final TextStyle? contentStyle;
  final VoidCallback? onTextTap;

  const LineCampDate({
    super.key,
    required this.label,
    this.readOnly = false,
    this.content,
    this.maxLine,
    this.labelStyle,
    this.contentStyle,
    this.onTextTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: labelStyle ??
                const TextStyle(
                  fontSize: 14,
                  color: AppColor.navUnSelect,
                ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: readOnly ? null : onTextTap,
              child: Container(
                padding: const EdgeInsets.only(top: 10, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content ?? '',
                      style: contentStyle ??
                          const TextStyle(fontSize: 18, color: AppColor.black),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: AppColor.appBarStart, height: 1),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
