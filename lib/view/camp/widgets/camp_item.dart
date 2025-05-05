import 'package:flutter/material.dart';

import '../../../app/utils.dart';
import '../../../constants/app_color.dart';
import '../../../models/camp/camp_model.dart';
import '../../../view/camp/widgets/camp_line_action.dart';

class CampItem extends StatelessWidget {
  final CampModel data;
  final bool removeMode;
  final Set<String?>? campSelected;
  final ValueChanged<CampModel>? onEditTap;
  final ValueChanged<CampModel>? onCloningTap;
  final ValueChanged<CampModel>? onDeleteTap;
  final ValueChanged<CampModel>? onHistoryTap;
  final Function(CampModel)? onLongPress;

  CampItem({
    super.key,
    required this.data,
    this.removeMode = false,
    this.campSelected,
    this.onHistoryTap,
    this.onEditTap,
    this.onCloningTap,
    this.onDeleteTap,
    this.onLongPress,
  });

  final GlobalKey<PopupMenuButtonState> _menuKey =
      GlobalKey<PopupMenuButtonState>();

  @override
  Widget build(BuildContext context) {
    bool selected =
        removeMode ? campSelected?.contains(data.campaignId) == true : false;

    return Material(
      color: Colors.transparent,
      child: Listener(
        onPointerDown: (PointerEvent event) {
          if (event.buttons == 2 && !removeMode) {
            _menuKey.currentState?.showButtonMenu();
          }
        },
        child: InkWell(
          onTap: () => onEditTap?.call(data),
          onLongPress:
              onLongPress != null ? () => onLongPress!.call(data) : null,
          onDoubleTap:
              onCloningTap != null ? () => onCloningTap?.call(data) : null,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.black,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(text: data.campaignName ?? ''),
                                    TextSpan(
                                      text:
                                          ' (${data.runByDefaultYn == '1' ? 'Thiết lập mặc định' : '${convertTimeString2(data.fromDate)} - ${convertTimeString2(data.toDate)}'})',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Trạng thái: ',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: data.approvedYn == '1'
                                          ? data.status == '1'
                                              ? 'đang chạy'
                                              : 'đã tắt'
                                          : data.approvedYn == '-1'
                                              ? 'Từ chối duyệt'
                                              : 'Chờ duyệt',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: data.approvedYn == '1'
                                            ? data.status == '1'
                                                ? Colors.green
                                                : Colors.red
                                            : data.approvedYn == '-1'
                                                ? Colors.red
                                                : AppColor.appBarEnd,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (!removeMode)
                          PopupMenuButton(
                            key: _menuKey,
                            onSelected: onMenuTaped,
                            tooltip: 'Tùy chọn',
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem(
                                  value: 0,
                                  child: CampLineAction(
                                    title: 'Lịch sử',
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    leadingIconString:
                                        'assets/images/ic_history.png',
                                  ),
                                ),
                                if (onEditTap != null)
                                  const PopupMenuItem(
                                    value: 1,
                                    child: CampLineAction(
                                      title: 'Sửa',
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      leadingIconString:
                                          'assets/images/ic_pensil.png',
                                    ),
                                  ),
                                if (onCloningTap != null)
                                  const PopupMenuItem(
                                    value: 2,
                                    child: CampLineAction(
                                      title: 'Nhân bản',
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      leadingIconString:
                                          'assets/images/ic_cloning.png',
                                    ),
                                  ),
                                if (onDeleteTap != null)
                                  const PopupMenuItem(
                                    value: 3,
                                    child: CampLineAction(
                                      title: 'Xóa',
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      leadingIconString:
                                          'assets/images/ic_recycle_bin.png',
                                    ),
                                  ),
                              ];
                            },
                            icon: const Icon(Icons.menu,
                                size: 20, color: AppColor.black),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 0.5),
                ],
              ),
              if (selected)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColor.white,
                    ),
                    child: const Icon(
                      Icons.check_circle_sharp,
                      color: AppColor.navSelected,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void onMenuTaped(int value) {
    switch (value) {
      case 0:
        onHistoryTap?.call(data);
        break;
      case 1:
        onEditTap?.call(data);
        break;
      case 2:
        onCloningTap?.call(data);
        break;
      case 3:
        onDeleteTap?.call(data);
        break;
      default:
        break;
    }
  }
}
