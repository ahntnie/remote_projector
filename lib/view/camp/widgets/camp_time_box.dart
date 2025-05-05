import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';

class CampTimeBox extends StatelessWidget {
  final String centerText;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const CampTimeBox({
    super.key,
    required this.centerText,
    this.onTap,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Card(
        color: backgroundColor ?? AppColor.bgTimeBox,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Center(
                child: Text(
                  centerText,
                  style: TextStyle(
                    color: textColor ?? AppColor.navSelected,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
