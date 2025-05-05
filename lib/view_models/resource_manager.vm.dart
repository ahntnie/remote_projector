import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../app/app.locator.dart';
import '../app/app.router.dart';
import '../app/compare.dart';
import '../app/utils.dart';
import '../constants/app_api.dart';
import '../models/packet/my_packet_model.dart';
import '../models/resource/resource_model.dart';
import '../models/resource/resource_picker_model.dart';
import '../models/resource/sort_type.dart';
import '../models/response/response_result.dart';
import '../requests/packet/packet.request.dart';
import '../requests/resource/resource.request.dart';
import '../widget/pop_up.dart';

class ResourceMangerViewModel extends BaseViewModel {
  ResourceMangerViewModel({required this.context});

  BuildContext context;
  ValueChanged<List<String>>? _onChoseSuccess;
  bool _isSingle = true;

  final ResourceRequest _resourceRequest = ResourceRequest();
  final PacketRequest _packetRequest = PacketRequest();
  final ImagePicker _picker = ImagePicker();
  final _navigationService = appLocator<NavigationService>();

  bool _folderIsExist = false;

  int _totalSizeFolder = 0;
  int get totalSizeFolder => _totalSizeFolder;

  bool _draggingToAdd = false;
  bool get draggingToAdd => _draggingToAdd;

  bool _draggingToUpload = false;
  bool get draggingToUpload => _draggingToUpload;

  bool _removeResourceMode = false;
  bool get removeResourceMode =>
      _removeResourceMode && _listUrlSelected.isNotEmpty;

  bool _choseMoreResourceMode = false;
  bool get choseMoreResourceMode =>
      _choseMoreResourceMode && _listUrlSelected.isNotEmpty;

  MyPacketModel? _myPacketValid;
  get myPacketValid => _myPacketValid;

  final List<ResourcePickerModel> _listFilePicker = [];
  List<ResourcePickerModel> get listFilePicker => _listFilePicker;

  final List<ResourceModel> _listResource = [];
  List<ResourceModel> get listResource => _listResource;

  final Set<String?> _listUrlSelected = {};
  Set<String?> get listUrlSelected => _listUrlSelected;

  final List<String?> _fileNameUploaded = [];

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  SortType _sortType = SortType.defaultSortType;
  SortType get sortType => _sortType;

  int _sizeFileUploading = 0;
  final Set<String?> _setNameUploading = {};

  Future<void> initialise() async {
    setBusy(true);

    _folderIsExist = await _resourceRequest.checkDirectoryExist();
    if (_folderIsExist) {
      await _getResourceFileFromFolder();
      await _handleGetTotalSizeFolder();
    }

    setBusy(false);
  }

  @override
  void dispose() {
    for (ResourcePickerModel pickerModel in _listFilePicker) {
      if (pickerModel.cancelToken != null) {
        _handleCancelUploadFileToFolderResource(
          pickerModel,
          requiredCancel: true,
        );
      }
    }

    _listFilePicker.clear();
    _listResource.clear();

    super.dispose();
  }

  int getSizeResourceSelected() {
    int size = 0;

    for (var item in _listResource) {
      if (_listUrlSelected.contains(item.path)) {
        int fileSize = item.fileSize ?? 0;
        size += fileSize;
      }
    }

    return size;
  }

