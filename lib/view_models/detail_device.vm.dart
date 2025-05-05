import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:remote_projector_2024/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../app/app.locator.dart';
import '../app/app_string.dart';
import '../models/camp/camp_model.dart';
import '../models/command/command_model.dart';
import '../models/device/device_model.dart';
import '../models/dir/dir_model.dart';
import '../models/response/response_result.dart';
import '../models/user/user.dart';
import '../requests/camp/camp.request.dart';
import '../requests/command/command.request.dart';
import '../requests/device/device.request.dart';
import '../requests/dir/dir.request.dart';
import '../widget/pop_up.dart';

class DetailDeviceViewModel extends BaseViewModel {
  DetailDeviceViewModel({
    required this.context,
    required this.currentDevice,
    required this.currentDir,
    required this.inDir,
  });

  final BuildContext context;
  Device currentDevice;
  final Dir currentDir;
  final bool inDir;

  final DeviceRequest _deviceRequest = DeviceRequest();
  final CommandRequest _commandRequest = CommandRequest();
  final DirRequest _dirRequest = DirRequest();
  final CampRequest _campRequest = CampRequest();
  final ExpandableController expandableManagerController =
      ExpandableController();
  final _navigationService = appLocator<NavigationService>();

  CommandModel? _commandModel;
  CommandModel? get commandModel => _commandModel;

  final List<User> _listCustomerOnDevice = [];
  List<User> get listCustomerOnDevice => _listCustomerOnDevice;

  final List<CampModel> _listCampOnDevice = [];
  List<CampModel> get listCampOnDevice => _listCampOnDevice;

  final List<CampModel> _listCampRequestOnDevice = [];
  List<CampModel> get listCampRequestOnDevice => _listCampRequestOnDevice;

  final List<Device> _listSharedDevices = [];
  List<Device> get listSharedDevices => _listSharedDevices;

  final List<Dir> _directorySharedByOther = [];
  List<Dir> get directorySharedByOther => _directorySharedByOther;

  final Set<String?> _campSelected = {};
  Set<String?> get campSelected => _campSelected;

  bool _removeMode = false;
  bool get removeMode => _removeMode && _campSelected.isNotEmpty;

  int? _currentTab = 0;
  int? get currentTab => _currentTab;

  bool _isWaitCommand = false;
  bool get isWaitCommand => _isWaitCommand;

  Future<void> initialise() async {
    setBusy(true);

    await _fetchCampInDevice();
    if (currentDevice.isOwner == true) {
      await getShareCustomerListByComputerId();
      if (!expandableManagerController.expanded) {
        expandableManagerController.toggle();
      }
    } else {
      await _fetchSharedDevices();
      await _fetchSharedDirectories();
      if (_directorySharedByOther.isNotEmpty && currentDevice.idDir != null) {
        Dir? dir = _directorySharedByOther
            .where((e) => e.dirId?.toString() == currentDevice.idDir)
            .firstOrNull;
        if (dir != null) {
          currentDevice.nameDir = dir.dirName;
        }
      }
    }

    setBusy(false);
  }

  @override
  void dispose() {
    _listCustomerOnDevice.clear();
    _listCampOnDevice.clear();
    _listCampRequestOnDevice.clear();
    _campSelected.clear();
    _listSharedDevices.clear();
    _directorySharedByOther.clear();
    expandableManagerController.dispose();

    super.dispose();
  }

  bool isSharedDevice() {
    return _listSharedDevices
        .where((e) => e.computerId == currentDevice.computerId)
        .isNotEmpty;
  }

  void changeTab(int index) {
    _currentTab = index;
  }

  Future<void> updateDeviceName(String? text) async {
    if (text != null && text.isNotEmpty) {
      setBusy(true);
      currentDevice.computerName = text;
      bool updated = await _deviceRequest.updateDevice(currentDevice);

      if (updated) {
        await refreshCurrentDevice();
      } else if (context.mounted) {
        showPopupSingleButton(
          title: 'Thông tin chưa được lưu, vui lòng thử lại sau',
          context: context,
        );
      }
      setBusy(false);
    }
  }

