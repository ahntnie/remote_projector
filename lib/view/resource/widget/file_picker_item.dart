import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../../../app/utils.dart';
import '../../../constants/app_color.dart';
import '../../../models/resource/resource_picker_model.dart';

class FilePickerItem extends StatelessWidget {
  final ResourcePickerModel data;
  final ValueChanged<int>? onDeleteTap;
  final Function(String?, bool)? onItemTap;
  final ValueChanged<ResourcePickerModel>? onUploadTap;

  const FilePickerItem({
    super.key,
    required this.data,
    this.onDeleteTap,
    this.onItemTap,
    this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: InkWell(
        onTap: () => onItemTap?.call(data.file?.path, data.type == 'image'),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/img_${data.type}.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            basenameWithoutExtension(data.file?.name ?? ''),
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColor.black,
                            ),
                          ),
                          Text(
                            formatBytes(data.fileSize),
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColor.unSelectedLabel2,
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              data.file?.path ?? '',
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
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: data.progress < 1
                          ? () => onUploadTap?.call(data)
                          : null,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          children: [
                            if (data.progress > 0 && data.cancelToken != null)
                              Center(
                                child: SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: CircularProgressIndicator(
                                    value: data.progress,
                                    color: data.progress < 1
                                        ? AppColor.navSelected
                                        : AppColor.navUnSelect,
                                  ),
                                ),
                              ),
                            if (data.cancelToken == null)
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/ic_upload.png',
                                      width: 10,
                                      height: 10,
                                    ),
                                    const Text(
                                      'Tải lên',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.unSelectedLabel2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Center(
                                child: Text(
                                  'Hủy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: data.progress < 1
                                        ? AppColor.navSelected
                                        : AppColor.navUnSelect,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (data.cancelToken == null)
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColor.bgDir,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => onDeleteTap?.call(data.id),
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
              ),
            ),
            const Divider(height: 0.5, color: AppColor.navSelected),
          ],
        ),
      ),
    );
  }
}
