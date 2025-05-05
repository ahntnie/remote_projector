import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import '../../app/app_string.dart';
import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../models/device/device_model.dart';
import '../../models/dir/dir_model.dart';
import '../../models/user/user.dart';
import '../../view_models/detail_device.vm.dart';
import '../../view_models/device.vm.dart';
import '../../view_models/dir.vm.dart';
import '../../widget/base_page.dart';
import '../../widget/loading_shimmer.dart';
import '../../widget/pop_up.dart';
import '../account/widgets/user_card.dart';
import '../camp/widgets/camp_item.dart';
import '../camp/widgets/camp_line_action.dart';
import 'widget/change_text_widget.dart';
import 'widget/device_card.dart';

class DeviceDetailPage extends StatefulWidget {
  final Device device;
  final Dir currentDir;
  final DeviceViewModel deviceViewModel;
  final DirViewModel dirViewModel;
  final bool inDir;

  const DeviceDetailPage({
    super.key,
    required this.device,
    required this.currentDir,
    required this.deviceViewModel,
    required this.dirViewModel,
    required this.inDir,
  });

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  bool checkAlive = false;

  @override
  void initState() {
    checkAlive = checkIfWithinFiveMinutes(widget.device.lastedAliveTime);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DetailDeviceViewModel>.reactive(
      viewModelBuilder: () => DetailDeviceViewModel(
        context: context,
        currentDevice: widget.device,
        currentDir: widget.currentDir,
        inDir: widget.inDir,
      ),
      onViewModelReady: (viewModel) {
        viewModel.initialise();
      },
      builder: (context, viewModel, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          isBusy: viewModel.isBusy,
          title: 'Chi tiết thiết bị',
          actions: [
            if (viewModel.currentDevice.isOwner == true)
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ChangeTextWidget(
                        text: viewModel.currentDevice.computerName,
                        onChanged: viewModel.updateDeviceName,
                      );
                    },
                  );
                },
                tooltip: 'Đổi tên thiết bị',
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
          ],
          body: Stack(
            children: [
              ScreenTypeLayout.builder(
                mobile: (BuildContext context) =>
                    _buildViewDetailDeviceMobile(viewModel),
                desktop: (BuildContext context) =>
                    _buildViewDetailDeviceWindows(viewModel),
              ),
              if (viewModel.isWaitCommand)
                const GradientLoadingWidget(showFull: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewDetailDeviceMobile(DetailDeviceViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: viewModel.refreshCurrentDevice,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(),
          SliverFillRemaining(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: DeviceCard(
                    inDir: widget.currentDir.dirId != -1,
                    data: viewModel.currentDevice,
                    dirViewModel: widget.dirViewModel,
                    deviceViewModel: widget.deviceViewModel,
                    onTap: false,
                    isDetail: true,
                  ),
                ),
                Expanded(
                  child: viewModel.currentDevice.isOwner == true ||
                          viewModel.currentDevice.isShareOwner == true
                      ? _buildViewOwner(viewModel)
                      : _buildViewGuest(viewModel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailDeviceWindows(DetailDeviceViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: viewModel.refreshCurrentDevice,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(),
                SliverFillRemaining(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: DeviceCard(
                          inDir: widget.currentDir.dirId != -1,
                          data: viewModel.currentDevice,
                          dirViewModel: widget.dirViewModel,
                          deviceViewModel: widget.deviceViewModel,
                          onTap: false,
                          isDetail: true,
                        ),
                      ),
                      Expanded(
                        child: viewModel.currentDevice.isOwner == true ||
                                viewModel.currentDevice.isShareOwner == true
                            ? _buildOwnerDeviceManagerWindows(viewModel)
                            : _buildGuestDeviceManagerWindows(viewModel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: AppColor.navUnSelect,
          height: double.infinity,
          width: 0.5,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        ),
        Expanded(
          child: viewModel.currentDevice.isOwner == true ||
                  viewModel.currentDevice.isShareOwner == true
              ? _buildViewOwner(viewModel, isMobileView: false)
              : _buildViewGuest(viewModel, isMobileView: false),
        ),
      ],
    );
  }

  Widget _buildOwnerDeviceManagerWindows(DetailDeviceViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Quản lý thiết bị',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                if (!isMobile)
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      onPressed: viewModel.refreshCurrentDevice,
                      icon: const Icon(Icons.refresh_outlined, size: 20),
                      tooltip: 'Làm mới thiết bị',
                      color: AppColor.navUnSelect,
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              // Expanded(
              //   child: CampLineAction(
              //     title: 'Chạy USB',
              //     leadingIcon: const Icon(
              //       Icons.usb,
              //       size: 20,
              //       color: Colors.black,
              //     ),
              //     onTap: () async {
              //       if (!viewModel.isBusy) {
              //         await viewModel.createCommand(
              //           device: viewModel.currentDevice,
              //           command: AppString.videoFromUSB,
              //         );
              //       }
              //     },
              //   ),
              // ),
              Expanded(
                child: CampLineAction(
                  title: 'Chạy CAMP',
                  leadingIcon: const Icon(
                    Icons.campaign_outlined,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.videoFromCamp,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Xem giờ thiết bị',
                  leadingIcon: const Icon(
                    Icons.timer_sharp,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.getTimeNow,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: CampLineAction(
                  title: 'Khởi động lại ứng dụng',
                  leadingIcon: const Icon(
                    Icons.restart_alt_outlined,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.restartApp,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Dừng / Tiếp tục video',
                  leadingIcon: const Icon(
                    Icons.motion_photos_paused,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.videoPause,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: CampLineAction(
                  title: 'Tắt chạy video',
                  leadingIcon: const Icon(
                    Icons.stop_circle_outlined,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.videoStop,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Mở YOUTUBE',
                  leadingIcon: const Icon(
                    Icons.play_circle_fill,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openYoutube,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: CampLineAction(
                  title: 'Mở NETFLIX',
                  leadingIcon: const Icon(
                    Icons.movie,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openNetflix,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Mở SPOTIFY',
                  leadingIcon: const Icon(
                    Icons.music_note,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openSpotify,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: CampLineAction(
                  title: 'Mở TS Screen',
                  leadingIcon: Image.asset(
                    'assets/images/ic_ts.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openTSScreen,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Mở Vòng quay may mắn',
                  leadingIcon: Image.asset(
                    'assets/images/ic_fortune_wheel.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openFortuneWheel,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: CampLineAction(
                  title: 'Mở VieON',
                  leadingIcon: const Icon(
                    Icons.computer,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openVieOn,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Mở TIKTOK',
                  leadingIcon: Image.asset(
                    'assets/images/ic_tiktok.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openTiktok,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: CampLineAction(
                  title: 'Mở trang chủ',
                  leadingIcon: const Icon(
                    Icons.home,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openHome,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Khởi động lại thiết bị',
                  leadingIcon: const Icon(
                    Icons.restart_alt_outlined,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.restartDevice,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          if (viewModel.listCustomerOnDevice.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Người được chia sẻ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          if (viewModel.listCustomerOnDevice.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.listCustomerOnDevice.length,
                itemBuilder: (context, index) {
                  return UserCard(
                    user: viewModel.listCustomerOnDevice[index],
                    onCancelSharedTap: (user) =>
                        cancelSharedDevice(viewModel, user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuestDeviceManagerWindows(DetailDeviceViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Quản lý thiết bị',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                if (!isMobile)
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      onPressed: viewModel.refreshCurrentDevice,
                      icon: const Icon(Icons.refresh_outlined, size: 20),
                      tooltip: 'Làm mới thiết bị',
                      color: AppColor.navUnSelect,
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              // Expanded(
              //   child: CampLineAction(
              //     title: 'Chạy USB',
              //     leadingIcon: const Icon(
              //       Icons.usb,
              //       size: 20,
              //       color: Colors.black,
              //     ),
              //     onTap: () async {
              //       if (!viewModel.isBusy) {
              //         await viewModel.createCommand(
              //           device: viewModel.currentDevice,
              //           command: AppString.videoFromUSB,
              //         );
              //       }
              //     },
              //   ),
              // ),
              Expanded(
                child: CampLineAction(
                  title: 'Chạy CAMP',
                  leadingIcon: const Icon(
                    Icons.campaign_outlined,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.videoFromCamp,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Xem giờ thiết bị',
                  leadingIcon: const Icon(
                    Icons.timer_sharp,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.getTimeNow,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: CampLineAction(
                  title: 'Khởi động lại ứng dụng',
                  leadingIcon: const Icon(
                    Icons.restart_alt_outlined,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.restartApp,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Dừng / Tiếp tục video',
                  leadingIcon: const Icon(
                    Icons.motion_photos_paused,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.videoPause,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: CampLineAction(
                  title: 'Tắt chạy video',
                  leadingIcon: const Icon(
                    Icons.stop_circle_outlined,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.videoStop,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Mở YOUTUBE',
                  leadingIcon: const Icon(
                    Icons.play_circle_fill,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openYoutube,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: CampLineAction(
                  title: 'Mở NETFLIX',
                  leadingIcon: const Icon(
                    Icons.movie,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openNetflix,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Mở SPOTIFY',
                  leadingIcon: const Icon(
                    Icons.music_note,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openSpotify,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: CampLineAction(
                  title: 'Mở TS Screen',
                  leadingIcon: Image.asset(
                    'assets/images/ic_ts.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openTSScreen,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Mở Vòng quay may mắn',
                  leadingIcon: Image.asset(
                    'assets/images/ic_fortune_wheel.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openFortuneWheel,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: CampLineAction(
                  title: 'Mở VieON',
                  leadingIcon: const Icon(
                    Icons.computer,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openVieOn,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CampLineAction(
                  title: 'Mở TIKTOK',
                  leadingIcon: Image.asset(
                    'assets/images/ic_tiktok.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openTiktok,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: CampLineAction(
                  title: 'Mở trang chủ',
                  leadingIcon: const Icon(
                    Icons.home,
                    size: 20,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createCommand(
                        device: viewModel.currentDevice,
                        command: AppString.openHome,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewGuest(DetailDeviceViewModel viewModel,
      {bool isMobileView = true}) {
    bool isManageVideo = viewModel.currentDevice.isOwner == true ||
        viewModel.isSharedDevice() ||
        viewModel.currentDevice.isShareOwner == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobileView) _buildGuestDeviceManagerWindows(viewModel),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Danh sách video',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              if (!isMobile)
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: viewModel.refreshCampInDevice,
                    icon: const Icon(Icons.refresh_outlined, size: 20),
                    tooltip: 'Làm mới video',
                    color: AppColor.navUnSelect,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (isManageVideo)
          Container(
            color: AppColor.appBarStart.withOpacity(0.1),
            width: double.infinity,
            height: 40,
            margin: const EdgeInsets.only(top: 5),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: viewModel.onAddNewVideoTaped,
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Thêm video mới cho thiết bị',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: viewModel.refreshCampInDevice,
            child: ListView.builder(
              itemCount: viewModel.listCampOnDevice.length,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (context, index) {
                return CampItem(
                  data: viewModel.listCampOnDevice[index],
                  removeMode: viewModel.removeMode,
                  campSelected: viewModel.campSelected,
                  onEditTap: viewModel.removeMode
                      ? viewModel.onItemTapedInRemoveMode
                      : viewModel.onEditCampaignTaped,
                  onCloningTap:
                      isManageVideo ? viewModel.onCloningCampaignTaped : null,
                  onDeleteTap:
                      isManageVideo ? viewModel.onDeleteCampaignTaped : null,
                  onHistoryTap: viewModel.onHistoryRunCampaignTaped,
                  onLongPress: viewModel.onItemTapedInRemoveMode,
                );
              },
            ),
          ),
        ),
        if (viewModel.removeMode)
          Row(
            children: [
              IconButton(
                onPressed: viewModel.onCancelRemoveMode,
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Hủy',
                color: AppColor.navUnSelect,
                constraints: const BoxConstraints(
                  minWidth: 30,
                  minHeight: 30,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Đã chọn ${viewModel.campSelected.length}',
                  style: const TextStyle(
                    color: AppColor.navUnSelect,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 45,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: viewModel.onDeleteCampSelected,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: const Center(
                        child: Text(
                          'Xóa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildViewOwner(DetailDeviceViewModel viewModel,
      {bool isMobileView = true}) {
    return DefaultTabController(
      initialIndex: 0,
      length: isMobileView ? 3 : 2,
      child: Column(
        children: [
          PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: SizedBox(
              height: 40,
              child: TabBar(
                indicatorColor: AppColor.navSelected,
                labelColor: AppColor.navSelected,
                unselectedLabelColor: AppColor.unSelectedLabel,
                tabAlignment: TabAlignment.center,
                isScrollable: true,
                labelStyle: const TextStyle(fontSize: 16),
                tabs: [
                  if (isMobileView) const Tab(text: 'Thiết bị'),
                  const Tab(text: 'Video'),
                  Tab(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        const Text('Chờ duyệt'),
                        if (viewModel.listCampRequestOnDevice.isNotEmpty)
                          Positioned(
                            top: -5,
                            right: -10,
                            child: IgnorePointer(
                              child: Container(
                                height: 15,
                                width: 15,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    viewModel.listCampRequestOnDevice.length >
                                            99
                                        ? '99+'
                                        : '${viewModel.listCampRequestOnDevice.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                onTap: (tabIndex) {
                  if (!isMobile && tabIndex == viewModel.currentTab) {
                    switch (tabIndex) {
                      case 0:
                        isMobileView
                            ? viewModel.refreshCurrentDevice()
                            : viewModel.refreshCampInDevice();
                        break;
                      case 1:
                        viewModel.refreshCampInDevice();
                        break;
                      case 2:
                        viewModel.refreshCampInDevice();
                        break;
                    }
                  }
                  viewModel.changeTab(tabIndex);
                },
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (isMobileView)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: ExpandablePanel(
                            controller: viewModel.expandableManagerController,
                            header: Container(
                              height: 40,
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Quản lý thiết bị',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            collapsed: const SizedBox(),
                            expanded: Material(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 1),
                                  Row(
                                    children: [
                                      // Expanded(
                                      //   child: CampLineAction(
                                      //     title: 'Chạy USB',
                                      //     leadingIcon: const Icon(
                                      //       Icons.usb,
                                      //       size: 20,
                                      //       color: Colors.black,
                                      //     ),
                                      //     onTap: () async {
                                      //       if (!viewModel.isBusy) {
                                      //         await viewModel.createCommand(
                                      //           device: viewModel.currentDevice,
                                      //           command: AppString.videoFromUSB,
                                      //         );
                                      //       }
                                      //     },
                                      //   ),
                                      // ),
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Chạy CAMP',
                                          leadingIcon: const Icon(
                                            Icons.campaign_outlined,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command:
                                                    AppString.videoFromCamp,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 1),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Xem giờ thiết bị',
                                          leadingIcon: const Icon(
                                            Icons.timer_sharp,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command: AppString.getTimeNow,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Khởi động lại ứng dụng',
                                          leadingIcon: const Icon(
                                            Icons.restart_alt_outlined,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command: AppString.restartApp,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 1),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Dừng / Tiếp tục video',
                                          leadingIcon: const Icon(
                                            Icons.motion_photos_paused,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command: AppString.videoPause,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Tắt chạy video',
                                          leadingIcon: const Icon(
                                            Icons.stop_circle_outlined,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command: AppString.videoStop,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 1),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Mở YOUTUBE',
                                          leadingIcon: const Icon(
                                            Icons.play_circle_fill,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command: AppString.openYoutube,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Mở NETFLIX',
                                          leadingIcon: const Icon(
                                            Icons.movie,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command: AppString.openNetflix,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 1),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Mở SPOTIFY',
                                          leadingIcon: const Icon(
                                            Icons.music_note,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command: AppString.openSpotify,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Mở TS Screen',
                                          leadingIcon: Image.asset(
                                            'assets/images/ic_ts.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command: AppString.openTSScreen,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 1),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Mở Vòng quay may mắn',
                                          leadingIcon: Image.asset(
                                            'assets/images/ic_fortune_wheel.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command:
                                                    AppString.openFortuneWheel,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Mở VieON',
                                          leadingIcon: const Icon(
                                            Icons.computer,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command: AppString.openVieOn,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Mở TIKTOK',
                                          leadingIcon: Image.asset(
                                            'assets/images/ic_tiktok.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command: AppString.openTiktok,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Mở trang chủ',
                                          leadingIcon: const Icon(
                                            Icons.home,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command: AppString.openHome,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CampLineAction(
                                          title: 'Khởi động lại thiết bị',
                                          leadingIcon: const Icon(
                                            Icons.restart_alt_outlined,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            if (!viewModel.isBusy) {
                                              await viewModel.createCommand(
                                                device: viewModel.currentDevice,
                                                command:
                                                    AppString.restartDevice,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (viewModel.listCustomerOnDevice.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              'Người được chia sẻ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        if (viewModel.listCustomerOnDevice.isNotEmpty)
                          Expanded(
                            child: ListView.builder(
                              itemCount: viewModel.listCustomerOnDevice.length,
                              itemBuilder: (context, index) {
                                return UserCard(
                                  user: viewModel.listCustomerOnDevice[index],
                                  onCancelSharedTap: (user) =>
                                      cancelSharedDevice(viewModel, user),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                RefreshIndicator(
                  onRefresh: viewModel.refreshCampInDevice,
                  child: _lineViewVideoInDevice(viewModel),
                ),
                RefreshIndicator(
                  onRefresh: viewModel.refreshCampInDevice,
                  child: _lineViewVideoRequestInDevice(viewModel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineViewVideoInDevice(DetailDeviceViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: AppColor.appBarStart.withOpacity(0.1),
          width: double.infinity,
          height: 40,
          margin: const EdgeInsets.only(top: 5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => viewModel.onAddNewVideoTaped(autoApprove: true),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Thêm video mới cho thiết bị',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: viewModel.listCampOnDevice.length,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 10),
            itemBuilder: (context, index) {
              return CampItem(
                data: viewModel.listCampOnDevice[index],
                removeMode: viewModel.removeMode,
                campSelected: viewModel.campSelected,
                onEditTap: viewModel.removeMode
                    ? viewModel.onItemTapedInRemoveMode
                    : (camp) =>
                        viewModel.onEditCampaignTaped(camp, autoApprove: true),
                onCloningTap: (camp) =>
                    viewModel.onCloningCampaignTaped(camp, autoApprove: true),
                onDeleteTap: viewModel.onDeleteCampaignTaped,
                onHistoryTap: viewModel.onHistoryRunCampaignTaped,
                onLongPress: viewModel.onItemTapedInRemoveMode,
              );
            },
          ),
        ),
        if (viewModel.removeMode)
          Row(
            children: [
              IconButton(
                onPressed: viewModel.onCancelRemoveMode,
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Hủy',
                color: AppColor.navUnSelect,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Đã chọn ${viewModel.campSelected.length}',
                  style: const TextStyle(
                    color: AppColor.navUnSelect,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 45,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: viewModel.onDeleteCampSelected,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: const Center(
                        child: Text(
                          'Xóa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _lineViewVideoRequestInDevice(DetailDeviceViewModel viewModel) {
    return Stack(
      children: [
        if (viewModel.listCampRequestOnDevice.isEmpty)
          const Center(child: Text('Không có video nào đang chờ duyệt')),
        ListView.builder(
          itemCount: viewModel.listCampRequestOnDevice.length,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 10),
          itemBuilder: (context, index) {
            // print(viewModel.currentDevice.isShareOwner);
            // print(viewModel.currentDevice.isOwner);
            return CampItem(
              data: viewModel.listCampRequestOnDevice[index],
              removeMode: viewModel.removeMode,
              campSelected: viewModel.campSelected,
              onEditTap: viewModel.removeMode
                  ? viewModel.onItemTapedInRemoveMode
                  : (camp) => viewModel.onEditCampaignTaped(camp,
                      autoApprove: true,
                      isOwner: viewModel.currentDevice.isShareOwner ?? false
                          ? true
                          : viewModel.currentDevice.isOwner ?? false),
              onCloningTap: (camp) =>
                  viewModel.onCloningCampaignTaped(camp, autoApprove: true),
              onDeleteTap: viewModel.onDeleteCampaignTaped,
              onHistoryTap: viewModel.onHistoryRunCampaignTaped,
              onLongPress: viewModel.onItemTapedInRemoveMode,
            );
          },
        ),
      ],
    );
  }

  void cancelSharedDevice(DetailDeviceViewModel viewModel, User user) {
    showPopupTwoButton(
      title:
          'Bạn có chắc chắn hủy chia sẻ thiết bị cho ${user.customerName} không?',
      context: context,
      isError: true,
      onLeftTap: () async {
        bool checkDelete = await viewModel.deleteDeviceShared(user.customerId);
        if (checkDelete) {
          viewModel.initialise();
          widget.dirViewModel.refreshSharedDevicesByCustomer();
          viewModel.onDeleteDeviceSharedSuccess();
        } else if (mounted) {
          showPopupSingleButton(
            title: 'Có lỗi xảy ra, vui lòng thử lại sau.',
            context: context,
            isError: true,
          );
        }
      },
    );
  }
}
