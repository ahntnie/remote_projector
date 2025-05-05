import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../app/app.locator.dart';
import '../app/app.router.dart';
import '../app/utils.dart';
import '../constants/app_color.dart';
import '../models/camp/camp_model.dart';
import '../models/camp/camp_statistics_model.dart';
import '../models/dir/dir_model.dart';
import '../models/statistics/camp_all_statistics.dart';
import '../requests/camp/camp.request.dart';
import '../requests/dir/dir.request.dart';
import 'edit_camp.vm.dart';

class CampStatisticsAllViewModel extends BaseViewModel {
  late BuildContext _context;

  CampRequest request = CampRequest();
  final DirRequest _dirRequest = DirRequest();
  final _navigationService = appLocator<NavigationService>();

  final List<Color> _exitsColor = [Colors.white, Colors.black];

  final Map<String?, Color?> _mapColor = {};

  List<CampModel> _listAllCamp = [];
  List<CampModel> get listAllCamp => _listAllCamp;

  final List<CampStatisticsModel> _listCampProfile = [];
  List<CampStatisticsModel> get listCampProfile => _listCampProfile;

  Pair<String, String>? _timeGetProfile;
  Pair<String, String>? get timeGetProfile => _timeGetProfile;

  final List<Dir> _listDir = [];
  List<Dir> get listDir => _listDir;

  Dir? _selectedDir;
  Dir? get selectedDir => _selectedDir;

  final Dir defaultAllDir = Dir(dirId: 0, dirName: 'Tất cả');

  Future<void> initialise() async {
    setBusy(true);

    _selectedDir = defaultAllDir;
    await _getAllCamp();
    await getMyDir();
    for (var camp in _listAllCamp) {
      Color color = randomHexColor();
      while (_exitsColor.contains(color)) {
        color = randomHexColor();
      }
      camp.colorChart = color;
      _exitsColor.add(color);
      _mapColor[camp.campaignId] = color;
    }

    DateTime timeNow = DateTime.now();
    _timeGetProfile = Pair(
        DateFormat('yyyy-MM-dd')
            .format(timeNow.subtract(const Duration(days: 7))),
        DateFormat('yyyy-MM-dd').format(timeNow));

    await _getCampProfile(_timeGetProfile);

    setBusy(false);
  }

