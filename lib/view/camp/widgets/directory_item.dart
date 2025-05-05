import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';
import '../../../models/device/device_model.dart';
import '../../../models/dir/dir_model.dart';
import 'device_item.dart';

class DirectoryItem extends StatefulWidget {
  final Dir dir;
  final ExpandableController? controller;
  final List<Device> deviceList;
  final List<String?> computerId;
  final bool isOwner;
  final ValueChanged<String?>? onDeviceTap;
  final Function(ExpandableController?)? onChangeStateController;

  const DirectoryItem({
    super.key,
    required this.dir,
    required this.deviceList,
    required this.computerId,
    this.controller,
    this.isOwner = false,
    this.onDeviceTap,
    this.onChangeStateController,
  });

  @override
  State<DirectoryItem> createState() => _DirectoryItemState();
}

class _DirectoryItemState extends State<DirectoryItem> {
  @override
  void initState() {
    widget.controller?.addListener(_controllerChangeValue);

    super.initState();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerChangeValue);

    super.dispose();
  }

  void _controllerChangeValue() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpandablePanel(
          controller: widget.controller,
          theme: const ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            hasIcon: false,
            tapHeaderToExpand: false,
          ),
          header: _collapsedWidget(),
          collapsed: const SizedBox(),
          expanded: ListView.builder(
            itemCount: widget.deviceList.length,
            padding: const EdgeInsets.only(left: 10),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return DeviceItem(
                data: widget.deviceList[index],
                computerId: widget.computerId,
                onDeviceTap: widget.onDeviceTap,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _collapsedWidget() {
    return Container(
      decoration: const BoxDecoration(color: AppColor.bgDir),
      margin: const EdgeInsets.only(top: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.deviceList.isNotEmpty
              ? () => widget.onChangeStateController?.call(widget.controller)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Image.asset(
                    widget.isOwner
                        ? 'assets/images/img_folder_owner.png'
                        : 'assets/images/img_folder_share.png',
                    height: 30,
                    width: 30,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.dir.dirName ?? '',
                    style: const TextStyle(
                      color: AppColor.navUnSelect,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (widget.deviceList.isNotEmpty)
                  ExpandableIcon(
                    theme: const ExpandableThemeData(
                      expandIcon: Icons.keyboard_arrow_down_outlined,
                      collapseIcon: Icons.keyboard_arrow_up_outlined,
                      iconColor: Colors.black,
                      iconSize: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
