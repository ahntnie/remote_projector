import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../app/utils.dart';
import '../../../constants/app_color.dart';
import '../../../models/device/device_model.dart';
import '../../../models/dir/dir_model.dart';
import '../../../view_models/device.vm.dart';
import '../../../view_models/dir.vm.dart';
import '../../../widget/pop_up.dart';
import '../../camp/widgets/camp_line_action.dart';
import '../device_detail_page.dart';
import 'line_info_device.dart';
import 'memory_bar.dart';
import 'search_customer_dialog.dart';

class DeviceCard extends StatefulWidget {
  const DeviceCard({
    super.key,
    required this.data,
    required this.dirViewModel,
    required this.deviceViewModel,
    this.onTap = true,
    this.inDir = true,
    this.isOwner = false,
    this.isDetail = false,
    this.showDir = true,
    this.checkAlive,
    this.dirId,
    this.onMovedSuccess,
    this.onDeleteSuccess,
    this.onShared,
    this.onOpenDetailSuccess,
    this.onOpenDetailStarted,
  });

  final Device data;
  final DirViewModel dirViewModel;
  final DeviceViewModel deviceViewModel;
  final bool onTap;
  final bool inDir;
  final bool isOwner;
  final bool isDetail;
  final bool? checkAlive;
  final bool showDir;
  final int? dirId;
  final Function(Device)? onMovedSuccess;
  final VoidCallback? onDeleteSuccess;
  final VoidCallback? onShared;
  final VoidCallback? onOpenDetailSuccess;
  final VoidCallback? onOpenDetailStarted;

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  @override
  Widget build(BuildContext context) {
    bool checkAlive = widget.checkAlive ??
        checkIfWithinFiveMinutes(widget.data.lastedAliveTime);

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        margin: const EdgeInsets.only(top: 5),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap
                ? () async {
                    if (widget.onTap) {
                      widget.onOpenDetailStarted?.call();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return DeviceDetailPage(
                              device: widget.data,
                              currentDir: widget.dirId == -1
                                  ? widget.dirViewModel.defaultDir
                                  : widget.dirViewModel.currentDir,
                              dirViewModel: widget.dirViewModel,
                              deviceViewModel: widget.deviceViewModel,
                              inDir: widget.inDir,
                            );
                          },
                        ),
                      );
                      widget.onOpenDetailSuccess?.call();
                    }
                  }
                : null,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcIn,
                              ),
                              child: Image.asset(
                                'assets/images/ic_projector.png',
                                height: 40,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.data.computerName ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColor.navSelected,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    MemoryBar(
                                      width: constraints.maxWidth / 3,
                                      romMemoryTotal: double.parse(
                                          widget.data.romMemoryTotal ?? '0'),
                                      romMemoryUsed: double.parse(
                                          widget.data.romMemoryUsed ?? '0'),
                                    ),
                                  ],
                                ),
                                Text(
                                  checkAlive ? 'Đang kết nối' : 'Ngắt kết nối',
                                  style: TextStyle(
                                    color: checkAlive
                                        ? AppColor.statusRunning
                                        : AppColor.statusDisable,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: LineInfoDevice(
                              leftText: 'Loại:',
                              rightText: widget.data.type ?? '',
                            ),
                          ),
                          if (widget.showDir)
                            Expanded(
                              child: LineInfoDevice(
                                leftText: 'Hệ thống:',
                                rightText: widget.data.nameDir ??
                                    (widget.inDir
                                        ? widget.dirViewModel.currentDir
                                                .dirName ??
                                            ''
                                        : 'Không có'),
                              ),
                            ),
                        ],
                      ),
                      if (widget.isDetail)
                        LineInfoDevice(
                          leftText: 'Hoạt động gần nhất:',
                          rightText: convertDateTimeFormat(
                              widget.data.lastedAliveTime),
                          margin: const EdgeInsets.only(top: 5),
                          rightTextStyle: TextStyle(
                            color: checkAlive
                                ? AppColor.statusRunning
                                : AppColor.statusDisable,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                if (widget.data.isOwner == true && widget.isOwner)
                  Row(
                    children: [
                      Expanded(
                        child: CampLineAction(
                          title: 'Đổi hệ thống',
                          leadingIconString: 'assets/images/ic_move_dir.png',
                          iconInRight: true,
                          onTap: showListDirMoving,
                        ),
                      ),
                      Expanded(
                        child: CampLineAction(
                          title: 'Chia sẻ',
                          leadingIconString: 'assets/images/ic_share.png',
                          iconInRight: true,
                          onTap: () {
                            SearchCustomerDialog.show(
                                context, widget.deviceViewModel, (customerId,checkOwner) {
                              Navigator.pop(context);
                              widget.deviceViewModel.shareDevice(
                                widget.data.computerId,
                                widget.deviceViewModel.currentDir.dirId
                                    .toString(),
                                widget.dirViewModel,
                                customerId,
                                checkOwner,
                              );
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: CampLineAction(
                          title: 'Xóa thiết bị',
                          leadingIconString: 'assets/images/ic_close.png',
                          iconInRight: true,
                          onTap: () {
                            widget.deviceViewModel
                                .setCurrentDevice(widget.data);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return PopUpWidget(
                                  icon:
                                      Image.asset('assets/images/ic_error.png'),
                                  title: 'Bạn có chắc muốn xóa thiết bị này',
                                  twoButton: true,
                                  onRightTap: () => Navigator.of(context).pop(),
                                  onLeftTap: () async {
                                    bool checkDelete = await widget
                                        .deviceViewModel
                                        .deleteDevice();
                                    if (checkDelete) {
                                      widget.onDeleteSuccess?.call();
                                      await widget.deviceViewModel
                                          .getDeviceByIdDir(widget
                                              .dirViewModel.currentDir.dirId);
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> showListDirMoving() async {
    List<Dir> lstDir = widget.dirViewModel.listDir;
    String externalDir = 'Thiết bị ngoài';

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void filterBrands(String keyword) {
              setState(() {
                lstDir = widget.dirViewModel.listDir
                    .where((dir) => (dir.dirName ?? '')
                        .toLowerCase()
                        .contains(keyword.toLowerCase()))
                    .toList();
              });
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: filterBrands,
                    decoration: InputDecoration(
                      labelText: 'Tìm kiếm',
                      labelStyle:
                          TextStyle(color: context.textTheme.bodyLarge!.color),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: lstDir.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= lstDir.length) {
                        return widget.dirId == -1
                            ? const SizedBox()
                            : ListTile(
                                title: Text(externalDir),
                                onTap: () async {
                                  Navigator.of(context).pop();

                                  Device dv = widget.data;
                                  dv.idDir = '0';
                                  bool checkMoved = await widget.deviceViewModel
                                      .updateDevice(dv);

                                  if (checkMoved && context.mounted) {
                                    widget.onMovedSuccess?.call(dv);

                                    showPopupSingleButton(
                                      title:
                                          'Đã chuyển thiết bị sang hệ thống $externalDir thành công',
                                      context: context,
                                    );
                                  }
                                },
                              );
                      }

                      final dir = lstDir[index];
                      return widget.dirId == -1 ||
                              dir.dirId != widget.dirViewModel.currentDir.dirId
                          ? ListTile(
                              title: Text(dir.dirName ?? ''),
                              onTap: () async {
                                Navigator.of(context).pop();

                                Device dv = widget.data;
                                dv.idDir = dir.dirId.toString();
                                bool checkMoved = await widget.deviceViewModel
                                    .updateDevice(dv);

                                if (checkMoved && context.mounted) {
                                  widget.onMovedSuccess?.call(dv);

                                  showPopupSingleButton(
                                    title:
                                        'Đã chuyển thiết bị sang hệ thống ${dir.dirName} thành công',
                                    context: context,
                                  );
                                }
                              },
                            )
                          : const SizedBox();
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
