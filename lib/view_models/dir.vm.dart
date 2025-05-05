import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:velocity_x/velocity_x.dart';

import '../app/app.locator.dart';
import '../app/app.router.dart';
import '../app/app_sp.dart';
import '../app/app_sp_key.dart';
import '../app/app_string.dart';
import '../app/utils.dart';
import '../constants/app_constants.dart';
import '../models/camp/camp_model.dart';
import '../models/camp/time_run_model.dart';
import '../models/device/device_model.dart';
import '../models/device/device_shared_model.dart';
import '../models/dir/dir_model.dart';
import '../models/dir/dir_shared_model.dart';
import '../models/response/response_result.dart';
import '../models/user/user.dart';
import '../requests/camp/camp.request.dart';
import '../requests/command/command.request.dart';
import '../requests/device/device.request.dart';
import '../requests/dir/dir.request.dart';
import '../view/device/widget/search_customer_dialog.dart';
import '../view_models/device.vm.dart';
import '../widget/pop_up.dart';

class DirViewModel extends BaseViewModel {
  DirViewModel({required this.context});

  BuildContext context;
  final _navigationService = appLocator<NavigationService>();

  final DirRequest _dirRequest = DirRequest();
  final CampRequest _campRequest = CampRequest();
  final DeviceRequest _deviceRequest = DeviceRequest();
  final CommandRequest _commandRequest = CommandRequest();

  late DeviceViewModel deviceViewModel;
  final TextEditingController folderNameController = TextEditingController();
  final TextEditingController changeFolderNameController =
      TextEditingController();

  final FocusNode folderNameFocusNode = FocusNode();
  final FocusNode changeFolderNameFocusNode = FocusNode();

  bool _isEditingFolderName = false;
  bool get isEditingFolderName => _isEditingFolderName;

  bool _isChangeFolderName = false;
  bool get isChangeFolderName => _isChangeFolderName;

  int? _idFolderChangeName;
  int? get idFolderChangeName => _idFolderChangeName;

  int? _currentTab = 0;
  int? get currentTab => _currentTab;

  final List<Dir> _listDir = [];
  List<Dir> get listDir => _listDir;

  final List<Dir> _listShareDir = [];
  List<Dir> get listShareDir => _listShareDir;

  final List<DirSharedModel> _listShareDirByCustomer = [];
  List<DirSharedModel> get listShareDirByCustomer => _listShareDirByCustomer;

  final List<Device> _listSharedDevices = [];
  List<Device> get listSharedDevices => _listSharedDevices;

  final List<DeviceSharedModel> _listSharedDevicesByCustomer = [];
  List<DeviceSharedModel> get listSharedDevicesByCustomer =>
      _listSharedDevicesByCustomer;

  final List<Device> _devices = [];
  List<Device> get devices => _devices;

  final List<Device> _listExternalDevices = [];
  List<Device> get listExternalDevices => _listExternalDevices;

  double _currentSheetSize = 0.5;
  double get currentSheetSize => _currentSheetSize;

  double _folderFraction = 0.5;
  double get folderFraction => _folderFraction;

  CampModel? campDefault;

  final Dir defaultDir = Dir(
    dirId: -1,
    dirName: 'Không có',
    customerId: -1,
    dirType: '',
    createdBy: '-1',
    createdDate: '',
    lastModifyBy: '',
    lastModifyDate: '',
    deleted: '',
    isOwner: true,
  );

  Dir currentDir = Dir(
    dirId: 0,
    dirName: '',
    customerId: 0,
    dirType: '',
    createdBy: '0',
    createdDate: '',
    lastModifyBy: '',
    lastModifyDate: '',
    deleted: '',
  );

  Future<void> initialise() async {
    setBusy(true);

    await getMyDir();
    await getShareDir();
    await getSharedDevices();
    await getSharedDirectoriesByCustomer();
    await getSharedDevicesByCustomer();
    await getExternalDevices();

    setBusy(false);
  }

  @override
  void dispose() {
    folderNameController.dispose();
    changeFolderNameController.dispose();

    _listDir.clear();
    _listShareDir.clear();
    _listShareDirByCustomer.clear();
    _listSharedDevices.clear();
    _listSharedDevicesByCustomer.clear();
    _devices.clear();
    _listExternalDevices.clear();

    super.dispose();
  }

  Future<void> fetchDirectoryAndDevice() async {
    int? idDir = currentDir.dirId;
    List<Device> list = [];

    if (idDir != null && idDir > 0) {
      list = await _deviceRequest.getDeviceByIdDir(idDir);
    }

    _devices.clear();
    _devices.addAll(list);
  }

  void changeTab(int index) {
    _currentTab = index;
  }