  void onChangeSortType({SortType? type}) {
    if (type == null || type.type != _sortType.type) {
      _sortType = type ?? _sortType;

      switch (_sortType.type) {
        case SortEnum.nameAscending:
          _listResource.sort(fileNameAscendingCompare);
          break;
        case SortEnum.nameDescending:
          _listResource.sort(fileNameDescendingCompare);
          break;
        case SortEnum.sizeAscending:
          _listResource.sort((a, b) {
            int fileSizeA = a.fileSize ?? 0;
            int fileSizeB = b.fileSize ?? 0;
            return fileSizeA.compareTo(fileSizeB);
          });
          break;
        case SortEnum.sizeDescending:
          _listResource.sort((a, b) {
            int fileSizeA = a.fileSize ?? 0;
            int fileSizeB = b.fileSize ?? 0;
            return fileSizeB.compareTo(fileSizeA);
          });
          break;
        case SortEnum.creationTimeAscending:
          _listResource.sort((a, b) {
            DateTime? timeA = stringToFullDateTime(a.creationTime);
            DateTime? timeB = stringToFullDateTime(b.creationTime);

            if (timeA == null && timeB == null) {
              return 0;
            } else if (timeA == null) {
              return -1;
            } else if (timeB == null) {
              return 1;
            } else {
              return timeA.compareTo(timeB);
            }
          });
          break;
        case SortEnum.creationTimeDescending:
          _listResource.sort((a, b) {
            DateTime? timeA = stringToFullDateTime(a.creationTime);
            DateTime? timeB = stringToFullDateTime(b.creationTime);

            if (timeA == null && timeB == null) {
              return 0;
            } else if (timeB == null) {
              return -1;
            } else if (timeA == null) {
              return 1;
            } else {
              return timeB.compareTo(timeA);
            }
          });
          break;
        default:
          break;
      }

      notifyListeners();
    }
  }

  void onCancelRemoveResourceMode() {
    _listUrlSelected.clear();
    _toggleRemoveResourceMode(mode: false);
    _toggleChoseMoreResourceMode(mode: false);
    notifyListeners();
  }

  void onItemTapedInRemoveMode(String? url) {
    _listUrlSelected.contains(url)
        ? removeItemFromListSelected(url)
        : addItemToUrlSelected(url);
  }

  void onItemTapedInChoseMoreMode(String? url) {
    _listUrlSelected.contains(url)
        ? removeItemFromListSelectedChoseMore(url)
        : addItemToUrlSelectedChoseMore(url);
  }

  void addItemToUrlSelected(String? url) {
    _listUrlSelected.add(url);
    _toggleRemoveResourceMode(mode: true);
  }

  void removeItemFromListSelected(String? url) {
    _listUrlSelected.remove(url);
    _toggleRemoveResourceMode(mode: _listUrlSelected.isNotEmpty);
  }

  void addItemToUrlSelectedChoseMore(String? url) {
    _listUrlSelected.add(url);
    _toggleChoseMoreResourceMode(mode: true);
  }

  void removeItemFromListSelectedChoseMore(String? url) {
    _listUrlSelected.remove(url);
    _toggleChoseMoreResourceMode(mode: _listUrlSelected.isNotEmpty);
  }

  void changeDraggingToAdd(bool drag) {
    _draggingToAdd = drag;
    notifyListeners();
  }

  void changeDraggingToUpload(bool drag) {
    _draggingToUpload = drag;
    notifyListeners();
  }

  void setChoseSuccess(
      ValueChanged<List<String>>? onChoseSuccess, bool single) {
    _onChoseSuccess = onChoseSuccess;
    _isSingle = single;
  }

  Future<void> refreshResourceFileFromFolder() async {
    if (_folderIsExist) {
      setBusy(true);
      await _getResourceFileFromFolder();
      await _handleGetTotalSizeFolder();
      setBusy(false);
    }
  }

  void _handleUpdateUrlSelected() {
    if (_listUrlSelected.isNotEmpty) {
      Set<String?> tempSet = {};
      Set<String?> allUrl = _listResource.map((e) => e.path).toSet();

      for (String? url in _listUrlSelected) {
        if (allUrl.contains(url)) {
          tempSet.add(url);
        }
      }

      _listUrlSelected.clear();
      _listUrlSelected.addAll(tempSet);
    }
  }

  Future<void> _refreshMyPacket() async {
    List<MyPacketModel> list = await _packetRequest.getPacketPurchased();
    _myPacketValid = list.where((packet) {
      if (packet.deleted != 'y') {
        DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
        DateTime? validDate = packet.validDate != null
            ? DateTime.tryParse(packet.validDate!)
            : null;
        DateTime? expireDate = packet.expireDate != null
            ? DateTime.tryParse(packet.expireDate!)
            : null;

        if (validDate == null || expireDate == null) return false;

        return validDate.isBefore(now) && expireDate.isAfter(now);
      } else {
        return false;
      }
    }).firstOrNull;
  }

