import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:velocity_x/velocity_x.dart';

import '../app/app.locator.dart';
import '../app/app_sp.dart';
import '../app/app_sp_key.dart';
import '../app/app_string.dart';
import '../app/utils.dart';
import '../constants/app_color.dart';
import '../constants/app_constants.dart';
import '../models/camp/camp_model.dart';
import '../models/camp/time_run_model.dart';
import '../models/device/device_model.dart';
import '../models/dir/dir_model.dart';
import '../models/response/response_result.dart';
import '../models/user/user.dart';
import '../requests/camp/camp.request.dart';
import '../requests/command/command.request.dart';
import '../requests/device/device.request.dart';
import '../requests/dir/dir.request.dart';
import '../widget/pop_up.dart';
import 'edit_camp.vm.dart';

class DirSettingViewModel extends BaseViewModel {
  DirSettingViewModel({
    required this.context,
    required this.currentDir,
    this.campModel,
  });

  BuildContext context;
  List<CampModel>? campModel;
  Dir currentDir;

  final CampRequest _campRequest = CampRequest();
  final DirRequest _dirRequest = DirRequest();
  final CommandRequest _commandRequest = CommandRequest();
  final DeviceRequest _deviceRequest = DeviceRequest();

  final _navigationService = appLocator<NavigationService>();
  final ExpandableController expandableTimeOnOffController =
      ExpandableController();

  bool _useOnOffTime = false;
  bool get useOnOffTime => _useOnOffTime;

  String _fromDate = formatDateToString(DateTime.now());
  String get fromDate => _fromDate;

  String _toDate = formatDateToString(DateTime.now());
  String get toDate => _toDate;

  TimeOfDay _turnonTime = defaultTimeOn;
  TimeOfDay get turnonTime => _turnonTime;

  TimeOfDay _turnoffTime = defaultTimeOff;
  TimeOfDay get turnoffTime => _turnoffTime;

  final List<String> _daysOfWeek = [];
  List<String> get daysOfWeek => _daysOfWeek;

  final List<String> _listError = [];
  List<String> get listError => _listError;

  // final List<TimeRunModel> _listTimeRunning = [];
  // List<TimeRunModel> get listTimeRunning => _listTimeRunning;

  // final List<TimeRunModel> _listTimeAdding = [];
  // final List<TimeRunModel> _listTimeRemoving = [];
  // final List<TimeRunModel> _listTimeUpdating = [];

  static const TimeOfDay defaultTimeOn = TimeOfDay(hour: 6, minute: 0);
  static const TimeOfDay defaultTimeOff = TimeOfDay(hour: 0, minute: 0);

  Future<void> initialise() async {
    setBusy(true);
    await initCampaign();
    notifyListeners();
    setBusy(false);
  }

  @override
  void dispose() {
    expandableTimeOnOffController.dispose();
    campModel!.forEach((camp) {
      camp.listTimeAdding ?? [].clear();
      camp.listTimeRemoving ?? [].clear();
      camp.listTimeUpdating ?? [].clear();
    });

    _daysOfWeek.clear();
    _listError.clear();

    super.dispose();
  }

  Future<void> initCampaign() async {
    if (campModel != null) {
      for (int i = 0; i < campModel!.length; i++) {
        var camp = campModel![i];
        if (camp != null) {
          camp.listTimeRun =
              await _campRequest.getTimeRunCampById(camp.campaignId);
          // Khởi tạo các danh sách nếu null
          camp.listTimeAdding ??= [];
          camp.listTimeUpdating ??= [];
          camp.listTimeRemoving ??= [];
          camp.isNew = i != 0;
          _daysOfWeek
              .addAll((camp.daysOfWeek ?? '').removeAllWhiteSpace().split(','));
          String? fromDateString = convertTimeString2(camp.fromDate);
          String? toDateString = convertTimeString2(camp.toDate);
          if (fromDateString != null) {
            camp.fromDate = fromDateString;
          }
          if (toDateString != null) {
            camp.toDate = toDateString;
          }
          notifyListeners();
        }
      }
    }

    bool useOnTime = false;
    bool useOffTime = false;
    if (currentDir.turnoffTime != null) {
      List<String> timeOff = currentDir.turnoffTime!.split(':');
      if (timeOff.length >= 2) {
        _turnoffTime = TimeOfDay(
            hour: int.parse(timeOff[0]), minute: int.parse(timeOff[1]));
        useOffTime = true;
      }
    }
    if (currentDir.turnonTime != null) {
      List<String> timeOn = currentDir.turnonTime!.split(':');
      if (timeOn.length >= 2) {
        _turnonTime =
            TimeOfDay(hour: int.parse(timeOn[0]), minute: int.parse(timeOn[1]));
        if (currentDir.turnonTime == currentDir.turnoffTime) {
          useOnTime = false;
        } else {
          useOnTime = true;
        }
      }
    }

    changeOnOffTime(useOffTime && useOnTime);
  }

