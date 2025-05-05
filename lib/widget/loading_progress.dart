import 'package:flutter/material.dart';

import '../constants/app_color.dart';

class LoadingProgress extends StatelessWidget {
  final bool isBusy;

  const LoadingProgress({super.key, required this.isBusy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isBusy ? double.infinity : 0,
      height: isBusy ? double.infinity : 0,
      color: AppColor.white.withOpacity(0.2),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColor.navSelected,
        ),
      ),
    );
  }
}