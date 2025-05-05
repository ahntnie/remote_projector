import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../requests/notification/notification.request.dart';
import '../view/notification/notification_page.dart';

class BasePage extends StatefulWidget {
  final bool showAppBar;
  final bool showLeadingAction;
  final Function? onBackPressed;
  final dynamic title;
  final bool showNotification;
  final bool showAddCamp;
  final bool isDevicePage;
  final bool isBusy;
  final bool showDeleteDir;
  final Widget? leading;
  final Widget body;
  final Widget? bottomSheet;
  final Widget? bottomNavigationBar;
  final Widget? fab;
  final List<Widget>? actions;
  final FloatingActionButtonLocation? fabLocation;
  final Color? appBarColor;
  final double? elevation;
  final Color? appBarItemColor;
  final PreferredSize? customAppbar;
  final VoidCallback? onPressedDeleteDir;
  final VoidCallback? onPressedShareDir;
  final VoidCallback? onPressedSettingDir;

  const BasePage({
    required this.body,
    this.showAppBar = false,
    this.isBusy = false,
    this.showDeleteDir = false,
    this.leading,
    this.showLeadingAction = false,
    this.onBackPressed,
    this.title = "",
    this.showNotification = false,
    this.bottomSheet,
    this.bottomNavigationBar,
    this.fab,
    this.actions,
    this.fabLocation,
    this.appBarColor,
    this.appBarItemColor,
    this.elevation,
    this.customAppbar,
    this.onPressedDeleteDir,
    this.onPressedShareDir,
    this.onPressedSettingDir,
    this.showAddCamp = false,
    this.isDevicePage = false,
    super.key,
  });

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int countNotification = 0;
  bool fetchNotify = true;

  NotificationRequest notificationRequest = NotificationRequest();

  @override
  void initState() {
    if (widget.showNotification) {
      Future.delayed(const Duration(milliseconds: 200), () {
        getNotification();
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    fetchNotify = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey.shade100,
        appBar: widget.customAppbar ??
            (widget.showAppBar
                ? AppBar(
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.appBarStart,
                            AppColor.appBarEnd,
                          ],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: widget.elevation,
                    automaticallyImplyLeading: widget.showLeadingAction,
                    leading: widget.showLeadingAction
                        ? widget.leading ??
                            IconButton(
                              icon: Image.asset(
                                'assets/images/back_arrow.png',
                                width: 24,
                                height: 12,
                              ),
                              tooltip: 'Quay lại',
                              onPressed: widget.onBackPressed != null
                                  ? () => widget.onBackPressed!()
                                  : () => Navigator.pop(context),
                            )
                        : null,
                    title: widget.title is Widget
                        ? widget.title
                        : Text(
                            widget.title,
                            style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                    actions: widget.actions ??
                        (widget.isDevicePage
                            ? [
                                IconButton(
                                  onPressed: () =>
                                      widget.onPressedSettingDir!(),
                                  tooltip: 'Thiết lập mặc định',
                                  icon: const Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => widget.onPressedShareDir!(),
                                  tooltip: 'Chia sẻ hệ thống',
                                  icon: const Icon(
                                    Icons.share,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                if (widget.showDeleteDir)
                                  IconButton(
                                    onPressed: () =>
                                        widget.onPressedDeleteDir!(),
                                    tooltip: 'Xóa hệ thống',
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                              ]
                            : [
                                if (widget.showNotification)
                                  Stack(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const NotificationPage(),
                                            ),
                                          );
                                          int count = await notificationRequest
                                              .getNewNotificationCount();
                                          setState(() {
                                            countNotification = count;
                                          });
                                        },
                                        tooltip: 'Thông báo',
                                        icon: const Icon(
                                          Icons.notifications_none,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                      ),
                                      if (countNotification > 0)
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: IgnorePointer(
                                            child: Container(
                                              height: 20,
                                              width: 20,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  countNotification > 99
                                                      ? '99+'
                                                      : '$countNotification',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                              ]),
                  )
                : null),
        body: Stack(
          children: [
            widget.body,
            if (widget.isBusy)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: AppColor.black.withOpacity(0.4),
                child: const Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: widget.bottomNavigationBar,
        bottomSheet: widget.bottomSheet,
        floatingActionButton: widget.fab,
        floatingActionButtonLocation: widget.fabLocation,
      ),
    );
  }

  void getNotification() async {
    if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
      int count = await notificationRequest.getNewNotificationCount();

      if (count != countNotification) {
        setState(() {
          countNotification = count;
        });
      }
    }

    Future.delayed(const Duration(seconds: 10), () {
      if (fetchNotify) getNotification();
    });
  }
}