  void changeOnOffTime(bool value) {
    _useOnOffTime = value;
    if (!value && expandableTimeOnOffController.expanded) {
      expandableTimeOnOffController.toggle();
    } else if (value && !expandableTimeOnOffController.expanded) {
      expandableTimeOnOffController.toggle();
    }

    notifyListeners();
  }

  // void onSaveTimeRun() async {
  //   // Iterate through all campaigns in campModel
  //   for (var campaign in campModel!) {
  //     // Prepare the campaign model
  //     CampModel? camp = _handleCreateCampaignModel(campaign);
  //     if (camp == null) continue; // Skip if campaign model is invalid

  //     // Check if campaign_id exists to determine update or create
  //     if (camp.campaignId != null && camp.campaignId!.isNotEmpty) {
  //       // Existing campaign: Update it
  //       switch (await _campRequest.updateCamp(camp)) {
  //         case ResultSuccess success:
  //           // Handle successful update
  //           await _handleUpdateTimeRunByCampId(camp.campaignId);
  //           await _handleUpdateTimeOnOffDevice();
  //           _handleSuccessUpdateCamp();
  //           // Optionally update default campaign if needed
  //           await _campRequest.updateDefaultCampById(camp.campaignId!);
  //           break;
  //         case ResultError error:
  //           showResultError(context: context, error: error);
  //           break;
  //       }
  //     } else {
  //       // New campaign: Create it
  //       switch (await _campRequest.createCamp(camp)) {
  //         case ResultSuccess success:
  //           if (success.value != null) {
  //             String campaignId = success.value.toString();
  //             await _handleUpdateTimeRunByCampId(campaignId);
  //             await _handleUpdateTimeOnOffDevice();
  //             _handleSuccessUpdateCamp();
  //             await _campRequest.updateDefaultCampById(campaignId);
  //           }
  //           break;
  //         case ResultError error:
  //           showResultError(context: context, error: error);
  //           break;
  //       }
  //     }
  //   }
  // }
  void onSaveTimeRun() async {
    if (campModel == null || campModel!.isEmpty) {
      print('Error: campModel is null or empty');
      return;
    }

    List<CampModel> campNew = campModel!
        .where((camp) => camp.campaignId == null || camp.campaignId!.isEmpty)
        .toList();
    List<CampModel> campUpdate = campModel!
        .where((camp) => camp.campaignId != null && camp.campaignId!.isNotEmpty)
        .toList();

    await _handleCreateCampaign(campNew);
    await _handleUpdateCampaign(campUpdate);
    _handleSuccessUpdateCamp();
  }

  Future<void> _handleCreateCampaign(List<CampModel>? campNew) async {
    print('create campaign');
    campNew!.forEach((campaign) async {
      CampModel? camp = _handleCreateCampaignModel(campaign);
      if (camp == null) return;
      switch (await _campRequest.createCamp(camp)) {
        case ResultSuccess success:
          if (success.value != null) {
            String campaignId = success.value.toString();
            await _handleUpdateTimeRunByCampId(success.value, campaign);
            await _handleUpdateTimeOnOffDevice();
            // _handleSuccessUpdateCamp();
            campaign.campaignId = campaignId;
            campaign.isNew = true;
            await _campRequest.updateDefaultCampById(campaignId);
            if (campModel != null && campModel!.isNotEmpty) {
              campModel!.first.isNew = false;
            }
            notifyListeners();
          }
          break;
        case ResultError error:
          showResultError(context: context, error: error);
          break;
      }
    });
  }

