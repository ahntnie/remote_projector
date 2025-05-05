import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';

class LineCaseColorProfile extends StatelessWidget {
  final String? label;
  final Color? color;
  final VoidCallback? onLabelTap;

  const LineCaseColorProfile({
    super.key,
    this.label,
    this.color,
    this.onLabelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onLabelTap,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  label ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: color ?? AppColor.white,
                height: 20,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