  Future<void> onAddNewVideoTaped({bool autoApprove = false}) async {
    await _navigationService.navigateToEditCampPage(
      computer: currentDevice,
      autoApprove: autoApprove,
    );
    await refreshCampInDevice();
  }

  Future<void> onEditCampaignTaped(CampModel campModel,
      {bool autoApprove = false, bool isOwner = false}) async {
    print('Đã nhấn vào edit campaign');
    await _navigationService.navigateToEditCampPage(
      campEdit: campModel,
      computer: currentDevice,
      autoApprove: autoApprove,
      isOwner: isOwner,
    );
    await refreshCampInDevice();
  }

  Future<void> onCloningCampaignTaped(CampModel campModel,
      {bool autoApprove = false}) async {
    CampModel copiedModelCopied = campModel.cloningItem();
    await _navigationService.navigateToEditCampPage(
      campEdit: copiedModelCopied,
      computer: currentDevice,
      autoApprove: autoApprove,
    );
    await refreshCampInDevice();
  }

  Future<void> onHistoryRunCampaignTaped(CampModel campModel) async {
    await _navigationService.navigateToCampProfilePage(campModel: campModel);
    await refreshCampInDevice();
  }

  void onDeleteCampaignTaped(CampModel campaign) {
    showPopupTwoButton(
      title: 'Bạn có chắc chắn muốn xóa camp này',
      isError: true,
      context: context,
      onLeftTap: () {
        _handleDeleteCampaign(campaign);
      },
    );
  }

  Future<void> refreshCampInDevice() async {
    setBusy(true);
    await _fetchCampInDevice();
    setBusy(false);
  }

  void onCancelRemoveMode() {
    _campSelected.clear();
    _toggleRemoveMode(mode: false);
    notifyListeners();
  }

  void onDeleteCampSelected() {
    showPopupTwoButton(
      title: 'Bạn có chắc chắn xóa những video này?',
      context: context,
      isError: true,
      onLeftTap: _handleDeleteCampSelected,
    );
  }

  void onItemTapedInRemoveMode(CampModel camp) {
    _campSelected.contains(camp.campaignId)
        ? removeItemFromListSelected(camp)
        : addItemToListSelected(camp);
  }

  void addItemToListSelected(CampModel camp) {
    if (!_campSelected.contains(camp.campaignId)) {
      _campSelected.add(camp.campaignId);
      _toggleRemoveMode(mode: true);
    }
  }

  void removeItemFromListSelected(CampModel camp) {
    _campSelected.remove(camp.campaignId);
    _toggleRemoveMode(mode: _campSelected.isNotEmpty);
  }

  void _toggleRemoveMode({bool? mode}) {
    _removeMode = mode ?? !_removeMode;
    notifyListeners();
  }

  Future<void> _handleDeleteCampSelected() async {
    setBusy(true);
    bool updateAllDevice = false;
    for (CampModel camp in _listCampOnDevice) {
      if (_campSelected.contains(camp.campaignId)) {
        if (camp.approvedYn == '1') updateAllDevice = true;
        await _handleDeleteCampaign(camp, showError: false);
      }
    }

    if (context.mounted) {
      if (!updateAllDevice) {
        showPopupSingleButton(
          title: 'Đã xóa hàng loạt video thành công',
          context: context,
        );
      } else {
        showPopupTwoButton(
          title:
              'Đã xóa hàng loạt video thành công, bạn có muốn cập nhật lại trên các thiết bị liên quan không?',
          context: context,
          barrierDismissible: false,
          onLeftTap: _handleUpdateDeviceInVideo,
        );
      }
    }

    await refreshCampInDevice();
    setBusy(false);
  }

  Future<void> _handleDeleteCampaign(CampModel campaign,
      {bool showError = true}) async {
    switch (await _campRequest.deleteCamp(campaign.campaignId)) {
      case ResultSuccess success:
        if (success.value && showError) {
          _onDeleteCampaignSuccess(campaign);
        }
        break;
      case ResultError error:
        if (showError) showResultError(context: context, error: error);
        break;
    }
  }

