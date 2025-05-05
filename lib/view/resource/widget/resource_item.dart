import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../../../app/utils.dart';
import '../../../constants/app_color.dart';
import '../../../models/resource/resource_model.dart';

class ResourceItem extends StatelessWidget {
  final ResourceModel data;
  final bool fromEditCamp;
  final bool removeMode;
  final bool showIndexSelect;
  final List<String?>? urlSelected;
  final ValueChanged<String?>? onDeleteTap;
  final ValueChanged<ResourceModel>? onCopyTap;
  final Function(String?, bool)? onItemTap;
  final Function(String?)? onItemLongPress;

  const ResourceItem({
    super.key,
    required this.data,
    this.removeMode = false,
    this.showIndexSelect = false,
    this.urlSelected,
    this.fromEditCamp = false,
    this.onDeleteTap,
    this.onCopyTap,
    this.onItemTap,
    this.onItemLongPress,
  });

  @override
  Widget build(BuildContext context) {
    bool selected =
        removeMode ? urlSelected?.contains(data.path) == true : false;
    String type =
        data.fileType?.startsWith('image') == true ? 'image' : 'video';

    return Container(
      height: 60,
      color: selected ? AppColor.navSelected.withOpacity(0.15) : null,
      child: InkWell(
        onTap: () => onItemTap?.call(data.path, type == 'image'),
        onLongPress: onItemLongPress != null
            ? () => onItemLongPress!.call(data.path)
            : null,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/img_$type.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  basenameWithoutExtension(data.name ?? ''),
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.black,
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColor.unSelectedLabel2,
                                  ),
                                  children: [
                                    TextSpan(
                                        text:
                                            '${formatBytes(data.fileSize ?? 0)} - '),
                                    TextSpan(
                                      text: type == 'image' ? 'Ảnh' : 'Video',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  data.path ?? '',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColor.unSelectedLabel2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!removeMode)
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () => onCopyTap?.call(data),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                child: SizedBox(
                                  height: 40,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Center(
                                      child: Text(
                                        fromEditCamp
                                            ? 'Xem trước'
                                            : 'Sao chép\nliên kết',
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColor.unSelectedLabel2,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (!fromEditCamp)
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: AppColor.bgDir,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () =>
                                            onDeleteTap?.call(data.name),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5),
                                        ),
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
                  ),
                ),
                const Divider(height: 0.5, color: AppColor.navSelected),
              ],
            ),
            if (selected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.5),
                    border: Border.all(color: AppColor.white, width: 2),
                    color: AppColor.navSelected,
                  ),
                  alignment: Alignment.center,
                  child: showIndexSelect && urlSelected != null
                      ? Text(
                          '${urlSelected!.indexOf(data.path) + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.white,
                          ),
                        )
                      : const Icon(
                          Icons.check,
                          color: AppColor.white,
                          size: 15,
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
