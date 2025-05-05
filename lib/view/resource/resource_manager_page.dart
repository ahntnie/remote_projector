import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import '../../app/utils.dart';
import '../../constants/app_api.dart';
import '../../constants/app_color.dart';
import '../../models/resource/sort_type.dart';
import '../../view_models/resource_manager.vm.dart';
import '../../widget/base_page.dart';
import 'widget/file_picker_item.dart';
import 'widget/resource_item.dart';
import 'widget/sort_type_item.dart';

class ResourceManagerPage extends StatefulWidget {
  final ValueChanged<List<String>>? onChoseSuccess;
  final bool isSingle;
  final List<String>? pathDragged;

  const ResourceManagerPage({
    super.key,
    this.onChoseSuccess,
    this.isSingle = true,
    this.pathDragged,
  });

  @override
  State<ResourceManagerPage> createState() => _ResourceManagerPageState();
}

class _ResourceManagerPageState extends State<ResourceManagerPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ResourceMangerViewModel>.reactive(
      viewModelBuilder: () => ResourceMangerViewModel(context: context),
      onViewModelReady: (viewModel) async {
        viewModel.setChoseSuccess(widget.onChoseSuccess, widget.isSingle);
        await viewModel.initialise();
        if (widget.pathDragged != null && widget.pathDragged!.isNotEmpty) {
          viewModel.onUploadDragFile(
              widget.pathDragged!.where((e) => isSupportedFile(e)).toList());
        }
      },
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: !viewModel.isUploading,
          child: BasePage(
            isBusy: viewModel.isBusy,
            showAppBar: true,
            showLeadingAction: true,
            title: widget.onChoseSuccess != null
                ? 'Chọn video'
                : 'Quản lý tài nguyên'.toUpperCase(),
            onBackPressed: () {
              if (!viewModel.isUploading) {
                Navigator.pop(context);
              }
            },
            body: ScreenTypeLayout.builder(
              mobile: (BuildContext context) => _buildViewMobile(viewModel),
              desktop: (BuildContext context) => _buildViewWindows(viewModel),
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewMobile(ResourceMangerViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: _buildMyFilePickerMobile(viewModel),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: _buildFileResourceUploaded(viewModel),
          ),
        ),
      ],
    );
  }

  Widget _buildViewWindows(ResourceMangerViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: _buildMyFilePickerWindows(viewModel),
          ),
        ),
        Container(
          color: AppColor.navUnSelect,
          height: double.infinity,
          width: 0.5,
          margin: const EdgeInsets.symmetric(vertical: 20),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: _buildFileResourceUploaded(viewModel),
          ),
        ),
      ],
    );
  }

  Widget _buildMyFilePickerMobile(ResourceMangerViewModel viewModel) {
    return DropTarget(
      onDragDone: (detail) {
        viewModel.onAddDragFile(detail.files
            .map((e) => e.path)
            .where((e) => isSupportedFile(e))
            .toList());
      },
      onDragEntered: (detail) {
        viewModel.changeDraggingToAdd(true);
      },
      onDragExited: (detail) {
        viewModel.changeDraggingToAdd(false);
      },
      child: SizedBox(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewModel.listFilePicker.isNotEmpty)
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColor.bgDir,
                    ),
                    height: 40,
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'File đã chọn',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (viewModel.listFilePicker.length > 1 &&
                            viewModel.listFilePicker
                                .where((item) => item.cancelToken != null)
                                .isEmpty)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: viewModel.onUploadAllFileTaped,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Tải lên tất cả',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColor.unSelectedLabel2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Image.asset(
                                        'assets/images/ic_upload.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else if (viewModel.listFilePicker
                            .where((item) => item.cancelToken != null)
                            .isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Đang tải lên',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.bgDir, width: 2),
                  ),
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              (MediaQuery.of(context).size.height > 13 * 60
                                      ? 3
                                      : 2) *
                                  60,
                        ),
                        child: ListView.builder(
                          itemCount: viewModel.listFilePicker.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return FilePickerItem(
                              data: viewModel.listFilePicker[index],
                              onDeleteTap: viewModel.onDeleteFilePickerTaped,
                              onUploadTap: viewModel.onUploadSingleFileTaped,
                              onItemTap: (path, isImage) {
                                if (path != null) {
                                  viewModel.toReviewPage(path, 1, isImage);
                                }
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: InkWell(
                          onTap: viewModel.onAddVideoFromStorageTaped,
                          child: const Center(
                            child: Text(
                              'Chọn thêm video',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.unSelectedLabel2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (viewModel.draggingToAdd || viewModel.draggingToUpload)
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
                  height: 40.0 +
                      (viewModel.listFilePicker.isNotEmpty ? 40 : 0) +
                      (viewModel.listFilePicker.length * 60).clamp(
                          0,
                          (MediaQuery.of(context).size.height > 13 * 60
                                  ? 3
                                  : 2) *
                              60),
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

  Widget _buildMyFilePickerWindows(ResourceMangerViewModel viewModel) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(color: AppColor.bgDir),
            height: 40,
            child: Row(
              children: [
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'File đã chọn',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                if (viewModel.listFilePicker.length > 1 &&
                    viewModel.listFilePicker
                        .where((item) => item.cancelToken != null)
                        .isEmpty)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: viewModel.onUploadAllFileTaped,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const Text(
                              'Tải lên tất cả',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.unSelectedLabel2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              padding: const EdgeInsets.only(left: 5),
                              child: Image.asset(
                                'assets/images/ic_upload.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (viewModel.listFilePicker
                    .where((item) => item.cancelToken != null)
                    .isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Đang tải lên',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.bgDir, width: 2),
              ),
              height: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: InkWell(
                      onTap: viewModel.onAddVideoFromStorageTaped,
                      child: const Center(
                        child: Text(
                          'Chọn thêm video',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.unSelectedLabel2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: DropTarget(
                      onDragDone: (detail) {
                        viewModel.onAddDragFile(detail.files
                            .map((e) => e.path)
                            .where((e) => isSupportedFile(e))
                            .toList());
                      },
                      onDragEntered: (detail) {
                        viewModel.changeDraggingToAdd(true);
                      },
                      onDragExited: (detail) {
                        viewModel.changeDraggingToAdd(false);
                      },
                      child: Stack(
                        children: [
                          ListView.builder(
                            itemCount: viewModel.listFilePicker.length,
                            itemBuilder: (context, index) {
                              return FilePickerItem(
                                data: viewModel.listFilePicker[index],
                                onDeleteTap: viewModel.onDeleteFilePickerTaped,
                                onUploadTap: viewModel.onUploadSingleFileTaped,
                                onItemTap: (path, isImage) {
                                  if (path != null) {
                                    viewModel.toReviewPage(path, 1, isImage);
                                  }
                                },
                              );
                            },
                          ),
                          if (viewModel.draggingToAdd ||
                              viewModel.draggingToUpload)
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileResourceUploaded(ResourceMangerViewModel viewModel) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(color: AppColor.bgDir),
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              viewModel.removeResourceMode || viewModel.choseMoreResourceMode
                  ? IconButton(
                      onPressed: viewModel.onCancelRemoveResourceMode,
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: 'Hủy',
                      color: AppColor.navUnSelect,
                      constraints:
                          const BoxConstraints(minWidth: 30, minHeight: 30),
                    )
                  : Image.asset(
                      'assets/images/img_folder_owner.png',
                      height: 30,
                      width: 30,
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  viewModel.removeResourceMode ||
                          viewModel.choseMoreResourceMode
                      ? 'Đã chọn ${viewModel.listUrlSelected.length}'
                      : 'Thư mục của tôi',
                  style: const TextStyle(
                    color: AppColor.navUnSelect,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                formatBytes(viewModel.removeResourceMode ||
                        viewModel.choseMoreResourceMode
                    ? viewModel.getSizeResourceSelected()
                    : viewModel.totalSizeFolder),
                style:
                    const TextStyle(color: AppColor.navUnSelect, fontSize: 13),
              ),
              if (!(viewModel.removeResourceMode ||
                  viewModel.choseMoreResourceMode))
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: viewModel.isUploading
                        ? null
                        : () => _showModalSort(viewModel),
                    icon: const Icon(Icons.swap_vert_sharp, size: 20),
                    tooltip: 'Sắp xếp',
                    color: AppColor.navUnSelect,
                    constraints:
                        const BoxConstraints(minWidth: 30, minHeight: 30),
                  ),
                ),
              if (!isMobile &&
                  !(viewModel.removeResourceMode ||
                      viewModel.choseMoreResourceMode))
                IconButton(
                  onPressed: viewModel.isUploading
                      ? null
                      : viewModel.refreshResourceFileFromFolder,
                  icon: const Icon(Icons.refresh_outlined, size: 20),
                  tooltip: 'Làm mới tài nguyên',
                  color: AppColor.navUnSelect,
                  constraints:
                      const BoxConstraints(minWidth: 30, minHeight: 30),
                ),
              if (viewModel.removeResourceMode)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
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
                        onTap: viewModel.onDeleteFileResourceSelected,
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
              if (viewModel.choseMoreResourceMode)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    width: 70,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: viewModel.onChoseMoreSuccess,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        child: const Center(
                          child: Text(
                            'Xác nhận',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (viewModel.removeResourceMode ||
                  viewModel.choseMoreResourceMode)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    width: 50,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        width: 1,
                        color: viewModel.listUrlSelected.length >=
                                viewModel.listResource.length
                            ? AppColor.navSelected
                            : AppColor.navUnSelect,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: viewModel.onSelectAllFileResource,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        child: Center(
                          child: Text(
                            'Tất cả',
                            style: TextStyle(
                              fontSize: 12,
                              color: viewModel.listUrlSelected.length >=
                                      viewModel.listResource.length
                                  ? AppColor.navSelected
                                  : AppColor.navUnSelect,
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: viewModel.refreshResourceFileFromFolder,
            child: DropTarget(
              onDragDone: (detail) {
                viewModel.onUploadDragFile(detail.files
                    .map((e) => e.path)
                    .where((e) => isSupportedFile(e))
                    .toList());
              },
              onDragEntered: (detail) {
                viewModel.changeDraggingToUpload(true);
              },
              onDragExited: (detail) {
                viewModel.changeDraggingToUpload(false);
              },
              child: Stack(
                children: [
                  ListView.builder(
                    itemCount: viewModel.listResource.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ResourceItem(
                        data: viewModel.listResource[index],
                        fromEditCamp: widget.onChoseSuccess != null,
                        removeMode: viewModel.removeResourceMode ||
                            viewModel.choseMoreResourceMode,
                        urlSelected: viewModel.listUrlSelected.toList(),
                        showIndexSelect:
                            widget.onChoseSuccess != null && !widget.isSingle,
                        onCopyTap: (data) {
                          if (data.path != null) {
                            String realPath =
                                data.path!.replaceFirst('.', Api.hostApi);
                            if (widget.onChoseSuccess != null) {
                              viewModel.toReviewPage(
                                realPath,
                                2,
                                data.fileType == 'image',
                              );
                            } else {
                              copyToClipboard(realPath, context);
                            }
                          }
                        },
                        onDeleteTap: viewModel.isUploading
                            ? null
                            : viewModel.onDeleteFileResourceTaped,
                        onItemTap: (path, isImage) {
                          if (path != null) {
                            String realPath =
                                path.replaceFirst('.', Api.hostApi);
                            if (widget.onChoseSuccess != null) {
                              if (viewModel.choseMoreResourceMode) {
                                viewModel.onItemTapedInChoseMoreMode(path);
                              } else if (!viewModel.isUploading) {
                                widget.onChoseSuccess!.call([realPath]);
                                Navigator.pop(context);
                              }
                            } else if (viewModel.removeResourceMode) {
                              viewModel.onItemTapedInRemoveMode(path);
                            } else {
                              viewModel.toReviewPage(realPath, 2, isImage);
                            }
                          }
                        },
                        onItemLongPress: widget.onChoseSuccess == null &&
                                !viewModel.isUploading
                            ? viewModel.addItemToUrlSelected
                            : !widget.isSingle
                                ? viewModel.addItemToUrlSelectedChoseMore
                                : null,
                      );
                    },
                  ),
                  if (viewModel.draggingToAdd || viewModel.draggingToUpload)
                    DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(5),
                      dashPattern: const [8, 6],
                      color: viewModel.draggingToUpload
                          ? AppColor.navSelected
                          : AppColor.navUnSelect,
                      strokeWidth: 2,
                      child: Container(
                        color: AppColor.white.withOpacity(0.85),
                        child: Container(
                          decoration: BoxDecoration(
                            color: (viewModel.draggingToUpload
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
                                'Tải lên nhanh',
                                style: TextStyle(
                                  color: viewModel.draggingToUpload
                                      ? AppColor.navSelected
                                      : AppColor.navUnSelect,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Thả files vào đây để tải lên ngay',
                                style: TextStyle(
                                  color: viewModel.draggingToUpload
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
          ),
        ),
      ],
    );
  }

  Future<void> _showModalSort(ResourceMangerViewModel viewModel) async {
    double height = MediaQuery.of(context).size.height;
    List<SortType> sortTypes = SortType.defaultSortTypeList();

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.white,
      scrollControlDisabledMaxHeightRatio: 1,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize:
              ((50 * (sortTypes.length + 1) + 33) / height).clamp(0.1, 1),
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 550),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 3,
                        color: AppColor.black,
                      ),
                      Container(
                        height: 50,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: const Text(
                          'Sắp xếp theo',
                          style: TextStyle(color: AppColor.black, fontSize: 14),
                        ),
                      ),
                      ...sortTypes.map((type) {
                        return SortTypeItem(
                          data: type,
                          isSelected: type.type == viewModel.sortType.type,
                          onChanged: (type) {
                            Navigator.of(context).pop();
                            viewModel.onChangeSortType(type: type);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