  void _onDeleteCampaignSuccess(CampModel campaign) {
    if (campaign.campaignId != null) {
      int index = _listCampOnDevice
          .indexWhere((element) => element.campaignId == campaign.campaignId);

      if (index > -1) {
        if (campaign.approvedYn != '1') {
          showPopupSingleButton(
            title:
                'Đã xóa video ${_listCampOnDevice[index].campaignName} thành công',
            context: context,
          );
        } else {
          showPopupTwoButton(
            title:
                'Đã xóa video ${_listCampOnDevice[index].campaignName} thành công, bạn có muốn cập nhật lại trên các thiết bị liên quan không?',
            context: context,
            barrierDismissible: false,
            onLeftTap: _handleUpdateDeviceInVideo,
          );
        }

        _listCampOnDevice.removeAt(index);
        notifyListeners();
      }
    }
  }

  Future<void> _handleUpdateDeviceInVideo() async {
    await _commandRequest.createNewCommand(
      device: currentDevice,
      command: AppString.videoFromCamp,
      content: '',
      isImme: '0',
      secondWait: 10,
    );
  }

  Future<void> _fetchSharedDirectories() async {
    List<Dir> shareDir = await _dirRequest.getShareDir();
    _directorySharedByOther.clear();
    _directorySharedByOther.addAll(shareDir);
  }

  Future<void> _fetchCampInDevice() async {
    List<CampModel> list = await _campRequest
        .getCampByIdDeviceWithFilter(currentDevice.computerId);

    for (var item in list) {
      item.listTimeRun = await _campRequest.getTimeRunCampById(item.campaignId);
    }

    _listCampOnDevice.clear();
    _listCampRequestOnDevice.clear();

    _listCampRequestOnDevice
        .addAll(list.where((e) => e.approvedYn != '-1' && e.approvedYn != '1'));
    _listCampOnDevice.addAll(list);

    _handleUpdateCampSelected();
  }

  void _handleUpdateCampSelected() {
    if (_campSelected.isNotEmpty) {
      Set<String?> tempSet = {};
      Set<String?> allCampaignId =
          _listCampOnDevice.map((e) => e.campaignId).toSet();

      for (String? campaignId in _campSelected) {
        if (allCampaignId.contains(campaignId)) {
          tempSet.add(campaignId);
        }
      }

      _campSelected.clear();
      _campSelected.addAll(tempSet);
    }
  }

  Future<void> _fetchSharedDevices() async {
    _listSharedDevices.clear();
    _listSharedDevices
        .addAll(await _deviceRequest.getDeviceCustomerSharedById());
    notifyListeners();
  }

  Future<void> refreshCurrentDevice() async {
    setBusy(true);

    if (currentDevice.isOwner != true) {
      await _fetchSharedDevices();
    }

    Device? device = await _deviceRequest
        .getSingleDeviceByComputerId(currentDevice.computerId);

    if (device != null) {
      device.isOwner = currentDevice.isOwner;
      device.idDir = currentDevice.idDir;
      device.nameDir = currentDevice.nameDir;

      currentDevice = device;

      if (currentDevice.isOwner == true) {
        await getShareCustomerListByComputerId();
      }
    } else if (context.mounted) {
      await showPopupSingleButton(
        title: 'Thiết bị không còn khả dụng, vui lòng kiểm tra lại',
        context: context,
        barrierDismissible: false,
        isError: true,
        onButtonTap: _navigationService.back,
      );
    }

    await initialise();
  }

  Future<void> getShareCustomerListByComputerId() async {
    _listCustomerOnDevice.clear();
    _listCustomerOnDevice.addAll(
        await _deviceRequest.getShareCustomerList(currentDevice.computerId));
    notifyListeners();
  }

