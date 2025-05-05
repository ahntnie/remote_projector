import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as pathPackage;
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win.dart';

import '../app/app.locator.dart';
import '../app/app.router.dart';
import '../app/app_sp.dart';
import '../app/app_sp_key.dart';
import '../app/app_string.dart';
import '../constants/app_constants.dart';
import '../models/camp/camp_model.dart';
import '../models/device/device_model.dart';
import '../models/dir/dir_model.dart';
import '../models/notification/notification_model.dart';
import '../models/response/response_result.dart';
import '../models/user/user.dart';
import '../requests/account/account.request.dart';
import '../requests/camp/camp.request.dart';
import '../requests/command/command.request.dart';
import '../requests/device/device.request.dart';
import '../requests/dir/dir.request.dart';
import '../requests/notification/notification.request.dart';
import '../view/home/home_page.dart';
import '../widget/pop_up.dart';
import 'dir.vm.dart';

class DeviceViewModel extends BaseViewModel {
  DeviceViewModel({
    required this.context,
    required this.currentDir,
    required this.dirViewModel,
  });

  final BuildContext context;
  Dir currentDir;
  final DirViewModel dirViewModel;

  final DeviceRequest _deviceRequest = DeviceRequest();
  final DirRequest _dirRequest = DirRequest();
  final CommandRequest _commandRequest = CommandRequest();
  final CampRequest _campRequest = CampRequest();
  final NotificationRequest _notificationRequest = NotificationRequest();
  final TextEditingController searchEmailController = TextEditingController();
  final _navigationService = appLocator<NavigationService>();

  Device? _currentDevice;

  final List<Device> _listDeviceByDir = [];
  List<Device> get listDeviceByDir => _listDeviceByDir;

  final List<CampModel> _listVideoByDir = [];
  List<CampModel> get listVideoByDir => _listVideoByDir;

  final List<CampModel> _listVideoByDirRequest = [];
  List<CampModel> get listVideoByDirRequest => _listVideoByDirRequest;

  final Set<String?> _campSelected = {};
  Set<String?> get campSelected => _campSelected;

  final List<User> _listCustomer = [];
  List<User> get listCustomer => _listCustomer;

  bool _draggingToAdd = false;
  bool get draggingToAdd => _draggingToAdd;

  bool _removeMode = false;
  bool get removeMode => _removeMode && _campSelected.isNotEmpty;

  int? _currentTab = 0;
  int? get currentTab => _currentTab;

  bool _activeDrag = true;

  List<CampModel>? _defaultCamp = [];
  List<CampModel>? get defaultCamp => _defaultCamp;

  final List<String> addVideoAction = [
    'Thêm nhanh',
    'Thêm tùy chỉnh',
  ];

  Future<void> initialise() async {
    setBusy(true);

    await _fetchDeviceListInDir(currentDir.dirId);
    await _fetchVideoList();

    if (currentDir.isOwner == true) {
      await _fetchShareCustomerList();
    }

    setBusy(false);
  }

  @override
  void dispose() {
    searchEmailController.dispose();

    _listDeviceByDir.clear();
    _listCustomer.clear();
    _listVideoByDir.clear();
    _campSelected.clear();

    super.dispose();
  }

  void changeTab(int index) {
    _currentTab = index;
  }

  void changeDraggingToAdd(bool drag) {
    _draggingToAdd = drag;
    notifyListeners();
  }

  Future<void> onAddDragFile(List<String> paths, bool isOwner) async {
    if (paths.isNotEmpty && _activeDrag) {
      _activeDrag = false;
      onCancelRemoveMode();
      await _navigationService.navigateToResourceManagerPage(
        onChoseSuccess: (List<String>? paths) =>
            _handleAddListVideoToCamp(paths, isOwner),
        isSingle: false,
        pathDragged: paths,
      );
      _activeDrag = true;
    }
  }

  void openDetailStarted() {
    _activeDrag = false;
  }

