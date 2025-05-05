import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants/app_color.dart';

class LineCampEditText extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? leadingIcon;
  final String? leadingText;
  final String? error;
  final int? maxLine;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? labelStyle;
  final TextStyle? contentStyle;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onLeadingTextTap;
  final bool readOnly;

  const LineCampEditText({
    super.key,
    required this.controller,
    required this.label,
    this.inputFormatters,
    this.leadingIcon,
    this.leadingText,
    this.textInputAction,
    this.error,
    this.maxLine = 1,
    this.labelStyle,
    this.contentStyle,
    this.onLeadingTap,
    this.onLeadingTextTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: labelStyle ??
                        const TextStyle(
                          fontSize: 14,
                          color: AppColor.navUnSelect,
                        ),
                  ),
                ),
                if (leadingText != null)
                  InkWell(
                    onTap: onLeadingTextTap,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        leadingText ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColor.navUnSelect,
                        ),
                      ),
                    ),
                  ),
                if (leadingIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: InkWell(
                      onTap: onLeadingTap,
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Image.asset(leadingIcon!, height: 24),
                      ),
                    ),
                  ),
              ],
            ),
            TextField(
              controller: controller,
              maxLines: maxLine,
              cursorColor: AppColor.navSelected,
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColor.appBarStart),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColor.appBarStart),
                ),
              ),
              inputFormatters: inputFormatters,
              readOnly: readOnly,
              textInputAction: textInputAction ?? TextInputAction.done,
              style: contentStyle ??
                  const TextStyle(fontSize: 18, color: AppColor.black),
            ),
            if (error != null && error!.isNotEmpty)
              Text(
                error!,
                style: const TextStyle(
                    fontSize: 12, color: AppColor.statusDisable),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