  Future<void> _handleUpdateCampaign(List<CampModel>? campUpdate) async {
    print('update');
    campUpdate!.forEach((campaign) async {
      CampModel? camp = _handleCreateCampaignModel(campaign);
      if (camp == null) return;

      switch (await _campRequest.updateCamp(camp)) {
        case ResultSuccess success:
          if (success.value) {
            await _handleUpdateTimeRunByCampId(camp.campaignId, campaign);
            campaign.isNew = true;
            await _handleUpdateTimeOnOffDevice();
            if (campModel != null && campModel!.isNotEmpty) {
              campModel!.first.isNew = false;
            }

            // _handleSuccessUpdateCamp();
          }
          break;
        case ResultError error:
          showResultError(context: context, error: error);
          break;
      }
    });
  }

  Future<void> _handelDeleteCampById(String campId) async {
    await _campRequest.deleteCamp(campId);
  }

  Future<void> _handleUpdateTimeRunByCampId(
      String? campaignId, CampModel campModel) async {
    for (var item in campModel.listTimeUpdating ?? []) {
      await _campRequest.updateTimeRunByIdRun(item);
    }

    for (var item in campModel.listTimeRemoving ?? []) {
      await _campRequest.deleteTimeRunByIdRun(item);
    }

    for (var item in campModel.listTimeAdding ?? []) {
      await _campRequest.addTimeRunByCampaignId(item, campaignId);
    }
  }

  CampModel? _handleCreateCampaignModel(CampModel campaign) {
    bool checkValid = true;
    _listError.clear();
    final User currentUser =
        User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

    if (_daysOfWeek.isEmpty) {
      checkValid = false;
      _listError.add('thứ trong tuần');
    }

    if (checkValid) {
      _daysOfWeek.sort(compareWeekdays);

      final camp = CampModel(
        campaignId: campaign.campaignId,
        campaignName: '',
        status: '1',
        videoId: '',
        fromDate: convertTimeString(campaign.fromDate!),
        toDate: convertTimeString(campaign.toDate!),
        daysOfWeek: campaign.daysOfWeek,
        videoType: 'url',
        urlYoutube: '',
        urlUSP: '',
        videoDuration: '',
        customerId: campaign.customerId ?? currentUser.customerId ?? '0',
        idComputer: '0',
        idDir: currentDir.dirId?.toString(),
        approvedYn: '1',
        defaultYn: '1',
      );
      return camp;
    } else {
      showErrorString(
        error:
            'Thông tin camp chưa được thay đổi do chưa nhập ${listError.length == 1 ? '' : 'các '}thông tin về ${listError.join(', ')}',
        context: context,
      );
    }

    return null;
  }

  void _handleSuccessUpdateCamp() {
    showPopupTwoButton(
      title:
          'Đã thay đổi thông tin hệ thống thành công. Bạn có muốn cập nhật lại trên tất cả các thiết bị không?',
      context: context,
      barrierDismissible: false,
      onLeftTap: _handleUpdateAllDevice,
      onRightTap: _navigationService.back,
    );
  }

  Future<void> handelDeleteCamp(String campId) async {
    switch (await _campRequest.deleteCamp(campId)) {
      case ResultSuccess success:
        if (success.value) {
          await _handelDeleteCampById(campId);
          _handleDeleteCamp(campId);
          // _handleSuccessUpdateCamp();
        }
        break;
      case ResultError error:
        showResultError(context: context, error: error);
        break;
    }
  }

  void _handleDeleteCamp(String campId) {
    showPopupTwoButton(
      title:
          'Đã xóa thông tin giờ chạy thành công. Bạn có muốn cập nhật lại trên tất cả các thiết bị không?',
      context: context,
      barrierDismissible: false,
      onLeftTap: () => _handleDel(campId),
      onRightTap: _navigationService.back,
    );
  }

  Future<void> _handleDel(String campID) async {
    setBusy(true);
    campModel!.forEach((campp) async {
      await _campRequest.getTimeRunCampById(campp.campaignId);
    });
    campModel?.removeWhere((camp) => camp.campaignId == campID);
    notifyListeners();

    notifyListeners();
    setBusy(false);
  }

  Future<void> _handleUpdateAllDevice() async {
    setBusy(true);
    List<Device> devices =
        await _deviceRequest.getDeviceByIdDir(currentDir.dirId);

    for (Device device in devices) {
      await _commandRequest.createNewCommand(
        device: device,
        command: AppString.videoFromCamp,
        content: '',
        isImme: '0',
        secondWait: 10,
      );
    }

    setBusy(false);
    _navigationService.back();
  }

