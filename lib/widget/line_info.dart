import 'package:flutter/material.dart';

import '../../../../constants/app_color.dart';
import '../app/utils.dart';

class LineInfo extends StatelessWidget {
  final String firstText;
  final String? secondsText;
  final int? maxLine;
  final bool canCopy;
  final EdgeInsets? margin;
  final TextStyle? firstStyle;
  final TextStyle? secondsStyle;
  final double? fontSize;
  final VoidCallback? onTap;

  const LineInfo({
    super.key,
    required this.firstText,
    this.secondsText,
    this.maxLine,
    this.canCopy = false,
    this.margin,
    this.firstStyle,
    this.secondsStyle,
    this.fontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      color: AppColor.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress:
              canCopy ? () => copyToClipboard(secondsText, context) : null,
          child: Column(
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text(
                      '$firstText: ',
                      style: firstStyle ??
                          TextStyle(
                            color: AppColor.black,
                            fontWeight: FontWeight.normal,
                            fontSize: fontSize ?? 14,
                          ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        secondsText ?? '',
                        maxLines: maxLine,
                        style: secondsStyle ??
                            TextStyle(
                              color: AppColor.black,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize ?? 14,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}
