import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../app/app.locator.dart';
import '../app/app.router.dart';
import '../app/app_string.dart';
import '../models/camp/camp_model.dart';
import '../models/device/device_model.dart';
import '../models/response/response_result.dart';
import '../requests/camp/camp.request.dart';
import '../requests/command/command.request.dart';
import '../requests/device/device.request.dart';
import '../widget/pop_up.dart';

class CampViewModel extends BaseViewModel {
  CampViewModel({required this.context});

  final BuildContext context;

  final CampRequest _campRequest = CampRequest();
  final DeviceRequest _deviceRequest = DeviceRequest();
  final CommandRequest _commandRequest = CommandRequest();
  final _navigationService = appLocator<NavigationService>();

  final List<CampModel> _listAllVideo = [];
  List<CampModel> get listAllVideo => _listAllVideo;

  final List<CampModel> _listVideoRequest = [];
  List<CampModel> get listVideoRequest => _listVideoRequest;

  final Set<String?> _campSelected = {};
  Set<String?> get campSelected => _campSelected;

  bool _removeMode = false;
  bool get removeMode => _removeMode && _campSelected.isNotEmpty;

  Future<void> initialise() async {
    setBusy(true);

    await _getAllCampaign();

    for (var item in _listAllVideo) {
      item.listTimeRun = await _campRequest.getTimeRunCampById(item.campaignId);
    }

    setBusy(false);
  }

  @override
  void dispose() {
    _listAllVideo.clear();
    _listVideoRequest.clear();
    _campSelected.clear();

    super.dispose();
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

  Future<void> _handleDeleteCampSelected() async {
    setBusy(true);
    bool updateAllDevice = false;
    List<CampModel> campRemoved = [];
    for (CampModel camp in _listAllVideo) {
      if (_campSelected.contains(camp.campaignId)) {
        if (camp.approvedYn == '1') {
          campRemoved.add(camp);
          updateAllDevice = true;
        }
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
          onLeftTap: () => _handleUpdateDeviceInMoreVideo(campRemoved),
        );
      }
    }
    onCancelRemoveMode();
    await _getAllCampaign();
    setBusy(false);
  }

  void _toggleRemoveMode({bool? mode}) {
    _removeMode = mode ?? !_removeMode;
    notifyListeners();
  }

  Future<void> _getAllCampaign() async {
    List<CampModel> listMyCamp = await _campRequest.getAllCampByIdCustomer();

    _listAllVideo.clear();
    _listVideoRequest.clear();

    _listAllVideo.addAll(listMyCamp.where((e) => e.defaultYn != '1'));
    _addVideoRequest();
    _handleUpdateCampSelected();
  }

  void _handleUpdateCampSelected() {
    if (_campSelected.isNotEmpty) {
      Set<String?> tempSet = {};
      Set<String?> allCampaignId =
          _listAllVideo.map((e) => e.campaignId).toSet();

      for (String? campaignId in _campSelected) {
        if (allCampaignId.contains(campaignId)) {
          tempSet.add(campaignId);
        }
      }

      _campSelected.clear();
      _campSelected.addAll(tempSet);
    }
  }

  void _addVideoRequest() {
    _listVideoRequest.clear();
    _listVideoRequest.addAll(_listAllVideo
        .where((e) => e.approvedYn != '-1' && e.approvedYn != '1'));
  }

  void onDeleteCampaignTaped(CampModel campaign) {
    showPopupTwoButton(
      title: 'Bạn có chắc chắn muốn xóa camp này',
      isError: true,
      context: context,
      onLeftTap: () => _handleDeleteCampaign(campaign),
    );
  }

  Future<void> onEditCampaignTaped(CampModel? campModel) async {
    await _navigationService.navigateToEditCampPage(
        campEdit: campModel, isOwner: campModel!.isOwner == '1');
    initialise();
  }

  Future<void> onHistoryRunCampaignTaped(CampModel campModel) async {
    await _navigationService.navigateToCampProfilePage(campModel: campModel);
    initialise();
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
      int index = _listAllVideo
          .indexWhere((element) => element.campaignId == campaign.campaignId);

      if (index > -1) {
        await showPopupTwoButton(
          title:
              'Đã xóa video ${_listAllVideo[index].campaignName} thành công, bạn có muốn cập nhật lại trên các thiết bị liên quan không?',
          context: context,
          barrierDismissible: false,
          onLeftTap: () => _handleUpdateDeviceInVideo(campaign),
        );

        _listAllVideo.removeAt(index);
        _addVideoRequest();
        notifyListeners();
      }
    }
  }

  Future<void> _handleUpdateDeviceInMoreVideo(List<CampModel> camps) async {
    setBusy(true);

    Set<String?> resultSet = {};
    List<Device> list = [];

    for (CampModel camp in camps) {
      if (camp.idDir != null && camp.idDir != '0') {
        List<Device> devices =
            await _deviceRequest.getDeviceByIdDir(int.tryParse(camp.idDir!));
        for (Device device in devices) {
          if (!resultSet.contains(device.computerId)) {
            list.add(device);
            resultSet.add(device.computerId);
          }
        }
      } else if (camp.idComputer != null && camp.idComputer != '0') {
        Device? device =
            await _deviceRequest.getSingleDeviceByComputerId(camp.idComputer);
        if (device != null && !resultSet.contains(device.computerId)) {
          list.add(device);
          resultSet.add(device.computerId);
        }
      }
    }

    for (Device device in list) {
      await _commandRequest.createNewCommand(
        device: device,
        command: AppString.videoFromCamp,
        content: '',
        isImme: '0',
        secondWait: 10,
      );
    }

    setBusy(false);
  }

  Future<void> _handleUpdateDeviceInVideo(CampModel campaign) async {
    setBusy(true);

    Set<String> resultSet = {};
    List<Device> list = [];

    if (campaign.idDir != null && campaign.idDir != '0') {
      list.addAll(
          await _deviceRequest.getDeviceByIdDir(int.tryParse(campaign.idDir!)));
    } else if (campaign.idComputer != null && campaign.idComputer != '0') {
      Device? device =
          await _deviceRequest.getSingleDeviceByComputerId(campaign.idComputer);
      if (device != null) list.add(device);
    }

    for (Device device in list) {
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
}