  Future<void> _handleUpdateTimeOnOffDevice() async {
    await _dirRequest.updateOnOffDeviceByIdDir(
      currentDir.dirId,
      turnOnTime: _useOnOffTime
          ? '${_turnonTime.hour.toString().padLeft(2, '0')}:${_turnonTime.minute.toString().padLeft(2, '0')}'
          : null,
      turnOffTime: _useOnOffTime
          ? '${_turnoffTime.hour.toString().padLeft(2, '0')}:${_turnoffTime.minute.toString().padLeft(2, '0')}'
          : null,
    );
  }

  void onTimeRunDeleteTaped(int index, CampModel? currentCamp) {
    showPopupTwoButton(
      title: 'Bạn có chắc chắn muốn xóa khoảng thời gian này',
      isError: true,
      context: context,
      onLeftTap: () {
        _removeTimeRange(currentCamp!.listTimeRun![index], currentCamp);
      },
    );
  }

  void _removeTimeRange(TimeRunModel item, CampModel? currentCamp) {
    currentCamp!.listTimeRun!.remove(item);
    if (item.idRun != null) {
      currentCamp.listTimeRemoving!.add(item);
      currentCamp.listTimeUpdating!
          .removeWhere((element) => element.idRun == item.idRun);
    } else {
      currentCamp.listTimeAdding!.remove(item);
    }
    notifyListeners();
  }

  void addAllDayOfWeek(CampModel currentcamp) {
    _daysOfWeek.clear();
    _daysOfWeek.addAll(AppConstants.days);
    currentcamp.daysOfWeek = _daysOfWeek.join(',');
    print('all ${currentcamp.daysOfWeek}');
    notifyListeners();
  }

  void addDayOfWeek(int index, CampModel currentcamp) {
    String day = AppConstants.days[index];
    List<String> list = currentcamp.daysOfWeek!
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    list.contains(day) ? list.remove(day) : list.add(day);
    currentcamp.daysOfWeek = list.join(',');
    print(currentcamp.daysOfWeek);
    notifyListeners();
  }

  void addTimeRange(TimeRunModel item, {required CampModel camp}) {
    print('Adding time range: ${item.fromTime} - ${item.toTime}');
    int checkSame = _checkSameTime(timeCheck: item, camp: camp);
    if (checkSame != 1) {
      print(
          'Failed to add time: ${checkSame == -1 ? 'Invalid time' : 'Time overlap'}');
      showErrorString(
        error:
            'Mốc thời gian nhập vào ${checkSame == -1 ? 'không hợp lệ' : 'bị trùng lặp'}, hãy thử lại',
        context: context,
      );
      return;
    }
    camp.listTimeRun ??= [];
    camp.listTimeAdding ??= [];
    camp.listTimeRun!.add(item);
    camp.listTimeAdding!.add(item);
    print('Added to listTimeRun: ${camp.listTimeRun!.length} items');
    print('Added to listTimeAdding: ${camp.listTimeAdding!.length} items');
    print('camp.listTimeAdding: ${camp.listTimeAdding}');
    _sortedListTime(camp);
    notifyListeners();
  }

  void _sortedListTime(CampModel camp) {
    List<TimeRunModelWithParsedTime> parsedIntervals =
        camp.listTimeRun!.map((interval) {
      return TimeRunModelWithParsedTime(
        model: interval,
        fromTime: stringToTimeOfDay(interval.fromTime)!,
        toTime: stringToTimeOfDay(interval.toTime)!,
      );
    }).toList();

    parsedIntervals.sort((a, b) => compareTimeOfDay(a.fromTime, b.fromTime));

    List<TimeRunModel> sortedTimeIntervals = parsedIntervals.map((interval) {
      return interval.model;
    }).toList();

    camp.listTimeRun ?? [].clear();
    camp.listTimeRun ?? [].addAll(sortedTimeIntervals);
  }