  Future<void> refreshExternalDevices() async {
    setBusy(true);
    await getExternalDevices();
    setBusy(false);
  }

  Future<void> refreshSharedDevices() async {
    setBusy(true);
    await getSharedDevices();
    setBusy(false);
  }

  Future<void> refreshSharedDevicesByCustomer() async {
    setBusy(true);
    await getSharedDevicesByCustomer();
    setBusy(false);
  }

  Future<void> refreshDir() async {
    setBusy(true);

    await getMyDir();
    await getShareDir();
    await getSharedDirectoriesByCustomer();

    setBusy(false);
  }

  Dir updateCurrentDirInNewValue() {
    Dir? dir = [..._listDir, ..._listShareDir]
        .where((e) => e.dirId == currentDir.dirId)
        .firstOrNull() as Dir?;
    if (dir != null) {
      currentDir = dir;
    }
    notifyListeners();

    return currentDir;
  }

  Future<void> refreshOwnerTab() async {
    setBusy(true);

    await getMyDir();
    await getExternalDevices();

    setBusy(false);
  }

  Future<void> refreshSharedByOtherTab() async {
    setBusy(true);

    await getShareDir();
    await getSharedDevices();

    setBusy(false);
  }

  Future<void> refreshSharedByCustomerTab() async {
    setBusy(true);

    await getSharedDirectoriesByCustomer();
    await getSharedDevicesByCustomer();

    setBusy(false);
  }

  void updateSheetSize(double size) {
    _currentSheetSize = size;
    notifyListeners();
  }

  void onChangeFraction(DragUpdateDetails details,
      {double? maxHeight,
      double? maxWidth,
      double? clampMin,
      double? clampMax}) {
    double maxFrag = 0.8;
    if (maxHeight != null) {
      _folderFraction += details.delta.dy / maxHeight;
    } else if (maxWidth != null) {
      _folderFraction += details.delta.dx / maxWidth;
      maxFrag = (maxWidth - 400) / maxWidth;
    }
    _folderFraction =
        _folderFraction.clamp(clampMin ?? 0.2, clampMax ?? maxFrag);
    notifyListeners();
  }

  Future<void> getMyDir() async {
    _listDir.clear();
    _listDir.addAll(await _dirRequest.getMyDir());
    for (var dir in _listDir) {
      dir.isOwner = true;
    }
  }

  void clearEditAndChangeNameFolder() {
    changeEditingFolderName(false);
    changeChangeFolderName(false);
  }

  void changeEditingFolderName(bool isEditing) {
    _isEditingFolderName = isEditing;

    if (isEditing) {
      folderNameFocusNode.requestFocus();
      _isChangeFolderName = false;
    } else {
      folderNameFocusNode.unfocus();
    }

    notifyListeners();
  }

  void changeChangeFolderName(bool isChange, {int? idFolder}) {
    _isChangeFolderName = isChange;
    _idFolderChangeName = idFolder;

    changeFolderNameController.clear();
    if (isChange) {
      Dir? dir = _listDir
          .where((element) => element.dirId == _idFolderChangeName)
          .firstOrNull() as Dir?;

      changeFolderNameFocusNode.requestFocus();
      changeFolderNameController.text = dir?.dirName ?? '';
      _isEditingFolderName = false;
    } else {
      changeFolderNameFocusNode.unfocus();
    }

    notifyListeners();
  }

  shareDevice(
    DeviceSharedModel data,
  ) {
    print('Nhấnnnn');
    deviceViewModel = DeviceViewModel(
        context: context, currentDir: currentDir, dirViewModel: this);
    SearchCustomerDialog.show(context, deviceViewModel,
        (customerId, checkOwner) {
      Navigator.pop(context);
      deviceViewModel.shareDevice(
        data.computerId,
        data.idDir.toString(),
        this,
        customerId,
        checkOwner,
      );
    });
  }

  Future<void> onCreateNewFolderTaped() async {
    setBusy(true);
    var name = folderNameController.text;
    if (name.isNotEmpty) {
      currentDir.dirName = name;
      currentDir.dirType = 'New Type';
      await createDir();
    }

    clearEditAndChangeNameFolder();
    setBusy(false);
  }

  Future<void> onUpdateFolderTaped() async {
    var name = changeFolderNameController.text;
    Dir? dir = _listDir
        .where((element) => element.dirId == _idFolderChangeName)
        .firstOrNull() as Dir?;
    if (name.isNotEmpty && dir != null) {
      dir.dirName = name;

      if (await _dirRequest.updateDir(dir)) {
        await refreshDir();
      }
    }

    clearEditAndChangeNameFolder();
  }

  Future<void> getShareDir() async {
    _listShareDir.clear();
    _listShareDir.addAll(await _dirRequest.getShareDir());
  }

