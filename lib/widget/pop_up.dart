import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../models/response/response_result.dart';

class PopUpWidget extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? leftText;
  final String? rightText;
  final bool twoButton;
  final bool barrierDismissible;
  final Function()? onLeftTap;
  final Function()? onRightTap;

  const PopUpWidget({
    super.key,
    required this.icon,
    required this.title,
    this.leftText,
    this.rightText,
    this.twoButton = false,
    this.barrierDismissible = true,
    required this.onLeftTap,
    this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: PopScope(
        canPop: barrierDismissible,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [
                AppColor.appBarStart,
                AppColor.appBarEnd,
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  height: 80,
                  child: icon,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(
                height: 2,
                color: AppColor.white,
              ),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onLeftTap,
                        borderRadius: BorderRadius.only(
                          bottomLeft: const Radius.circular(6),
                          bottomRight: Radius.circular(twoButton ? 0 : 6),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            leftText ?? 'Xác nhận',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (twoButton)
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onRightTap,
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(6),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              rightText ?? 'Hủy',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showPopupTwoButton({
  required String title,
  required BuildContext context,
  String? leftText,
  String? rightText,
  dynamic icon,
  bool isError = false,
  bool barrierDismissible = true,
  VoidCallback? onLeftTap,
  VoidCallback? onRightTap,
}) async {
  Widget iconWidget =
      Image.asset('assets/images/ic_${isError ? 'error' : 'success'}.png');

  if (icon != null) {
    if (icon is Widget) {
      iconWidget = icon;
    } else if (icon is String) {
      iconWidget = Image.asset(icon);
    }
  }

  return await showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return PopUpWidget(
        icon: iconWidget,
        title: title,
        leftText: leftText,
        rightText: rightText,
        twoButton: true,
        barrierDismissible: barrierDismissible,
        onLeftTap: () {
          Navigator.of(context).pop();
          onLeftTap?.call();
        },
        onRightTap: () {
          Navigator.of(context).pop();
          onRightTap?.call();
        },
      );
    },
  );
}

Future<void> showPopupSingleButton({
  required String title,
  required BuildContext context,
  dynamic icon,
  bool isError = false,
  bool barrierDismissible = true,
  VoidCallback? onButtonTap,
}) async {
  Widget iconWidget =
      Image.asset('assets/images/ic_${isError ? 'error' : 'success'}.png');

  if (icon != null) {
    if (icon is Widget) {
      iconWidget = icon;
    } else if (icon is String) {
      iconWidget = Image.asset(icon);
    }
  }

  return await showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return PopUpWidget(
        icon: iconWidget,
        title: title,
        barrierDismissible: barrierDismissible,
        onLeftTap: () {
          Navigator.of(context).pop();
          onButtonTap?.call();
        },
      );
    },
  );
}

Future<void> showResultError({
  required BuildContext context,
  required ResultError error,
}) async {
  return await showPopupSingleButton(
    title: error.message,
    context: context,
    isError: true,
  );
}

Future<void> showErrorString({
  required BuildContext context,
  required String error,
}) async {
  return await showPopupSingleButton(
    title: error,
    context: context,
    isError: true,
  );
}