  Future<void> _getResourceFileFromFolder() async {
    List<ResourceModel> listPath =
        await _resourceRequest.getFilesFromDirectoryResource();
    _listResource.clear();
    _listResource.addAll(listPath);
    _handleUpdateUrlSelected();
    onChangeSortType();
  }

  Future<void> onUploadDragFile(List<String> paths) async {
    if (paths.isNotEmpty) {
      List<ResourcePickerModel> tempList = [];
      tempList.addAll(_listFilePicker);

      _listFilePicker.clear();
      await onAddDragFile(paths);

      await onUploadAllFileTaped(showError: false);
      tempList.addAll(_listFilePicker);
      _listFilePicker.clear();
      _listFilePicker.addAll(tempList);
    }
  }

  Future<void> onAddDragFile(List<String> paths) async {
    if (paths.isNotEmpty) {
      int now = DateTime.now().millisecondsSinceEpoch;
      if (_onChoseSuccess != null && _isSingle) {
        XFile xFile = XFile(paths[0]);
        int fileSize = await xFile.length();
        _listFilePicker.clear();
        _listFilePicker.add(ResourcePickerModel(
          file: xFile,
          type: isImageUrl(paths[0]) ? 'image' : 'video',
          fileSize: fileSize,
          id: now,
        ));
      } else {
        for (var path in paths) {
          if (!_listFilePicker.any((item) => item.file?.path == path)) {
            XFile xFile = XFile(path);
            int fileSize = await xFile.length();
            _listFilePicker.add(ResourcePickerModel(
              file: xFile,
              type: isImageUrl(path) ? 'image' : 'video',
              fileSize: fileSize,
              id: now,
            ));
            now += 1;
          }
        }
      }
      notifyListeners();
    }
  }

  Future<void> onAddVideoFromStorageTaped() async {
    final XFile? file = await _picker.pickMedia();
    _updateMediaPicker(file);
  }

  Future<void> onAddImagesFromStorageTaped() async {
    List<XFile> files = [];

    if (_onChoseSuccess == null) {
      files = await _picker.pickMultiImage();
    } else {
      XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        files.add(file);
      }
    }