  Future<void> getSharedDevices() async {
    _listSharedDevices.clear();
    _listSharedDevices
        .addAll(await _deviceRequest.getDeviceCustomerSharedById());
    notifyListeners();
  }

  Future<void> getSharedDevicesByCustomer() async {
    _listSharedDevicesByCustomer.clear();
    _listSharedDevicesByCustomer
        .addAll(await _deviceRequest.getDeviceSharedFromCustomerId());
    notifyListeners();
  }

  Future<void> getSharedDirectoriesByCustomer() async {
    _listShareDirByCustomer.clear();
    _listShareDirByCustomer
        .addAll(await _dirRequest.getDirectoriesSharedFromCustomerId());
    notifyListeners();
  }

  Future<void> onDeviceMovedSuccess(Device device) async {
    _commandRequest.createNewCommand(
      device: device,
      command: AppString.videoFromCamp,
      content: '',
      isImme: '0',
      secondWait: 10,
    );
    await getExternalDevices();
  }

  Future<void> getExternalDevices() async {
    _listExternalDevices.clear();
    _listExternalDevices
        .addAll(await _deviceRequest.getExternalDeviceByCustomerId());
    notifyListeners();
  }

  Future<void> createDir() async {
    String? idDir =
        await _dirRequest.createDir(currentDir.dirName, currentDir.dirType);
    if (idDir != null && idDir.isNotEmpty) {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
      DateTime now = DateTime.now();

      final campModel = CampModel(
        status: '1',
        fromDate: convertDateTimeString(DateTime(now.year, now.month, 1)),
        toDate: convertDateTimeString(DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(days: 1))),
        daysOfWeek: AppConstants.days.join(','),
        videoType: 'url',
        customerId: currentUser.customerId,
        idDir: idDir,
        approvedYn: '1',
        defaultYn: '1',
      );

      switch (await _campRequest.createCamp(campModel)) {
        case ResultSuccess success:
          if (success.value != null) {
            String campaignId = success.value.toString();
            campModel.campaignId = campaignId;
            await _campRequest.updateDefaultCampById(campaignId);
            await _campRequest.addTimeRunByCampaignId(
              TimeRunModel(
                campaignId: campaignId,
                fromTime: '00:00',
                toTime: '23:59',
              ),
              campaignId,
            );
          }
          break;
      }

      folderNameController.clear();
      await refreshDir();
    }
  }

  void openDevicePage() {
    clearEditAndChangeNameFolder();
    _navigationService.navigateToDevicePage(dirViewModel: this);
  }

  void cancelSharedDirectory(DirSharedModel dir) {
    if (dir.customerIdTo == null || dir.idDir == null) return;

    showPopupTwoButton(
      title:
          'Bạn có chắc chắn hủy chia sẻ hệ thống cho ${dir.customerName} không?',
      context: context,
      isError: true,
      onLeftTap: () async {
        bool checkDelete = await _dirRequest.deleteDirShared(
            int.tryParse(dir.idDir!), dir.customerIdTo!);
        if (checkDelete) {
          refreshDir();
        } else if (context.mounted) {
          showPopupSingleButton(
            title: 'Có lỗi xảy ra, vui lòng thử lại sau.',
            context: context,
            isError: true,
          );
        }
      },
    );
  }

  void cancelSharedDevice(DeviceSharedModel device) {
    if (device.customerIdTo == null || device.idDir == null) return;

    showPopupTwoButton(
      title:
          'Bạn có chắc chắn hủy chia sẻ thiết bị cho ${device.customerName} không?',
      context: context,
      isError: true,
      onLeftTap: () async {
        bool checkDelete = await _deviceRequest.deleteDeviceShared(
            device.computerId, device.customerIdTo!);
        if (checkDelete) {
          refreshSharedDevicesByCustomer();
          _onDeleteDeviceSharedSuccess(device);
        } else if (context.mounted) {
          showPopupSingleButton(
            title: 'Có lỗi xảy ra, vui lòng thử lại sau.',
            context: context,
            isError: true,
          );
        }
      },
    );
  }

  void _onDeleteDeviceSharedSuccess(DeviceSharedModel device) {
    showPopupTwoButton(
      title:
          'Đã thu hồi chia sẻ thiết bị ${device.computerName} thành công, bạn có muốn cập nhật lại danh sách video trên thiết bị này không?',
      context: context,
      barrierDismissible: false,
      onLeftTap: () {
        _commandRequest.createNewCommand(
          device: Device(
            serialComputer: device.serialComputer,
            computerToken: device.computerToken,
          ),
          command: AppString.videoFromCamp,
          content: '',
          isImme: '0',
          secondWait: 10,
        );
      },
    );
  }
}