  int _checkSameTime(
      {int indexSubtract = -1,
      required TimeRunModel timeCheck,
      required CampModel camp}) {
    final startTime = stringToTimeOfDay(timeCheck.fromTime)!;
    final endTime = stringToTimeOfDay(timeCheck.toTime)!;
    print('starttime: ${startTime}');
    if (endTime == startTime) return -1;
    if (camp.listTimeRun!.isEmpty) return 1;
    for (int i = 0; i < camp.listTimeRun!.length; i++) {
      if (indexSubtract != i) {
        var targetStartTime = stringToTimeOfDay(camp.listTimeRun![i].fromTime)!;
        var targetEndTime = stringToTimeOfDay(camp.listTimeRun![i].toTime)!;

        bool checkSame = _isTimeRangeOverlap(
            startTime, endTime, targetStartTime, targetEndTime);
        if (checkSame) return 0;
      }
    }

    return 1;
  }

  bool _isTimeRangeOverlap(TimeOfDay startTime, TimeOfDay endTime,
      TimeOfDay targetStartTime, TimeOfDay targetEndTime) {
    final start1 = startTime.hour * 60 + startTime.minute;
    final end1 = endTime.hour * 60 + endTime.minute;
    final start2 = targetStartTime.hour * 60 + targetStartTime.minute;
    final end2 = targetEndTime.hour * 60 + targetEndTime.minute;

    if (start1 < end1 && start2 < end2) {
      return start1 < end2 && start2 < end1;
    } else if (start1 > end1 && start2 > end2) {
      return true;
    } else if (start1 > end1) {
      return start2 < end1 || start2 > start1;
    } else if (start2 > end2) {
      return start1 < end2 || start1 > start2;
    }
    return false;
  }

  void updateTimeRange(int index, TimeRunModel oldTime, TimeRunModel newTime,
      {required CampModel camp}) {
    int checkSame =
        _checkSameTime(indexSubtract: index, timeCheck: newTime, camp: camp);
    if (checkSame != 1) {
      showErrorString(
        error:
            'Mốc thời gian nhập vào ${checkSame == -1 ? 'không hợp lệ' : 'bị trùng lặp'}, hãy thử lại',
        context: context,
      );
      return;
    }

    int indexInList = camp.listTimeRun!.indexOf(oldTime);
    if (indexInList > -1) {
      camp.listTimeRun!.replaceRange(indexInList, indexInList + 1, [newTime]);
      _sortedListTime(camp);
    }

    if (oldTime.idRun != null) {
      int index = camp.listTimeUpdating!.indexOf(oldTime);
      if (index > -1) {
        camp.listTimeUpdating!.replaceFirstWhere(
            (currentValue) => currentValue.idRun == oldTime.idRun, newTime);
      } else {
        camp.listTimeUpdating!.add(newTime);
      }
    } else {
      int index = camp.listTimeAdding!.indexOf(oldTime);
      if (index > -1) {
        camp.listTimeAdding!.replaceRange(index, index + 1, [newTime]);
      } else {
        camp.listTimeAdding!.add(newTime);
      }
    }
    notifyListeners();
  }

  void updateTimeOnOffDevice(TimeOfDay turnonTime, TimeOfDay turnoffTime) {
    _turnonTime = turnonTime;
    _turnoffTime = turnoffTime;
    notifyListeners();
  }

  Future<void> onDateRangeTaped(CampModel campModel) async {
    DateTime start = stringToDateTime(campModel.fromDate.toString());
    DateTime end = stringToDateTime(campModel.toDate.toString());
    int nowYear = DateTime.now().year;

    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        firstDate: DateTime(nowYear - 5),
        lastDate: DateTime(nowYear + 5),
        cancelButton: const Text(
          'Hủy',
          style: TextStyle(
            color: AppColor.navSelected,
            fontWeight: FontWeight.bold,
          ),
        ),
        okButton: const Text(
          'Xác nhận',
          style: TextStyle(
            color: AppColor.navSelected,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      value: [start, end],
      dialogSize: const Size(450, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (results != null && results.isNotEmpty) {
      _changeFromDate(formatDateToString(results[0]!), campModel);
      _changeToDate(
          formatDateToString(results.length > 1 ? results[1]! : results[0]!),
          campModel);
    }
  }

  void _changeFromDate(String time, CampModel campModel) {
    campModel.fromDate = time;
    print('campModel.fromDate: ${campModel.fromDate}');
    notifyListeners();
  }

  void _changeToDate(String time, CampModel campModel) {
    campModel.toDate = time;
    print('campModel.toDate: ${campModel.toDate}');

    notifyListeners();
  }
}
