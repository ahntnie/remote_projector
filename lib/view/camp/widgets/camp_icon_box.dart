import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';

class CampIconBox extends StatelessWidget {
  final String icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const CampIconBox({
    super.key,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 60,
      child: Card(
        color: backgroundColor ?? AppColor.navSelected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Image.asset(
                icon,
                color: iconColor ?? AppColor.white,
                width: 25,
                height: 25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