  @override
  void dispose() {
    _exitsColor.clear();
    _listAllCamp.clear();
    _listCampProfile.clear();
    _listDir.clear();
    _mapColor.clear();
    super.dispose();
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> getMyDir() async {
    _listDir.clear();
    _listDir.addAll(await _dirRequest.getMyDir());
    _listDir.add(defaultAllDir);

    for (var dir in _listDir) {
      dir.isOwner = true;
    }
  }

  Future<void> onChangeDir(Dir? dir) async {
    _selectedDir = dir;
    await _getAllCamp();
    if (dir?.dirId != 0) {
      _listAllCamp = _listAllCamp.where((camp) {
        return camp.idDir.toString() == _selectedDir?.dirId.toString();
      }).toList();
    }

    for (var camp in _listAllCamp) {
      Color? color = _mapColor[camp.campaignId];

      if (color == null) {
        color = randomHexColor();
        while (_exitsColor.contains(color)) {
          color = randomHexColor();
        }
        _exitsColor.add(color!);
        _mapColor[camp.campaignId] = color;
      }

      camp.colorChart = color;
    }
    notifyListeners();
  }

  Future<void> refreshStatistics() async {
    setBusy(true);
    await _getCampProfile(_timeGetProfile);
    setBusy(false);
  }

  Future<void> onSingleStatisticCampaignTaped(int index) async {
    await _navigationService.navigateToSingleStatisticsPage(
      camp: _listAllCamp[index],
    );
    await refreshStatistics();
  }

  Future<void> onDateRangeTaped() async {
    List<DateTime> times = [];
    if (timeGetProfile != null) {
      DateTime start = DateFormat('yyyy-MM-dd').parse(timeGetProfile!.first);
      DateTime end = DateFormat('yyyy-MM-dd').parse(timeGetProfile!.second);
      times = [start, end];
    }

    var results = await showCalendarDatePicker2Dialog(
      context: _context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        firstDate: DateTime(2024),
        lastDate: DateTime.now(),
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
      value: times,
      dialogSize: const Size(450, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (results != null && results.isNotEmpty) {
      _changeTimeGetProfile(
        Pair(
          DateFormat('yyyy-MM-dd').format(results[0]!),
          DateFormat('yyyy-MM-dd').format(results[results.length > 1 ? 1 : 0]!),
        ),
      );
    }
  }

  List<CampAllStatistics> divideDataByTimePeriod() {
    DateTime startDate = DateTime.parse(timeGetProfile!.first);
    DateTime endDate = DateTime.parse(timeGetProfile!.second);

    final difference = endDate.difference(startDate).inDays;

    if (difference <= 7) {
      // Divided by day if the period is less than 1 week
      return _divideDataByDay(difference, startDate);
    } else if (difference > 7 && difference <= 60) {
      // Divided by week if the period is from more than 1 week to 2 months
      return _divideDataByWeek(startDate, endDate);
    } else if (difference > 60 && difference <= 730) {
      // Divided by month if the period is from 2 months to 2 years
      return _divideDataByMonth(startDate, endDate);
    } else {
      // Divided by year if the period is 2 years or more
      return _divideDataByYear(startDate, endDate);
    }
  }

  List<CampAllStatistics> _divideDataByDay(int difference, DateTime startDate) {
    List<CampAllStatistics> dividedData = [];

    for (int i = 0; i <= difference; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      List<int> listData = [];

      for (var camp in _listAllCamp) {
        int total = 0;
        for (var item in _listCampProfile) {
          if (item.campaignId == camp.campaignId) {
            DateTime time = DateTime.parse(item.runDate ?? '0');
            if (isSameDay(time, currentDate)) {
              total += int.parse(item.runTotal ?? '0');
            }
          }
        }

        listData.add(total);
      }

      dividedData.add(CampAllStatistics(
        getFormattedDate(currentDate),
        listData,
      ));
    }

    return dividedData;
  }

  List<CampAllStatistics> _divideDataByWeek(
      DateTime startDate, DateTime endDate) {
    List<CampAllStatistics> dividedData = [];
    DateTime currentWeekStart = startDate;

    while (isSameDay(currentWeekStart, endDate) ||
        currentWeekStart.isBefore(endDate)) {
      List<int> listData = [];
      DateTime currentWeekEnd = currentWeekStart.add(const Duration(days: 6));
      if (currentWeekEnd.isAfter(endDate)) {
        currentWeekEnd = endDate;
      }

      for (var camp in _listAllCamp) {
        int total = 0;
        for (var item in _listCampProfile) {
          if (item.campaignId == camp.campaignId) {
            DateTime time = DateTime.parse(item.runDate ?? '0');
            if (isSameDay(currentWeekStart, currentWeekEnd)) {
              if (isSameDay(currentWeekStart, time)) {
                total += int.parse(item.runTotal ?? '0');
              }
            } else {
              if (time.isAfter(
                      currentWeekStart.subtract(const Duration(days: 1))) &&
                  time.isBefore(currentWeekEnd.add(const Duration(days: 1)))) {
                total += int.parse(item.runTotal ?? '0');
              }
            }
          }
        }
        listData.add(total);
      }

      dividedData.add(CampAllStatistics(
        '${DateFormat('dd/MM').format(currentWeekStart)} - ${DateFormat('dd/MM').format(currentWeekEnd)}',
        listData,
      ));
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }

    return dividedData;
  }

  List<CampAllStatistics> _divideDataByMonth(
      DateTime startDate, DateTime endDate) {
    List<CampAllStatistics> dividedData = [];

    DateTime currentMonthStart = DateTime(startDate.year, startDate.month);
    while (currentMonthStart.isBefore(endDate)) {
      List<int> listData = [];
      DateTime currentMonthEnd =
          DateTime(currentMonthStart.year, currentMonthStart.month + 1)
              .subtract(const Duration(days: 1));
      if (currentMonthEnd.isAfter(endDate)) {
        currentMonthEnd = endDate;
      }

      for (var camp in _listAllCamp) {
        int total = 0;
        for (var item in _listCampProfile) {
          if (item.campaignId == camp.campaignId) {
            DateTime time = DateTime.parse(item.runDate ?? '0');
            if (time.isAfter(
                    currentMonthStart.subtract(const Duration(days: 1))) &&
                time.isBefore(currentMonthEnd.add(const Duration(days: 1)))) {
              total += int.parse(item.runTotal ?? '0');
            }
          }
        }
        listData.add(total);
      }

      dividedData.add(CampAllStatistics(
        DateFormat('MM/yyyy').format(currentMonthStart),
        listData,
      ));
      currentMonthStart =
          DateTime(currentMonthStart.year, currentMonthStart.month + 1);
    }

    return dividedData;
  }

  List<CampAllStatistics> _divideDataByYear(
      DateTime startDate, DateTime endDate) {
    List<CampAllStatistics> dividedData = [];

    DateTime currentYearStart = DateTime(startDate.year);
    while (currentYearStart.isBefore(endDate)) {
      List<int> listData = [];
      DateTime currentYearEnd =
          DateTime(currentYearStart.year + 1).subtract(const Duration(days: 1));
      if (currentYearEnd.isAfter(endDate)) {
        currentYearEnd = endDate;
      }

      for (var camp in _listAllCamp) {
        int total = 0;
        for (var item in _listCampProfile) {
          if (item.campaignId == camp.campaignId) {
            DateTime time = DateTime.parse(item.runDate ?? '0');
            if (time.isAfter(
                    currentYearStart.subtract(const Duration(days: 1))) &&
                time.isBefore(currentYearEnd.add(const Duration(days: 1)))) {
              total += int.parse(item.runTotal ?? '0');
            }
          }
        }
        listData.add(total);
      }

      dividedData.add(CampAllStatistics(
        DateFormat('yyyy').format(currentYearStart),
        listData,
      ));
      currentYearStart = DateTime(currentYearStart.year + 1);
    }

    return dividedData;
  }

  Future<void> _getAllCamp() async {
    List<CampModel> listMyCamp = await request.getAllCampByIdCustomer();

    _listAllCamp.clear();
    _listAllCamp.addAll(listMyCamp.where((e) => e.defaultYn != '1'));
  }

  Future<void> _getCampProfile(Pair<String, String>? timeGetProfile) async {
    if (timeGetProfile != null) {
      List<CampStatisticsModel> list =
          await request.getCampaignRunProfileGeneral(
        fromDate: timeGetProfile.first,
        toDate: timeGetProfile.second,
      );

      _listCampProfile.clear();
      _listCampProfile.addAll(list);
      notifyListeners();
    }
  }

  Future<void> _changeTimeGetProfile(Pair<String, String> time) async {
    _timeGetProfile = time;
    setBusy(true);

    await _getCampProfile(_timeGetProfile);

    setBusy(false);
  }
}
