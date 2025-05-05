import 'package:flutter/material.dart';

class CampLineAction extends StatelessWidget {
  final String title;
  final String leadingIconString;
  final Widget? leadingIcon;
  final MainAxisAlignment? mainAxisAlignment;
  final bool iconInRight;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const CampLineAction({
    super.key,
    required this.title,
    this.leadingIconString = 'assets/images/ic_pensil.png',
    this.leadingIcon,
    this.onTap,
    this.iconInRight = false,
    this.mainAxisAlignment,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> item = [
      SizedBox(
        width: 15,
        height: 15,
        child: leadingIcon ??
            Image.asset(leadingIconString, width: 15, height: 15),
      ),
      const SizedBox(width: 10),
      Text(
        title,
        maxLines: 1,
        style: const TextStyle(fontSize: 13),
      ),
    ];

    if (iconInRight) {
      item = item.reversed.toList();
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
          children: item,
        ),
      ),
    );
  }
}