  void openDetailEnded() {
    _activeDrag = true;
    onCancelRemoveMode();
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

  Future<void> refreshDeviceInDir() async {
    setBusy(true);
    await _fetchDeviceListInDir(currentDir.dirId);
    setBusy(false);
  }

  Future<void> refreshVideoInDir() async {
    setBusy(true);
    await _fetchVideoList();
    setBusy(false);
  }

  Future<void> refreshSharedCustomer() async {
    setBusy(true);
    await _fetchShareCustomerList();
    setBusy(false);
  }

  Future<void> getDeviceByIdDir(int? idDir) async {
    setBusy(true);
    await _fetchDeviceListInDir(idDir);
    setBusy(false);
  }

  void onCancelSharedCustomerTap(User user) {
    showPopupTwoButton(
      title:
          'Bạn có chắc chắn hủy chia sẻ hệ thống cho ${user.customerName} không?',
      context: context,
      isError: true,
      onLeftTap: () => _handleCancelSharedUser(user),
    );
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

  Future<void> openSettingDir() async {
    if (!isBusy) {
      _activeDrag = false;
      onCancelRemoveMode();
      await _navigationService.navigateToDirSettingPage(
        currentDir: currentDir,
        campModel: _defaultCamp,
      );
      _activeDrag = true;

      await refreshVideoInDir();
      await dirViewModel.refreshDir();
      currentDir = dirViewModel.updateCurrentDirInNewValue();
    }
  }

  Future<void> onAddDefaultMoreVideoTaped(bool isOwner) async {
    _activeDrag = false;
    await _navigationService.navigateToResourceManagerPage(
      onChoseSuccess: (List<String>? paths) =>
          _handleAddListVideoToCamp(paths, isOwner),
      isSingle: false,
    );
    _activeDrag = true;
  }

  Future<void> onAddNewVideoTaped({bool isOwner = false}) async {
    _activeDrag = false;
    onCancelRemoveMode();
    await _navigationService.navigateToEditCampPage(
      dir: currentDir,
      autoApprove: isOwner ? true : false,
      isOwner: isOwner,
    );
    _activeDrag = true;
    refreshVideoInDir();
  }

  Future<void> onEditCampaignTaped(CampModel campModel,
      {bool isOwner = false}) async {
    _activeDrag = false;
    print('isOwner: $isOwner');
    onCancelRemoveMode();
    await _navigationService.navigateToEditCampPage(
      campEdit: campModel,
      dir: currentDir,
      autoApprove: true,
      isOwner: isOwner,
    );
    _activeDrag = true;
    refreshVideoInDir();
  }

  Future<void> onCloningCampaignTaped(CampModel campModel) async {
    _activeDrag = false;
    CampModel copiedModelCopied = campModel.cloningItem();
    await _navigationService.navigateToEditCampPage(
      campEdit: copiedModelCopied,
      dir: currentDir,
      autoApprove: true,
    );
    _activeDrag = true;
    refreshVideoInDir();
  }

  Future<void> onHistoryRunCampaignTaped(CampModel campModel) async {
    _activeDrag = false;
    await _navigationService.navigateToCampProfilePage(campModel: campModel);
    _activeDrag = true;
    initialise();
  }

  Future<void> _handleDeleteCampSelected() async {
    setBusy(true);
    bool updateAllDevice = false;
    for (CampModel camp in _listVideoByDir) {
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
    onCancelRemoveMode();
    refreshVideoInDir();
    setBusy(false);
  }

  Future<void> _handleAddListVideoToCamp(
      List<String>? paths, bool isOwner) async {
    User user = User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

    if (paths != null && paths.isNotEmpty) {
      setBusy(true);
      int successCount = 0;

      for (String path in paths) {
        int duration =
            10; // Giá trị mặc định cho video nếu không lấy được duration

        // Kiểm tra loại file dựa trên phần mở rộng
        String extension = path.split('.').last.toLowerCase();
        bool isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension);
        bool isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(extension);

        if (isImage) {
          // Nếu là ảnh, gán duration = 15 giây
          duration = 15;
        } else if (isVideo && !kIsWeb) {
          // Nếu là video, lấy duration
          try {
            if (Platform.isAndroid || Platform.isIOS) {
              VideoPlayerController videoPlayer =
                  VideoPlayerController.networkUrl(Uri.parse(path));
              await videoPlayer.initialize();
              duration = videoPlayer.value.duration.inSeconds;
              videoPlayer.dispose();
            } else if (Platform.isWindows) {
              WinVideoPlayerController videoPlayer =
                  WinVideoPlayerController.network(path);
              await videoPlayer.initialize();
              duration = videoPlayer.value.duration.inSeconds;
              videoPlayer.dispose();
            }
          } catch (e) {
            print("Error getting video duration: $e");
            // Giữ duration mặc định (10 giây) nếu lỗi
          }
        }

        // Tạo CampModel
        final campModel = CampModel(
          campaignName:
              pathPackage.basenameWithoutExtension(path.split('/').last),
          status: '1',
          videoType: AppConstants.sourceVideo[0],
          urlYoutube: path,
          videoDuration: '$duration',
          customerId: user.customerId,
          idDir: '${currentDir.dirId}',
          approvedYn: isOwner ? '1' : '0',
        );

        switch (await _campRequest.createCamp(campModel)) {
          case ResultSuccess success:
            if (success.value != null) {
              successCount += 1;
              await _campRequest.updateRunByDefaultByCampaignId(
                  success.value, true);
            }
            break;
        }
      }

      if (successCount > 0 && context.mounted) {
        showPopupTwoButton(
          title:
              'Đã thêm nội dung thành công. Bạn có muốn cập nhật lại trên tất cả các thiết bị không?',
          context: context,
          onLeftTap: _handleUpdateDeviceInVideo,
        );
      }

      await refreshVideoInDir();
      setBusy(false);
    }
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

  Future<void> _onDeleteCampaignSuccess(CampModel campaign) async {
    if (campaign.campaignId != null) {
      int index = _listVideoByDir
          .indexWhere((element) => element.campaignId == campaign.campaignId);

      if (index > -1) {
        if (campaign.approvedYn != '1') {
          showPopupSingleButton(
            title:
                'Đã xóa video ${_listVideoByDir[index].campaignName} thành công',
            context: context,
          );
        } else {
          showPopupTwoButton(
            title:
                'Đã xóa video ${_listVideoByDir[index].campaignName} thành công, bạn có muốn cập nhật lại trên các thiết bị liên quan không?',
            context: context,
            barrierDismissible: false,
            onLeftTap: _handleUpdateDeviceInVideo,
          );
        }

        _listVideoByDir.removeAt(index);
        notifyListeners();
      }
    }
  }

  Future<void> _handleUpdateDeviceInVideo() async {
    setBusy(true);

    Set<String> resultSet = {};
    await _fetchDeviceListInDir(currentDir.dirId);

    for (Device device in _listDeviceByDir) {
      if (!resultSet.contains(device.computerId ?? '')) {
        await _commandRequest.createNewCommand(
          device: device,
          command: AppString.videoFromCamp,
          content: '',
          isImme: '0',
          secondWait: 10,
        );
        resultSet.add(device.computerId ?? '');
      }
    }

    setBusy(false);
  }

  Future<void> _handleCancelSharedUser(User user) async {
    bool checkDelete = await deleteDirectoryShared(user.customerId);

    if (checkDelete) {
      await refreshSharedCustomer();
      dirViewModel.refreshDir();
    } else if (context.mounted) {
      showPopupSingleButton(
        title: 'Có lỗi xảy ra, vui lòng thử lại sau.',
        context: context,
        isError: true,
      );
    }
  }

  Future<void> _fetchShareCustomerList() async {
    List<User> list =
        await _dirRequest.getShareCustomerList(currentDir.dirId.toString());

    _listCustomer.clear();
    _listCustomer.addAll(list);
  }

  Future<void> _fetchVideoList() async {
    List<CampModel> list = await _campRequest
        .getCampByIdDirectoryWithFilter(currentDir.dirId?.toString());

    _listVideoByDir.clear();
    _listVideoByDirRequest.clear();
    _defaultCamp = [];
    for (CampModel campModel in list) {
      if (campModel.defaultYn == '1') {
        // print('Vào thêm cap');
        // print(campModel.toJson());
        _defaultCamp!.add(campModel);
        // print(_defaultCamp!.first.toJson());
      } else {
        campModel.listTimeRun =
            await _campRequest.getTimeRunCampById(campModel.campaignId);
        _listVideoByDir.add(campModel);
      }
    }
    _listVideoByDirRequest.addAll(_listVideoByDir
        .where((video) => video.approvedYn != '-1' && video.approvedYn != '1')
        .toList());
    _handleUpdateCampSelected();
  }

  void _handleUpdateCampSelected() {
    if (_campSelected.isNotEmpty) {
      Set<String?> tempSet = {};
      Set<String?> allCampaignId =
          _listVideoByDir.map((e) => e.campaignId).toSet();

      for (String? campaignId in _campSelected) {
        if (allCampaignId.contains(campaignId)) {
          tempSet.add(campaignId);
        }
      }

      _campSelected.clear();
      _campSelected.addAll(tempSet);
    }
  }

  Future<void> _fetchDeviceListInDir(int? idDir) async {
    List<Device> list = await _deviceRequest.getDeviceByIdDir(idDir);

    _listDeviceByDir.clear();
    _listDeviceByDir.addAll(list);
  }

  void setCurrentDevice(Device? device) {
    _currentDevice = device;
  }

  Future<bool> deleteDevice() async {
    if (_currentDevice == null) return false;

    bool checkDelete = await _deviceRequest.deleteDevice(_currentDevice!);

    if (checkDelete) {
      createCommand(device: _currentDevice!, command: AppString.deleteDevice);
    }

    if (context.mounted) {
      Navigator.pop(context);
    }

    return checkDelete;
  }

  void createCommand({
    required Device device,
    required String command,
    String content = '',
    String isImme = '0',
    int secondWait = 10,
  }) {
    _commandRequest.createNewCommand(
      device: device,
      command: command,
      content: content,
      isImme: isImme,
      secondWait: secondWait,
    );
  }

  Future<void> deleteDir() async {
    setBusy(true);
    await _fetchDeviceListInDir(currentDir.dirId);
    if (_listDeviceByDir.isEmpty) {
      bool checkDelete =
          await _dirRequest.deleteDir(currentDir.dirId.toString());

      if (checkDelete) {
        if (_defaultCamp != null) {
          _defaultCamp!.forEach((camp) async {
            await _campRequest.deleteCamp(camp.campaignId);
          });
        }

        for (var camp in _listVideoByDir) {
          await _campRequest.deleteCamp(camp.campaignId);
        }

        if (context.mounted) {
          showPopupSingleButton(
            title: 'Xóa hệ thống thành công',
            context: context,
            onButtonTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            },
          );
        }
      } else if (context.mounted) {
        showPopupSingleButton(
          title: 'Xóa hệ thống thất bại',
          context: context,
          isError: true,
        );
      }
    } else if (context.mounted) {
      showPopupSingleButton(
        title: 'Không thể xóa hệ thống có thiết bị',
        context: context,
        isError: true,
      );
    }
    setBusy(false);
  }

  Future<bool> deleteDirectoryShared(String? customerId) async {
    if (customerId == null) return false;

    bool deleted = await _dirRequest.deleteDirShared(
      currentDir.dirId,
      customerId,
    );

    return deleted;
  }

  Future<User?> getCustomer() async {
    String email = searchEmailController.text;

    if (email.isNotBlank) {
      AccountRequest accountRequest = AccountRequest();
      User? user =
          await accountRequest.getCustomerByEmail(searchEmailController.text);
      return user;
    }

    return null;
  }

  Future<void> shareDir(
      String idDir, String customerIDTo, bool checkOwner) async {
    String userInfo = AppSP.get(AppSPKey.userInfo);
    final userJson = jsonDecode(userInfo);
    User currentUser = User.fromJson(userJson);
    String customerIDFrom = currentUser.customerId.toString();

    if (customerIDFrom == customerIDTo) {
      showPopupSingleButton(
        title: 'Không thể chia sẻ cho chính bản thân',
        context: context,
      );
      return;
    }

    if ((int.tryParse(customerIDTo) ?? 0) <= 0) {
      showPopupSingleButton(
        title: 'Chia sẻ không thành công, vui lòng thử lại sau',
        context: context,
      );
      return;
    }

    for (var user in _listCustomer) {
      if (user.customerId == customerIDTo) {
        showPopupSingleButton(
          title: 'Hệ thống đã được chia sẻ cho ${user.customerName} trước đó',
          context: context,
        );
        return;
      }
    }

    String? errorMessage = await _dirRequest.shareDir(
        idDir, customerIDFrom, customerIDTo, checkOwner);

    if (errorMessage == null) {
      _notificationRequest.createNotification(
        NotificationModel(
          title: 'Chia sẻ hệ thống',
          description: 'Bạn nhận được chia sẻ hệ thống mới',
          detail:
              'Bạn nhận được chia sẻ hệ thống từ người tên ${currentUser.customerName}',
        ),
        customerIDTo,
      );

      if (context.mounted) {
        initialise();
        dirViewModel.refreshDir();

        showPopupSingleButton(
          title: 'Chia sẻ hệ thống thành công',
          context: context,
        );
      }
    } else if (context.mounted) {
      showPopupSingleButton(
        title: 'Đã có lỗi xảy ra, vui lòng thử lại sau',
        isError: true,
        context: context,
      );
    }
  }

  Future<void> shareDevice(String? computerId, String idDir,
      DirViewModel dirViewModel, String customerIDTo, bool checkOwner) async {
    String userInfo = AppSP.get(AppSPKey.userInfo);
    final userJson = jsonDecode(userInfo);
    User currentUser = User.fromJson(userJson);
    String customerIDFrom = currentUser.customerId.toString();

    if (customerIDFrom == customerIDTo) {
      showPopupSingleButton(
        title: 'Không thể chia sẻ cho chính bản thân',
        context: context,
      );
      return;
    }

    if ((int.tryParse(customerIDTo) ?? 0) <= 0) {
      showPopupSingleButton(
        title: 'Chia sẻ không thành công, vui lòng thử lại sau',
        context: context,
      );
      return;
    }

    List<User> list = await _deviceRequest.getShareCustomerList(computerId);
    for (var user in list) {
      if (user.customerId == customerIDTo && context.mounted) {
        showPopupSingleButton(
          title: 'Thiết bị đã được chia sẻ cho ${user.customerName} trước đó',
          context: context,
        );
        return;
      }
    }

    String? errorMessage = await _deviceRequest.shareDevice(
        computerId, idDir, customerIDFrom, customerIDTo,checkOwner);
    if (errorMessage == null) {
      _notificationRequest.createNotification(
        NotificationModel(
          title: 'Chia sẻ thiết bị',
          description: 'Bạn nhận được chia sẻ thiết bị mới',
          detail:
              'Bạn nhận được chia sẻ thiết bị từ người tên ${currentUser.customerName}',
        ),
        customerIDTo,
      );

      if (context.mounted) {
        initialise();
        dirViewModel.refreshDir();
        dirViewModel.refreshSharedDevicesByCustomer();

        showPopupSingleButton(
          title: 'Chia sẻ thiết bị thành công',
          context: context,
        );
      }
    } else if (context.mounted) {
      initialise();

      showPopupSingleButton(
        title: 'Đã có lỗi xảy ra, vui lòng thử lại sau',
        isError: true,
        context: context,
      );
    }
  }

  Future<bool> updateDevice(Device device) async {
    bool updated = await _deviceRequest.updateDevice(device);

    return updated;
  }

  Future<void> onDeviceMovedSuccess(Device device) async {
    _commandRequest.createNewCommand(
      device: device,
      command: AppString.videoFromCamp,
      content: '',
      isImme: '0',
      secondWait: 10,
    );
    await initialise();
  }
}
