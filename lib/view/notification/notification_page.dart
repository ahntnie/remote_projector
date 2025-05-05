import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../view_models/notification.vm.dart';
import '../../widget/base_page.dart';
import 'widget/notification_item.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationViewModel>.reactive(
      viewModelBuilder: () => NotificationViewModel(),
      onViewModelReady: (viewModel) {
        viewModel.initialise();
      },
      builder: (context, viewModel, child) {
        return BasePage(
          showAppBar: true,
          isBusy: viewModel.isBusy,
          showLeadingAction: true,
          title: 'Thông báo'.toUpperCase(),
          actions: [
            IconButton(
              onPressed: viewModel.updateAllNotification,
              tooltip: 'Đã xem tất cả',
              icon: const Icon(
                Icons.done_all_sharp,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
          body: Material(
            color: Colors.transparent,
            child: RefreshIndicator(
              onRefresh: viewModel.refreshNotification,
              child: Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: viewModel.listNotification.length,
                    itemBuilder: (context, index) {
                      return NotificationItem(
                        data: viewModel.listNotification[index],
                        onNotificationTap: viewModel.onNotificationTaped,
                      );
                    },
                  ),
                  if (viewModel.listNotification.isEmpty)
                    const Center(child: Text('Không có thông báo nào')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