    _updateImagesPicker(files);
  }

  Future<void> onUploadSingleFileTaped(ResourcePickerModel filePicker) async {
    await refreshResourceFileFromFolder();
    await _refreshMyPacket();

    if (filePicker.cancelToken == null) {
      int limitCapacity =
          int.tryParse(_myPacketValid?.limitCapacity ?? '0') ?? 0;

      if ((_totalSizeFolder + _sizeFileUploading + filePicker.fileSize) >
              limitCapacity &&
          context.mounted) {
        showErrorString(
          error:
              'Đã đạt giới hạn dung lượng tài nguyên được tải lên, vui lòng xóa tài nguyên hoặc nâng cấp gói cước',
          context: context,
        );
      } else {
        if (_checkFileNameDuplicate(filePicker) ||
            _setNameUploading.contains(
                filePicker.fileNameReplace ?? filePicker.file?.name)) {
          bool errorChangeFileName = _getUniqueFileName(filePicker);
          if (errorChangeFileName && context.mounted) {
            showErrorString(
              error:
                  'Tên file bị trùng, vui lòng xóa tài nguyên có sẵn hoặc đổi tên file đã chọn',
              context: context,
            );
          } else {
            _handleUploadFileToFolderResource(filePicker, showPopup: true);
          }
        } else {
          _handleUploadFileToFolderResource(filePicker, showPopup: true);
        }
      }
    } else {
      _handleCancelUploadFileToFolderResource(filePicker);
    }
  }

  Future<void> onUploadAllFileTaped({bool showError = true}) async {
    var (duplicate, overLimit) = await _handleUploadAllFile();

    if (overLimit) {
      showErrorString(
        error:
            'Đã đạt giới hạn dung lượng tài nguyên được tải lên, vui lòng xóa tài nguyên hoặc nâng cấp gói cước',
        context: context,
      );
    } else {
      if (showError && context.mounted && duplicate) {
        showErrorString(
          error:
              'Có lỗi xảy ra đối với một số files, hãy thử tải lên lại chúng sau',
          context: context,
        );
      }
    }
    await _handleGetTotalSizeFolder();
  }

  void onDeleteFileResourceSelected() {
    showPopupTwoButton(
      title: 'Bạn có chắc chắn xóa những files này?',
      context: context,
      isError: true,
      onLeftTap: _handleDeleteFileResourceSelected,
    );
  }

  void onChoseMoreSuccess() {
    List<String> list = [];

    for (String? path in _listUrlSelected) {
      if (path != null) {
        list.add(path.replaceFirst('.', Api.hostApi));
      }
    }

    _onChoseSuccess?.call(list);
    _navigationService.back();
  }

  void onSelectAllFileResource() {
    if (_listUrlSelected.length >= _listResource.length) {
      _listUrlSelected.clear();
    } else {
      _listUrlSelected.addAll(_listResource.map((e) => e.path));
    }
    notifyListeners();
  }

  void onDeleteFileResourceTaped(String? fileName) {
    if (fileName != null) {
      showPopupTwoButton(
        title: 'Bạn có chắc chắn xóa file này?',
        context: context,
        isError: true,
        onLeftTap: () => _handleDeleteFileResource(fileName),
      );
    }
  }

  void onDeleteFilePickerTaped(int id) {
    _listFilePicker.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void toReviewPage(String path, int videoType, bool isImage) {
    _navigationService.navigateToReviewVideoPage(
      urlFile: path,
      videoType: videoType,
    );
  }

  void setIsUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  void _toggleRemoveResourceMode({bool? mode}) {
    _removeResourceMode = mode ?? !_removeResourceMode;
    notifyListeners();
  }

  void _toggleChoseMoreResourceMode({bool? mode}) {
    _choseMoreResourceMode = mode ?? !_choseMoreResourceMode;
    notifyListeners();
  }

  /// return true when at least 1 file error
  Future<(bool, bool)> _handleUploadAllFile() async {
    int duplicationCount = 0;
    int overLimitCapacityCount = 0;
    _fileNameUploaded.clear();
    await refreshResourceFileFromFolder();
    await _refreshMyPacket();

    int limitCapacity = int.tryParse(_myPacketValid?.limitCapacity ?? '0') ?? 0;
    for (var item in _listFilePicker) {
      if (item.cancelToken == null) {
        if ((_totalSizeFolder + _sizeFileUploading + item.fileSize) >
            limitCapacity) {
          overLimitCapacityCount += 1;
        } else {
          if (!_checkFileNameDuplicate(item) &&
              !_setNameUploading
                  .contains(item.fileNameReplace ?? item.file?.name)) {
            _handleUploadFileToFolderResource(item);
            _setNameUploading.add(item.fileNameReplace ?? item.file?.name);
          } else {
            bool errorChangeFileName =
                _getUniqueFileName(item, nameTemp: _setNameUploading);
            if (errorChangeFileName) {
              duplicationCount += 1;
            } else {
              _handleUploadFileToFolderResource(item);
              _setNameUploading
                  .add(item.fileNameReplace ?? item.fileNameReplace);
            }
          }
        }
      }
    }

    return (duplicationCount > 0, overLimitCapacityCount > 0);
  }

  bool _getUniqueFileName(ResourcePickerModel item,
      {Set<String?> nameTemp = const {}}) {
    String fileName = item.file?.name ?? '';
    String baseName = fileName;
    String extension = '';

    if (fileName.contains('.')) {
      int lastDotIndex = fileName.lastIndexOf('.');
      baseName = fileName.substring(0, lastDotIndex);
      extension = fileName.substring(lastDotIndex);
    }

    int counter = 1;
    String uniqueName = fileName;
    item.fileNameReplace = uniqueName;

    while ((_checkFileNameDuplicate(item) || nameTemp.contains(uniqueName)) &&
        counter < 1000) {
      uniqueName = '$baseName ($counter)$extension';
      item.fileNameReplace = uniqueName;
      counter++;
    }

    bool isDuplicate =
        _checkFileNameDuplicate(item) || nameTemp.contains(uniqueName);

    if (isDuplicate) item.fileNameReplace = null;

    return isDuplicate;
  }

  Future<void> _handleGetTotalSizeFolder() async {
    _totalSizeFolder = await _resourceRequest.getSizeOfDirectoryResource();
    notifyListeners();
  }

  Future<void> _handleDeleteFileResource(String fileName) async {
    switch (await _resourceRequest.deleteFileFromDirectoryResource(fileName)) {
      case ResultSuccess success:
        if (success.value) {
          _onDeleteFileResourceSuccess(fileName);
        }
        break;
      case ResultError error:
        showResultError(context: context, error: error);
        break;
    }
  }

  Future<void> _handleDeleteFileResourceSelected() async {
    setBusy(true);

    for (var url in _listUrlSelected) {
      String fileName = basename(url ?? '');
      _setNameUploading.remove(fileName);
      await _resourceRequest.deleteFileFromDirectoryResource(fileName);
    }

    onCancelRemoveResourceMode();
    await _getResourceFileFromFolder();
    await _handleGetTotalSizeFolder();

    setBusy(false);
  }

  void _onDeleteFileResourceSuccess(String fileName) {
    int index = _listResource.indexWhere((model) => model.name == fileName);

    if (index > -1) {
      _listResource.removeAt(index);
      _setNameUploading.remove(fileName);
      notifyListeners();
    }
    _handleGetTotalSizeFolder();

    showPopupSingleButton(
      title: 'Đã xóa thành công $fileName',
      context: context,
    );
  }

  Future<void> _handleCancelUploadFileToFolderResource(
      ResourcePickerModel filePicker,
      {bool requiredCancel = false}) async {
    if (filePicker.progress < 95 || requiredCancel) {
      filePicker.cancelToken?.cancel();
      filePicker.cancelToken = null;
      filePicker.progress = 0;

      _updateFileSizeUploading(-filePicker.fileSize);

      File file = File(filePicker.file!.path);
      String fileName = basename(filePicker.fileNameReplace ?? file.path);
      int fileLength = await file.length();
      int maxLengthUpload = 200 * 1024 * 1024;
      _setNameUploading.remove(fileName);

      if (fileLength > maxLengthUpload) {
        await _resourceRequest.cancelUploadResource(fileName);
      }
    }

    _setBusyWhenActionDone(idNotCheck: filePicker.id);

    if (!isUploading) {
      await Future.delayed(const Duration(seconds: 1));
      await _handleGetTotalSizeFolder();
    }
  }

  void _setBusyWhenActionDone({int? idNotCheck}) {
    int listUploading = 0;
    for (var item in _listFilePicker) {
      if (item.id != idNotCheck) {
        if (item.cancelToken != null) {
          listUploading += 1;
        }
      }
    }
    setIsUploading(listUploading != 0);
  }

  Future<void> _handleUploadFileToFolderResource(ResourcePickerModel filePicker,
      {bool showPopup = false}) async {
    if (!_folderIsExist) {
      bool uploadNext = await _resourceRequest.createDirectory();
      _folderIsExist = uploadNext;
    }

    if (_folderIsExist) {
      setIsUploading(true);
      String? fileName = filePicker.fileNameReplace ?? filePicker.file?.name;
      _sizeFileUploading += filePicker.fileSize;
      _setNameUploading.add(fileName);
      ResponseResult<ResourceModel?> uploadResponse =
          await _resourceRequest.uploadFile(filePicker, (onProgress) {
        filePicker.progress = onProgress;
        notifyListeners();
      });

      switch (uploadResponse) {
        case ResultSuccess success:
          if (success.value != null) {
            ResourceModel resource = success.value;
            _fileNameUploaded.add(resource.path);
            _onUploadFileSuccess(filePicker, resource,
                _onChoseSuccess != null ? false : showPopup);
          }
          break;
        case ResultError error:
          filePicker.cancelToken = null;
          filePicker.progress = 0;
          _updateFileSizeUploading(-filePicker.fileSize);
          _setNameUploading.remove(fileName);

          if (showPopup && context.mounted) {
            showResultError(context: context, error: error);
          }
          break;
      }

      _setBusyWhenActionDone(idNotCheck: filePicker.id);

      if (!_isUploading) {
        if (_onChoseSuccess != null) {
          List<String> list = [];

          for (String? path in _fileNameUploaded) {
            if (path != null) {
              list.add(path.replaceFirst('.', Api.hostApi));
            }
          }
          _onChoseSuccess!.call(list);
          _navigationService.back();
        }
      }

      _handleGetTotalSizeFolder();
    }
  }

  void _onUploadFileSuccess(
      ResourcePickerModel filePicker, ResourceModel resource, bool showPopup) {
    int index = _listFilePicker.indexOf(filePicker);

    if (index > -1) {
      _updateFileSizeUploading(-filePicker.fileSize);
      _listFilePicker.removeAt(index);
      notifyListeners();
    }

    _listResource.add(resource);
    onChangeSortType();

    if (showPopup) {
      showPopupSingleButton(
        title: 'Đã tải lên ${resource.name} thành công',
        context: context,
      );
    }
  }

  void _updateFileSizeUploading(int value) {
    _sizeFileUploading += value;
    if (_sizeFileUploading < 0) _sizeFileUploading = 0;
  }

  Future<void> _updateMediaPicker(XFile? file) async {
    if (file != null) {
      // Xóa danh sách nếu có callback chọn thành công
      if (_onChoseSuccess != null) {
        _listFilePicker.clear();
      }

      // Kiểm tra xem file đã tồn tại trong danh sách chưa
      if (!_listFilePicker.any((item) => item.file?.path == file.path)) {
        // Xác định loại file (image hoặc video) dựa trên mimeType
        String mimeType = file.mimeType ?? '';
        String type = mimeType.startsWith('image') ? 'image' : 'video';

        // Nếu mimeType không có, dùng phần mở rộng file để xác định
        if (mimeType.isEmpty) {
          String extension = file.path.split('.').last.toLowerCase();
          type = ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension)
              ? 'image'
              : 'video';
        }

        // Lấy kích thước file
        int fileSize = await file.length();

        // Thêm file vào danh sách
        _listFilePicker.add(ResourcePickerModel(
          file: file,
          type: type,
          fileSize: fileSize,
          id: DateTime.now().millisecondsSinceEpoch,
        ));
      }

      // Thông báo cập nhật giao diện
      notifyListeners();
    }
  }

  Future<void> _updateImagesPicker(List<XFile> files) async {
    if (files.isNotEmpty) {
      int now = DateTime.now().millisecondsSinceEpoch;
      if (_onChoseSuccess != null) {
        int fileSize = await files[0].length();
        _listFilePicker.clear();
        _listFilePicker.add(ResourcePickerModel(
          file: files[0],
          type: 'image',
          fileSize: fileSize,
          id: now,
        ));
      } else {
        for (var file in files) {
          if (!_listFilePicker.any((item) => item.file?.path == file.path)) {
            int fileSize = await file.length();
            _listFilePicker.add(ResourcePickerModel(
              file: file,
              type: 'image',
              fileSize: fileSize,
              id: now,
            ));
            now += 1;
          }
        }
      }
      notifyListeners();
    }
  }

  /// return true when file name duplicated
  bool _checkFileNameDuplicate(ResourcePickerModel filePicker) {
    String? fileName = filePicker.fileNameReplace ?? filePicker.file?.name;
    for (var item in _listResource) {
      if (item.name == fileName) {
        return true;
      }
    }
    return false;
  }
}
