import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../models/device/device_model.dart';
import '../../models/device/device_shared_model.dart';
import '../../models/dir/dir_model.dart';
import '../../models/user/user.dart';
import '../../view_models/device.vm.dart';
import '../../view_models/dir.vm.dart';
import '../../widget/base_page.dart';
import '../device/device_detail_page.dart';
import '../device/widget/device_card.dart';
import 'widgets/device_shared_item.dart';
import 'widgets/dir_shared_item.dart';

class DirPage extends StatefulWidget {
  const DirPage({super.key});

  @override
  State<DirPage> createState() => _DirPageState();
}

class _DirPageState extends State<DirPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int axisCount = ((width - 10) / 90).floor();

    return ViewModelBuilder<DirViewModel>.reactive(
      viewModelBuilder: () => DirViewModel(context: context),
      onViewModelReady: (viewModel) {
        viewModel.initialise();
      },
      builder: (context, viewModel, child) {
        return GestureDetector(
          onTap: viewModel.clearEditAndChangeNameFolder,
          child: BasePage(
            isBusy: viewModel.isBusy,
            body: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelStyle: const TextStyle(fontSize: 16),
                    indicatorColor: AppColor.navSelected,
                    labelColor: AppColor.navSelected,
                    unselectedLabelColor: AppColor.unSelectedLabel,
                    tabAlignment: TabAlignment.center,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Chủ sở hữu'),
                      Tab(text: 'Được chia sẻ'),
                      Tab(text: 'Đã chia sẻ'),
                    ],
                    onTap: (tabIndex) {
                      if (!isMobile && tabIndex == viewModel.currentTab) {
                        switch (tabIndex) {
                          case 0:
                            viewModel.refreshOwnerTab();
                            break;
                          case 1:
                            viewModel.refreshSharedByOtherTab();
                            break;
                          case 2:
                            viewModel.refreshSharedByCustomerTab();
                            break;
                        }
                      }

                      viewModel.changeTab(tabIndex);
                      viewModel.clearEditAndChangeNameFolder();
                    },
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildOwnerView(viewModel, axisCount),
                        _buildSharedView(viewModel, axisCount),
                        _buildSharedFromCustomerView(viewModel),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOwnerView(DirViewModel viewModel, int axisCount) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) =>
          _buildOwnerViewMobile(viewModel, axisCount),
      desktop: (BuildContext context) => _buildOwnerViewWindows(viewModel),
    );
  }

  Widget _buildOwnerViewMobile(DirViewModel viewModel, int axisCount) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: constraints.maxHeight * viewModel.folderFraction,
                    child: RefreshIndicator(
                      onRefresh: viewModel.refreshDir,
                      child: _viewOwnerDirectory(viewModel, axisCount),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            'Thiết bị ngoài',
                            style: TextStyle(
                              color: AppColor.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: viewModel.refreshExternalDevices,
                            child: _lineViewExternalDevice(viewModel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: constraints.maxHeight * viewModel.folderFraction - 10,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) => viewModel.onChangeFraction(
                    details,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: Container(
                    color: Colors.transparent,
                    width: constraints.maxWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 20,
                    child: const Stack(
                      children: [
                        Center(child: Divider(height: 0.5)),
                        Center(
                          child: Row(
                            children: [
                              Icon(
                                Icons.expand_outlined,
                                size: 10,
                                color: AppColor.black,
                              ),
                              Expanded(child: SizedBox()),
                              Icon(
                                Icons.expand_outlined,
                                size: 10,
                                color: AppColor.black,
                              ),
                              Expanded(child: SizedBox()),
                              Icon(
                                Icons.expand_outlined,
                                size: 10,
                                color: AppColor.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOwnerViewWindows(DirViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double folderFraction = viewModel.folderFraction.clamp(
              190 / constraints.maxWidth,
              (constraints.maxWidth - 400) / constraints.maxWidth);
          int axisCount =
              ((constraints.maxWidth * folderFraction - 10) / 90).floor();

          return Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * folderFraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            'Hệ thống đã tạo',
                            style: TextStyle(
                              color: AppColor.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: viewModel.refreshDir,
                            child: _viewOwnerDirectory(viewModel, axisCount),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            'Thiết bị ngoài',
                            style: TextStyle(
                              color: AppColor.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: viewModel.refreshExternalDevices,
                            child: _lineViewExternalDevice(viewModel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                left: constraints.maxWidth * folderFraction - 10,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      viewModel.onChangeFraction(
                    details,
                    maxWidth: constraints.maxWidth,
                    clampMin: 190 / constraints.maxWidth,
                  ),
                  child: Container(
                    color: Colors.transparent,
                    height: constraints.maxHeight,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: 20,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            height: double.infinity,
                            width: 0.5,
                            color: AppColor.black,
                          ),
                        ),
                        Center(
                          child: Column(
                            children: [
                              Transform.rotate(
                                angle: pi / 2,
                                child: const Icon(
                                  Icons.expand_outlined,
                                  size: 10,
                                  color: AppColor.black,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              Transform.rotate(
                                angle: pi / 2,
                                child: const Icon(
                                  Icons.expand_outlined,
                                  size: 10,
                                  color: AppColor.black,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              Transform.rotate(
                                angle: pi / 2,
                                child: const Icon(
                                  Icons.expand_outlined,
                                  size: 10,
                                  color: AppColor.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSharedFromCustomerView(DirViewModel viewModel) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) =>
          _buildSharedFromCustomerViewMobile(viewModel),
      desktop: (BuildContext context) =>
          _buildSharedFromCustomerViewWindows(viewModel),
    );
  }

  Widget _buildSharedFromCustomerViewMobile(DirViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: constraints.maxHeight * viewModel.folderFraction,
                    child: RefreshIndicator(
                      onRefresh: viewModel.refreshDir,
                      child: _viewSharedDirectoryByCustomer(viewModel),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            'Thiết bị đã chia sẻ',
                            style: TextStyle(
                              color: AppColor.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: viewModel.refreshSharedDevicesByCustomer,
                            child: _lineViewSharedDeviceByCustomer(viewModel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: constraints.maxHeight * viewModel.folderFraction - 10,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) => viewModel.onChangeFraction(
                    details,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: Container(
                    color: Colors.transparent,
                    width: constraints.maxWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 20,
                    child: const Stack(
                      children: [
                        Center(child: Divider(height: 0.5)),
                        Center(
                          child: Row(
                            children: [
                              Icon(
                                Icons.expand_outlined,
                                size: 10,
                                color: AppColor.black,
                              ),
                              Expanded(child: SizedBox.shrink()),
                              Icon(
                                Icons.expand_outlined,
                                size: 10,
                                color: AppColor.black,
                              ),
                              Expanded(child: SizedBox.shrink()),
                              Icon(
                                Icons.expand_outlined,
                                size: 10,
                                color: AppColor.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSharedFromCustomerViewWindows(DirViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double clampMax = (constraints.maxWidth - 300) / constraints.maxWidth;
          double folderFraction = viewModel.folderFraction
              .clamp(300 / constraints.maxWidth, clampMax);

          return Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * folderFraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            'Hệ thống đã chia sẻ',
                            style: TextStyle(
                              color: AppColor.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: viewModel.refreshDir,
                            child: _viewSharedDirectoryByCustomer(viewModel),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            'Thiết bị đã chia sẻ',
                            style: TextStyle(
                              color: AppColor.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: viewModel.refreshSharedDevicesByCustomer,
                            child: _lineViewSharedDeviceByCustomer(viewModel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                left: constraints.maxWidth * folderFraction - 10,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      viewModel.onChangeFraction(
                    details,
                    maxWidth: constraints.maxWidth,
                    clampMin: 300 / constraints.maxWidth,
                    clampMax: clampMax,
                  ),
                  child: Container(
                    color: Colors.transparent,
                    height: constraints.maxHeight,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: 20,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            height: double.infinity,
                            width: 0.5,
                            color: AppColor.black,
                          ),
                        ),
                        Center(
                          child: Column(
                            children: [
                              Transform.rotate(
                                angle: pi / 2,
                                child: const Icon(
                                  Icons.expand_outlined,
                                  size: 10,
                                  color: AppColor.black,
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                              Transform.rotate(
                                angle: pi / 2,
                                child: const Icon(
                                  Icons.expand_outlined,
                                  size: 10,
                                  color: AppColor.black,
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                              Transform.rotate(
                                angle: pi / 2,
                                child: const Icon(
                                  Icons.expand_outlined,
                                  size: 10,
                                  color: AppColor.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSharedView(DirViewModel viewModel, int axisCount) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) =>
          _buildSharedViewMobile(viewModel, axisCount),
      desktop: (BuildContext context) => _buildSharedViewWindows(viewModel),
    );
  }

  Widget _buildSharedViewMobile(DirViewModel viewModel, int axisCount) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: constraints.maxHeight * viewModel.folderFraction,
                    child: RefreshIndicator(
                      onRefresh: viewModel.refreshDir,
                      child: _viewSharedDirectory(viewModel, axisCount),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            'Thiết bị được chia sẻ',
                            style: TextStyle(
                              color: AppColor.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: viewModel.refreshSharedDevices,
                            child: _lineViewSharedDevice(viewModel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: constraints.maxHeight * viewModel.folderFraction - 10,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) => viewModel.onChangeFraction(
                    details,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: Container(
                    color: Colors.transparent,
                    width: constraints.maxWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 20,
                    child: const Stack(
                      children: [
                        Center(child: Divider(height: 0.5)),
                        Center(
                          child: Row(
                            children: [
                              Icon(
                                Icons.expand_outlined,
                                size: 10,
                                color: AppColor.black,
                              ),
                              Expanded(child: SizedBox.shrink()),
                              Icon(
                                Icons.expand_outlined,
                                size: 10,
                                color: AppColor.black,
                              ),
                              Expanded(child: SizedBox.shrink()),
                              Icon(
                                Icons.expand_outlined,
                                size: 10,
                                color: AppColor.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSharedViewWindows(DirViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double folderFraction = viewModel.folderFraction.clamp(
              190 / constraints.maxWidth,
              (constraints.maxWidth - 400) / constraints.maxWidth);
          int axisCount =
              ((constraints.maxWidth * folderFraction - 10) / 90).floor();

          return Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * folderFraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            'Hệ thống được chia sẻ',
                            style: TextStyle(
                              color: AppColor.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: viewModel.refreshDir,
                            child: _viewSharedDirectory(viewModel, axisCount),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            'Thiết bị được chia sẻ',
                            style: TextStyle(
                              color: AppColor.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: viewModel.refreshSharedDevices,
                            child: _lineViewSharedDevice(viewModel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                left: constraints.maxWidth * folderFraction - 10,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      viewModel.onChangeFraction(
                    details,
                    maxWidth: constraints.maxWidth,
                    clampMin: 190 / constraints.maxWidth,
                  ),
                  child: Container(
                    color: Colors.transparent,
                    height: constraints.maxHeight,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: 20,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            height: double.infinity,
                            width: 0.5,
                            color: AppColor.black,
                          ),
                        ),
                        Center(
                          child: Column(
                            children: [
                              Transform.rotate(
                                angle: pi / 2,
                                child: const Icon(
                                  Icons.expand_outlined,
                                  size: 10,
                                  color: AppColor.black,
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                              Transform.rotate(
                                angle: pi / 2,
                                child: const Icon(
                                  Icons.expand_outlined,
                                  size: 10,
                                  color: AppColor.black,
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                              Transform.rotate(
                                angle: pi / 2,
                                child: const Icon(
                                  Icons.expand_outlined,
                                  size: 10,
                                  color: AppColor.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _lineViewSharedDevice(DirViewModel viewModel) {
    return Stack(
      children: [
        if (viewModel.listSharedDevices.isEmpty)
          const Center(child: Text('Không có thiết bị nào được chia sẻ')),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: viewModel.listSharedDevices.length,
          itemBuilder: (context, index) {
            Device item = viewModel.listSharedDevices[index];

            return DeviceSharedItem(
              data: DeviceSharedModel(
                isShareOwner: item.isShareOwner!,
                computerId: item.computerId,
                computerName: item.computerName,
                type: item.type,
                serialComputer: item.serialComputer,
                customerName: item.customerName,
                idDir: item.idDir,
                lastedAliveTime: item.lastedAliveTime,
                romMemoryTotal: item.romMemoryTotal,
                romMemoryUsed: item.romMemoryUsed,
              ),
              isOwner: item.isOwner!, //false,
              onShareTaped: viewModel.shareDevice,
              onTaped: (device) async {
                final User currentUser =
                    User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
                Dir? dir = [...viewModel.listDir, ...viewModel.listShareDir]
                    .where((e) => e.dirId?.toString() == device.idDir)
                    .firstOrNull;

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return DeviceDetailPage(
                        device: Device(
                          isShareOwner: item.isShareOwner,
                          customerId: currentUser.customerId,
                          isOwner: item.isOwner!, //false,
                          idDir: device.idDir,
                          computerId: device.computerId,
                          computerName: device.computerName,
                          serialComputer: device.serialComputer,
                          type: device.type,
                          lastedAliveTime: device.lastedAliveTime,
                          romMemoryUsed: device.romMemoryUsed,
                          romMemoryTotal: device.romMemoryTotal,
                        ),
                        currentDir: dir ?? viewModel.defaultDir,
                        dirViewModel: viewModel,
                        deviceViewModel: DeviceViewModel(
                          context: context,
                          currentDir: viewModel.defaultDir,
                          dirViewModel: viewModel,
                        ),
                        inDir: false,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _lineViewSharedDeviceByCustomer(DirViewModel viewModel) {
    return Stack(
      children: [
        if (viewModel.listSharedDevicesByCustomer.isEmpty)
          const Center(child: Text('Không có thiết bị nào đã chia sẻ')),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: viewModel.listSharedDevicesByCustomer.length,
          itemBuilder: (context, index) {
            return DeviceSharedItem(
              data: viewModel.listSharedDevicesByCustomer[index],
              isOwner: true,
              onTaped: (device) async {
                final User currentUser =
                    User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
                Dir? dir = viewModel.listDir
                    .where((e) => e.dirId?.toString() == device.idDir)
                    .firstOrNull;

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return DeviceDetailPage(
                        device: Device(
                          customerId: currentUser.customerId,
                          isOwner: true,
                          idDir: device.idDir,
                          computerId: device.computerId,
                          computerName: device.computerName,
                          serialComputer: device.serialComputer,
                          type: device.type,
                          lastedAliveTime: device.lastedAliveTime,
                          romMemoryTotal: device.romMemoryTotal,
                          romMemoryUsed: device.romMemoryUsed,
                        ),
                        currentDir: dir ?? viewModel.defaultDir,
                        dirViewModel: viewModel,
                        deviceViewModel: DeviceViewModel(
                          context: context,
                          currentDir: viewModel.defaultDir,
                          dirViewModel: viewModel,
                        ),
                        inDir: false,
                      );
                    },
                  ),
                );
              },
              onCancelTaped: viewModel.cancelSharedDevice,
              onShareTaped: viewModel.shareDevice,
            );
          },
        ),
      ],
    );
  }

  Widget _lineViewExternalDevice(DirViewModel viewModel) {
    DeviceViewModel deviceViewModel = DeviceViewModel(
      context: context,
      currentDir: viewModel.defaultDir,
      dirViewModel: viewModel,
    );

    return Stack(
      children: [
        if (viewModel.listExternalDevices.isEmpty)
          const Center(child: Text('Không có thiết bị ngoài nào')),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: viewModel.listExternalDevices.length,
          itemBuilder: (context, index) {
            return DeviceCard(
              deviceViewModel: deviceViewModel,
              data: viewModel.listExternalDevices[index],
              dirViewModel: viewModel,
              inDir: false,
              isOwner: true,
              dirId: -1,
              onDeleteSuccess: viewModel.getExternalDevices,
              onMovedSuccess: viewModel.onDeviceMovedSuccess,
              onOpenDetailSuccess: viewModel.getExternalDevices,
            );
          },
        ),
      ],
    );
  }

  Widget _viewOwnerDirectory(DirViewModel viewModel, int axisCount) {
    int lengthList = viewModel.listDir.length;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: ((lengthList + 1) / axisCount).ceil(),
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        int startIndex = index * axisCount;
        int endIndex = (startIndex + axisCount).clamp(0, lengthList + 1);
        int mainItemLength = 0;
        List<Widget> listItemInRow = [];

        for (int indexInList = startIndex;
            indexInList < endIndex;
            indexInList++) {
          if (listItemInRow.isNotEmpty) {
            listItemInRow.add(const SizedBox(width: 10));
          }
          if (indexInList >= lengthList) {
            listItemInRow.add(SizedBox(
              width: 80,
              child: dirAddCard(context, viewModel),
            ));
          } else {
            listItemInRow.add(SizedBox(
              width: 80,
              child: dirCard(
                indexInList,
                viewModel,
                viewModel.listDir[indexInList],
                true,
              ),
            ));
          }
          mainItemLength += 1;
        }

        if (mainItemLength < axisCount) {
          int loop = axisCount - mainItemLength;
          for (int i = 0; i < loop; i++) {
            if (listItemInRow.isNotEmpty) {
              listItemInRow.add(const SizedBox(width: 10));
            }
            listItemInRow.add(const SizedBox(width: 80));
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listItemInRow,
          ),
        );
      },
    );
  }

  Widget _viewSharedDirectory(DirViewModel viewModel, int axisCount) {
    int lengthList = viewModel.listShareDir.length;

    return Stack(
      children: [
        if (viewModel.listShareDir.isEmpty)
          const Center(child: Text('Không có hệ thống nào được chia sẻ')),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: (lengthList / axisCount).ceil(),
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, index) {
            int startIndex = index * axisCount;
            int endIndex = (startIndex + axisCount).clamp(0, lengthList);
            int mainItemLength = 0;
            List<Widget> listItemInRow = [];

            for (int indexInList = startIndex;
                indexInList < endIndex;
                indexInList++) {
              if (listItemInRow.isNotEmpty) {
                listItemInRow.add(const SizedBox(width: 10));
              }
              listItemInRow.add(SizedBox(
                width: 80,
                child: dirCard(
                  indexInList,
                  viewModel,
                  viewModel.listShareDir[indexInList],
                  false,
                ),
              ));
              mainItemLength += 1;
            }

            if (mainItemLength < axisCount) {
              int loop = axisCount - mainItemLength;
              for (int i = 0; i < loop; i++) {
                if (listItemInRow.isNotEmpty) {
                  listItemInRow.add(const SizedBox(width: 10));
                }
                listItemInRow.add(const SizedBox(width: 80));
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: listItemInRow,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _viewSharedDirectoryByCustomer(DirViewModel viewModel) {
    return Stack(
      children: [
        if (viewModel.listShareDirByCustomer.isEmpty)
          const Center(
            child: Text('Không có hệ thống nào đã chia sẻ'),
          ),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: viewModel.listShareDirByCustomer.length,
          itemBuilder: (context, index) {
            return DirSharedItem(
              data: viewModel.listShareDirByCustomer[index],
              onTaped: (dir) {
                final User currentUser =
                    User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

                viewModel.currentDir = Dir(
                  isOwner: true,
                  dirName: dir.nameDir,
                  dirId: int.tryParse(dir.idDir ?? '0'),
                  customerId: int.tryParse(currentUser.customerId ?? '0'),
                );
                viewModel.openDevicePage();
              },
              onCancelTaped: viewModel.cancelSharedDirectory,
            );
          },
        ),
      ],
    );
  }

  InkWell dirAddCard(BuildContext context, DirViewModel vm) {
    return InkWell(
      onTap: () => vm.changeEditingFolderName(!vm.isEditingFolderName),
      child: Column(
        children: [
          Image.asset('assets/images/img_folder_add.png'),
          vm.isEditingFolderName
              ? TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(left: 5, right: 5),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffFABD1D)),
                    ),
                  ),
                  controller: vm.folderNameController,
                  focusNode: vm.folderNameFocusNode,
                  onSubmitted: (_) => vm.onCreateNewFolderTaped(),
                  style:
                      const TextStyle(color: Color(0xff797979), fontSize: 12),
                )
              : const Text(
                  'Tạo hệ thống',
                  style: TextStyle(color: Color(0xff797979), fontSize: 12),
                ),
        ],
      ),
    );
  }

  InkWell dirCard(int index, DirViewModel viewModel, Dir dir, bool isOwner) {
    return InkWell(
      onTap: () {
        viewModel.currentDir = dir;
        viewModel.openDevicePage();
      },
      onLongPress: isOwner
          ? () => viewModel.changeChangeFolderName(
                !viewModel.isChangeFolderName,
                idFolder: dir.dirId,
              )
          : null,
      child: Column(
        children: [
          Image.asset(
            isOwner
                ? 'assets/images/img_folder_owner.png'
                : dir.isShareOwner == true
                    ? 'assets/images/img_folder_share_owner.png'
                    : 'assets/images/img_folder_share.png',
          ),
          viewModel.isChangeFolderName &&
                  viewModel.idFolderChangeName == dir.dirId
              ? TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(left: 5, right: 5),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffFABD1D)),
                    ),
                  ),
                  controller: viewModel.changeFolderNameController,
                  focusNode: viewModel.changeFolderNameFocusNode,
                  onSubmitted: (_) => viewModel.onUpdateFolderTaped(),
                  style:
                      const TextStyle(color: Color(0xff797979), fontSize: 12),
                )
              : Text(
                  dir.dirName ?? '',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Color(0xff797979), fontSize: 12),
                ),
        ],
      ),
    );
  }
}
