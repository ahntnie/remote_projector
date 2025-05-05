import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../models/camp/camp_model.dart';
import '../../view_models/device.vm.dart';
import '../../view_models/dir.vm.dart';
import '../../widget/base_page.dart';
import '../account/widgets/user_card.dart';
import '../camp/widgets/camp_item.dart';
import 'widget/device_card.dart';
import 'widget/search_customer_dialog.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key, required this.dirViewModel});

  final DirViewModel dirViewModel;

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeviceViewModel>.reactive(
      viewModelBuilder: () => DeviceViewModel(
        context: context,
        currentDir: widget.dirViewModel.currentDir,
        dirViewModel: widget.dirViewModel,
      ),
      onViewModelReady: (viewModel) {
        viewModel.initialise();
      },
      builder: (context, viewModel, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          isBusy: viewModel.isBusy,
          isDevicePage: viewModel.currentDir.isOwner == true ||
              viewModel.currentDir.isShareOwner == true,
          onPressedDeleteDir: viewModel.deleteDir,
          showDeleteDir: viewModel.currentDir.isOwner == true,
          onPressedSettingDir: viewModel.openSettingDir,
          onPressedShareDir: () async {
            SearchCustomerDialog.show(context, viewModel,
                (customerId, checkOwner) async {
              Navigator.pop(context);
              await viewModel.shareDir(
                viewModel.currentDir.dirId.toString(),
                customerId,
                checkOwner,
              );
            });
          },
          title: widget.dirViewModel.currentDir.dirName,
          body: viewModel.currentDir.isOwner == true ||
                  viewModel.currentDir.isShareOwner == true
              ? _buildOwnerView(viewModel)
              : _buildGuestView(viewModel),
        );
      },
    );
  }

  Widget _buildOwnerView(DeviceViewModel viewModel) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => _buildOwnerViewMobile(viewModel),
      desktop: (BuildContext context) => _buildOwnerViewWindows(viewModel),
    );
  }

  Widget _buildOwnerViewMobile(DeviceViewModel viewModel) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppColor.navSelected,
            labelColor: AppColor.navSelected,
            unselectedLabelColor: AppColor.unSelectedLabel,
            tabAlignment: TabAlignment.center,
            isScrollable: true,
            labelStyle: const TextStyle(fontSize: 16),
            tabs: const [
              Tab(text: 'Thiết bị'),
              Tab(text: 'Video'),
              Tab(text: 'Chờ duyệt'),
              Tab(text: 'Người được chia sẻ'),
            ],
            onTap: (tabIndex) {
              if (!isMobile && tabIndex == viewModel.currentTab) {
                switch (tabIndex) {
                  case 0:
                    viewModel.refreshDeviceInDir();
                    break;
                  case 1:
                    viewModel.refreshVideoInDir();
                    break;
                  case 2:
                    viewModel.refreshVideoInDir();
                    break;
                  case 3:
                    viewModel.refreshSharedCustomer();
                    break;
                }
              }

              viewModel.changeTab(tabIndex);
            },
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                RefreshIndicator(
                  onRefresh: viewModel.refreshDeviceInDir,
                  child: _lineViewDeviceInDir(viewModel),
                ),
                RefreshIndicator(
                  onRefresh: viewModel.refreshVideoInDir,
                  child: _lineViewVideoInDir(viewModel,
                      isOwner: true, isApprove: true),
                ),
                RefreshIndicator(
                  onRefresh: viewModel.refreshVideoInDir,
                  child: _lineViewVideoInDir(viewModel, isOwner: true),
                ),
                RefreshIndicator(
                  onRefresh: viewModel.refreshSharedCustomer,
                  child: _lineViewSharedUserInDir(viewModel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerViewWindows(DeviceViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                padding: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Thiết bị',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (!isMobile)
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: IconButton(
                          onPressed: viewModel.refreshDeviceInDir,
                          icon: const Icon(Icons.refresh_outlined, size: 20),
                          tooltip: 'Làm mới thiết bị',
                          color: AppColor.navUnSelect,
                          constraints:
                              const BoxConstraints(minWidth: 30, minHeight: 30),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(child: _lineViewDeviceInDir(viewModel)),
            ],
          ),
        ),
        Container(
          color: AppColor.navUnSelect,
          height: double.infinity,
          width: 0.5,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        ),
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  indicatorColor: AppColor.navSelected,
                  labelColor: AppColor.navSelected,
                  unselectedLabelColor: AppColor.unSelectedLabel,
                  tabAlignment: TabAlignment.center,
                  isScrollable: true,
                  labelStyle: const TextStyle(fontSize: 16),
                  tabs: const [
                    Tab(text: 'Video'),
                    Tab(text: 'Chờ duyệt'),
                    Tab(text: 'Người được chia sẻ'),
                  ],
                  onTap: (tabIndex) {
                    if (!isMobile && tabIndex == viewModel.currentTab) {
                      switch (tabIndex) {
                        case 0:
                          viewModel.refreshVideoInDir();
                          break;
                        case 1:
                          viewModel.refreshVideoInDir();
                          break;
                        case 2:
                          viewModel.refreshSharedCustomer();
                          break;
                      }
                    }

                    viewModel.changeTab(tabIndex);
                  },
                ),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      RefreshIndicator(
                        onRefresh: viewModel.refreshVideoInDir,
                        child: _lineViewVideoInDir(viewModel,
                            isOwner: true, isApprove: true),
                      ),
                      RefreshIndicator(
                        onRefresh: viewModel.refreshVideoInDir,
                        child: _lineViewVideoInDir(viewModel, isOwner: true),
                      ),
                      RefreshIndicator(
                        onRefresh: viewModel.refreshSharedCustomer,
                        child: _lineViewSharedUserInDir(viewModel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestView(DeviceViewModel viewModel) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => _buildGuestViewMobile(viewModel),
      desktop: (BuildContext context) => _buildGuestViewWindows(viewModel),
    );
  }

  Widget _buildGuestViewMobile(DeviceViewModel viewModel) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppColor.navSelected,
            labelColor: AppColor.navSelected,
            unselectedLabelColor: AppColor.unSelectedLabel,
            tabAlignment: TabAlignment.center,
            isScrollable: true,
            labelStyle: const TextStyle(fontSize: 16),
            tabs: const [
              Tab(text: 'Thiết bị'),
              Tab(text: 'Video'),
              Tab(text: 'Chờ duyệt')
            ],
            onTap: (tabIndex) {
              if (!isMobile && tabIndex == viewModel.currentTab) {
                switch (tabIndex) {
                  case 0:
                    viewModel.refreshDeviceInDir();
                    break;
                  case 1:
                    viewModel.refreshVideoInDir();
                    break;
                  case 2:
                    viewModel.refreshVideoInDir();
                    break;
                }
              }

              viewModel.changeTab(tabIndex);
            },
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                RefreshIndicator(
                  onRefresh: viewModel.refreshDeviceInDir,
                  child: _lineViewDeviceInDir(viewModel),
                ),
                RefreshIndicator(
                  onRefresh: viewModel.refreshVideoInDir,
                  child: _lineViewVideoInDir(viewModel, isApprove: true),
                ),
                RefreshIndicator(
                  onRefresh: viewModel.refreshVideoInDir,
                  child: _lineViewVideoInDir(viewModel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestViewWindows(DeviceViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                padding: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Thiết bị',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (!isMobile)
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: IconButton(
                          onPressed: viewModel.refreshDeviceInDir,
                          icon: const Icon(Icons.refresh_outlined, size: 20),
                          tooltip: 'Làm mới thiết bị',
                          color: AppColor.navUnSelect,
                          constraints:
                              const BoxConstraints(minWidth: 30, minHeight: 30),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(child: _lineViewDeviceInDir(viewModel)),
            ],
          ),
        ),
        Container(
          color: AppColor.navUnSelect,
          height: double.infinity,
          width: 0.5,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        ),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  indicatorColor: AppColor.navSelected,
                  labelColor: AppColor.navSelected,
                  unselectedLabelColor: AppColor.unSelectedLabel,
                  tabAlignment: TabAlignment.center,
                  isScrollable: true,
                  labelStyle: const TextStyle(fontSize: 16),
                  tabs: const [
                    Tab(text: 'Video'),
                    Tab(text: 'Chờ duyệt'),
                  ],
                  onTap: (tabIndex) {
                    if (!isMobile && tabIndex == viewModel.currentTab) {
                      switch (tabIndex) {
                        case 0:
                          viewModel.refreshVideoInDir();
                          break;
                        case 1:
                          viewModel.refreshVideoInDir();
                          break;
                      }
                    }

                    viewModel.changeTab(tabIndex);
                  },
                ),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      RefreshIndicator(
                        onRefresh: viewModel.refreshVideoInDir,
                        child: _lineViewVideoInDir(viewModel,
                            isOwner: true, isApprove: true),
                      ),
                      RefreshIndicator(
                        onRefresh: viewModel.refreshVideoInDir,
                        child: _lineViewVideoInDir(viewModel, isOwner: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _lineViewDeviceInDir(DeviceViewModel viewModel) {
    return Stack(
      children: [
        if (viewModel.listDeviceByDir.isEmpty)
          const Center(
            child: Text('Không có thiết bị nào trong hệ thống'),
          ),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: viewModel.listDeviceByDir.length,
          itemBuilder: (context, index) {
            return DeviceCard(
              deviceViewModel: viewModel,
              isOwner: widget.dirViewModel.currentDir.isOwner == true,
              data: viewModel.listDeviceByDir[index],
              dirViewModel: widget.dirViewModel,
              onOpenDetailStarted: viewModel.openDetailStarted,
              onOpenDetailSuccess: viewModel.openDetailEnded,
              onMovedSuccess: (device) async {
                await widget.dirViewModel.initialise();
                await viewModel.onDeviceMovedSuccess(device);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _lineViewVideoInDir(DeviceViewModel viewModel,
      {bool isOwner = false, bool isApprove = false}) {
    List<CampModel> listCamp = isApprove
        ? viewModel.listVideoByDir
            .where((video) => video.approvedYn == '1')
            .toList()
        : viewModel.listVideoByDirRequest;
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropTarget(
        onDragDone: (detail) {
          viewModel.onAddDragFile(
              detail.files
                  .map((e) => e.path)
                  .where((e) => isSupportedFile(e))
                  .toList(),
              isOwner);
        },
        onDragEntered: (detail) {
          viewModel.changeDraggingToAdd(true);
        },
        onDragExited: (detail) {
          viewModel.changeDraggingToAdd(false);
        },
        child: Stack(
          children: [
            if (listCamp.isEmpty)
              const Center(child: Text('Không có video nào')),
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: listCamp.length,
                    itemBuilder: (context, index) {
                      return CampItem(
                        data: listCamp[index],
                        removeMode: viewModel.removeMode,
                        campSelected: viewModel.campSelected,
                        onEditTap: (camp) => viewModel.removeMode
                            ? viewModel.onItemTapedInRemoveMode(camp)
                            : viewModel.onEditCampaignTaped(camp,
                                isOwner: isOwner),
                        onHistoryTap: viewModel.onHistoryRunCampaignTaped,
                        onDeleteTap: isOwner || !isApprove
                            ? viewModel.onDeleteCampaignTaped
                            : null,
                        onCloningTap:
                            isOwner ? viewModel.onCloningCampaignTaped : null,
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
                        constraints:
                            const BoxConstraints(minWidth: 30, minHeight: 30),
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: viewModel.onDeleteCampSelected,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
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
              ],
            ),
            if (((viewModel.currentDir.isOwner == false &&
                        (viewModel.currentDir.isShareOwner ?? false) ==
                            false) &&
                    isApprove != true) ||
                ((viewModel.currentDir.isOwner == true ||
                            viewModel.currentDir.isShareOwner == true) &&
                        isApprove == true) &&
                    !viewModel.removeMode)
              Positioned(
                bottom: 50,
                right: 10,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColor.appBarStart, AppColor.appBarEnd],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton(
                    icon: const Icon(
                      Icons.add_circle_outline_sharp,
                      color: Colors.white,
                      size: 30,
                    ),
                    tooltip: 'Thêm video',
                    onSelected: (result) {
                      if (result == viewModel.addVideoAction[0]) {
                        viewModel.onAddDefaultMoreVideoTaped(isOwner);
                      } else if (result == viewModel.addVideoAction[1]) {
                        viewModel.onAddNewVideoTaped(isOwner: isOwner);
                      }
                    },
                    padding: const EdgeInsets.all(15),
                    position: PopupMenuPosition.under,
                    color: AppColor.white,
                    itemBuilder: (context) => viewModel.addVideoAction
                        .map(
                          (action) => PopupMenuItem(
                            value: action,
                            child: Text(
                              action,
                              style: const TextStyle(
                                color: AppColor.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            if (viewModel.draggingToAdd)
              DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(5),
                dashPattern: const [8, 6],
                color: viewModel.draggingToAdd
                    ? AppColor.navSelected
                    : AppColor.navUnSelect,
                strokeWidth: 2,
                child: Container(
                  color: AppColor.white.withOpacity(0.85),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (viewModel.draggingToAdd
                              ? AppColor.navSelected
                              : AppColor.navUnSelect)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Thêm nhanh',
                          style: TextStyle(
                            color: viewModel.draggingToAdd
                                ? AppColor.navSelected
                                : AppColor.navUnSelect,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Thả files vào đây để thêm nhanh',
                          style: TextStyle(
                            color: viewModel.draggingToAdd
                                ? AppColor.navSelected
                                : AppColor.navUnSelect,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _lineViewSharedUserInDir(DeviceViewModel viewModel) {
    return Stack(
      children: [
        if (viewModel.listCustomer.isEmpty ||
            viewModel.currentDir.isOwner != true)
          const Center(child: Text('Không có người nào được chia sẻ')),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: viewModel.listCustomer.length,
          itemBuilder: (context, index) {
            return UserCard(
              user: viewModel.listCustomer[index],
              onCancelSharedTap: viewModel.onCancelSharedCustomerTap,
            );
          },
        ),
      ],
    );
  }
}