  Future<void> createCommand({
    required Device device,
    required String command,
    String content = '',
    String isImme = '0',
    int secondWait = 10,
    ValueChanged<CommandModel?>? callback,
  }) async {
    Duration waitTime = const Duration(seconds: 1);
    setWaitCommand(true);
    String? commandId = await _commandRequest.createNewCommand(
      device: device,
      command: command,
      content: content,
      isImme: isImme,
      secondWait: secondWait,
    );

    if (commandId != null) {
      _commandModel = await _commandRequest.getInfoCommandById(commandId);
      final stopwatch = Stopwatch()..start();
      Timer.periodic(waitTime, (timer) async {
        int elapsedSeconds = stopwatch.elapsedMilliseconds ~/ 1000;
        if (elapsedSeconds >= secondWait) {
          timer.cancel();
          setWaitCommand(false);

          if (context.mounted) {
            showErrorString(
              error: 'Thiết bị không phản hồi',
              context: context,
            );
          }
        }
        if (_commandModel!.returnValue == '' ||
            _commandModel!.returnValue == null) {
          _commandModel = await _commandRequest
              .getInfoCommandById(_commandModel!.cmdId.toString());
          notifyListeners();
        } else {
          timer.cancel();
          onSuccessSendCommand(command);
          setWaitCommand(false);
        }
      });

      notifyListeners();
    }
  }

  void onSuccessSendCommand(String command) {
    if (context.mounted) {
      showPopupSingleButton(
        title: getTitleCommandVideo(command),
        context: context,
        isError: isErrorCommand(),
      );
    }
  }

  bool isErrorCommand() {
    String? value = commandModel?.returnValue;
    return value == AppString.notPlayVideo ||
        value == AppString.appNotShowing ||
        value == AppString.appNotPermission;
  }

  String getTitleCommandVideo(String command) {
    String? returnValue = commandModel?.returnValue;
    if (returnValue == AppString.notPlayVideo) {
      return 'Thiết bị hiện không phát video';
    }

    if (returnValue == AppString.appNotShowing) {
      return 'Thiết bị đang không hiển thị màn hình, hãy khởi động lại ứng dụng';
    }

    if (returnValue == AppString.appNotPermission) {
      return 'Ứng dụng chưa được cấp quyền thực hiện chức năng này';
    }

    if (command == AppString.getTimeNow) {
      return 'Lấy thời gian thành công\n${commandModel?.returnValue}';
    }

    return 'Gửi yêu cầu ${getCommandName(command)} thành công';
  }

  String getCommandName(String command) {
    String? returnValue = _commandModel?.returnValue;
    switch (command) {
      case AppString.restartApp:
        return 'khởi động lại thiết bị';
      case AppString.videoPause:
        return '${returnValue == AppString.continueVideo ? 'tiếp tục' : 'tạm dừng'} video';
      case AppString.videoStop:
        return 'ngừng chạy video';
      case AppString.videoRestart:
        return 'mở màn hình chạy video';
      case AppString.videoFromUSB:
        return 'chay video từ usb';
      case AppString.videoFromCamp:
        return 'chạy video từ camp';
      case AppString.wakeUpApp:
        if (returnValue == AppString.appLock) {
          return 'khóa màn hình';
        } else if (returnValue == AppString.appRunning) {
          return 'mở màn hình';
        }
    }

    return '';
  }

  void setWaitCommand(bool value) {
    _isWaitCommand = value;
    notifyListeners();
  }

  Future<bool> deleteDeviceShared(String? customerId) async {
    if (customerId == null) return false;

    List<CampModel> videos = await _campRequest
        .getCampByIdDeviceWithFilter(currentDevice.computerId);

    if (videos.isNotEmpty) {
      for (CampModel video in videos) {
        if (video.customerId == customerId) {
          await _campRequest.deleteCamp(video.campaignId);
        }
      }
    }

    bool deleted = await _deviceRequest.deleteDeviceShared(
      currentDevice.computerId,
      customerId,
    );

    return deleted;
  }

  void onDeleteDeviceSharedSuccess() {
    showPopupTwoButton(
      title:
          'Đã thu hồi chia sẻ thiết bị ${currentDevice.computerName} thành công, bạn có muốn cập nhật lại danh sách video trên thiết bị này không?',
      context: context,
      barrierDismissible: false,
      onLeftTap: _handleUpdateDeviceInVideo,
    );
  }
}
