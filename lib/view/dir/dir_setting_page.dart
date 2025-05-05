import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../constants/app_constants.dart';
import '../../models/camp/camp_model.dart';
import '../../models/camp/time_run_model.dart';
import '../../models/dir/dir_model.dart';
import '../../view_models/dir_setting.vm.dart';
import '../../widget/base_page.dart';
import '../camp/widgets/camp_icon_box.dart';
import '../camp/widgets/camp_time_box.dart';
import '../camp/widgets/line_camp_date.dart';
import '../camp/widgets/time_range.dart';
import '../camp/widgets/time_run_item.dart';

class DirSettingPage extends StatefulWidget {
  const DirSettingPage({
    super.key,
    required this.currentDir,
    this.campModel,
  });

  final List<CampModel>? campModel;
  final Dir currentDir;

  @override
  State<DirSettingPage> createState() => _DirSettingPageState();
}

class _DirSettingPageState extends State<DirSettingPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DirSettingViewModel>.reactive(
      viewModelBuilder: () => DirSettingViewModel(
        context: context,
        campModel: widget.campModel,
        currentDir: widget.currentDir,
      ),
      onViewModelReady: (viewModel) {
        viewModel.initialise();
      },
      builder: (context, viewModel, child) {
        return BasePage(
          showAppBar: true,
          title: 'Thiết lập giờ mặc định',
          showLeadingAction: true,
          isBusy: viewModel.isBusy,
          fab: FloatingActionButton(
            tooltip: 'Thêm campaign',
            backgroundColor: Colors.transparent,
            onPressed: () {
              DateTime now = DateTime.now();
              viewModel.campModel!.add(CampModel(
                  campaignId: '',
                  campaignName: '',
                  status: '1',
                  videoId: '',
                  fromDate:
                      formatDateToString(DateTime(now.year, now.month, 1)),
                  toDate: formatDateToString(
                      DateTime(now.year, now.month + 1, 1)
                          .subtract(const Duration(days: 1))),
                  daysOfWeek: '',
                  videoType: 'url',
                  urlYoutube: '',
                  urlUSP: '',
                  videoDuration: '',
                  customerId: '',
                  idComputer: '0',
                  idDir: '',
                  approvedYn: '1',
                  defaultYn: '1',
                  isNew: true,
                  listTimeAdding: [
                    TimeRunModel(fromTime: '00:00', toTime: '23:59')
                  ],
                  listTimeRun: [
                    TimeRunModel(fromTime: '00:00', toTime: '23:59')
                  ]));

              viewModel.notifyListeners();
            },
            shape: const CircleBorder(),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.appBarStart, AppColor.appBarEnd],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.add_circle_outline_sharp,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          body: ListView.builder(
            itemCount: viewModel.campModel!.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return settingTimeRun(
                viewModel,
                context,
                viewModel.campModel![index],
              );
            },
          ),
          bottomNavigationBar: Container(
            width: double.infinity,
            height: 70,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.appBarEnd, AppColor.appBarStart],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: viewModel.onSaveTimeRun,
                      child: Center(
                        child: Text(
                          'Lưu'.toUpperCase(),
                          style: const TextStyle(
                            color: AppColor.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Column settingTimeRun(
    DirSettingViewModel viewModel,
    BuildContext context,
    CampModel currentcamp,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Giờ chạy trong ngày',
              style: TextStyle(fontSize: 14, color: AppColor.navUnSelect),
            ),
            currentcamp.isNew == true
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red, // Màu nền đỏ cho container
                        // Bo tròn container
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white, // Màu trắng cho icon
                          size: 20,
                        ),
                        onPressed: () =>
                            viewModel.handelDeleteCamp(currentcamp.campaignId!),
                      ),
                    ),
                  )
                : SizedBox.shrink()
          ],
        ),
        SizedBox(
          width: 230,
          child: ListView.builder(
            itemCount: currentcamp.listTimeRun!.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return TimeRunItem(
                time: currentcamp.listTimeRun![index],
                index: index,
                onSubtractTap: (index) {
                  viewModel.onTimeRunDeleteTaped(index, currentcamp);
                },
                onTimeTap: (timeRun, iIndex) => onTimeRangeTaped(
                  context: context,
                  viewModel: viewModel,
                  index: iIndex,
                  timeRun: timeRun,
                  camp: currentcamp,
                ),
              );
            },
          ),
        ),
        CampIconBox(
          icon: 'assets/images/ic_plus.png',
          onTap: () => onTimeRangeTaped(
            context: context,
            viewModel: viewModel,
            index: -1,
            camp: currentcamp,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Thứ trong tuần',
          style: TextStyle(fontSize: 14, color: AppColor.navUnSelect),
        ),
        Container(
          height: 40,
          margin: const EdgeInsets.only(bottom: 10, top: 5),
          child: ListView.builder(
            itemCount: AppConstants.days.length + 1,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index == 0) {
                return CampTimeBox(
                  centerText: 'Tất cả',
                  textColor: AppColor.white,
                  backgroundColor: AppColor.navSelected,
                  onTap: () => viewModel.addAllDayOfWeek(currentcamp),
                );
              }
              return CampTimeBox(
                centerText: AppConstants.days[index - 1],
                textColor: currentcamp.daysOfWeek!
                        .split(',')
                        .contains(AppConstants.days[index - 1])
                    ? AppColor.navSelected
                    : AppColor.navUnSelect,
                onTap: () => viewModel.addDayOfWeek(index - 1, currentcamp),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: LineCampDate(
                label: 'Ngày bắt đầu',
                content: currentcamp.fromDate,
                readOnly: false,
                onTextTap: () => viewModel.onDateRangeTaped(currentcamp),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: LineCampDate(
                label: 'Ngày kết thúc',
                readOnly: false,
                content: currentcamp.toDate,
                onTextTap: () => viewModel.onDateRangeTaped(currentcamp),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Future<void> onTimeRangeTaped({
    required BuildContext context,
    required DirSettingViewModel viewModel,
    required int index,
    TimeRunModel? timeRun,
    required CampModel camp,
  }) {
    final timeStart = stringToTimeOfDay(timeRun?.fromTime);
    final timeEnd = stringToTimeOfDay(timeRun?.toTime);
    final timeNow = DateTime.now();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Chọn thời gian chạy',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColor.navSelected,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TimeRangePicker(
            initialFromHour: timeStart?.hour ?? timeNow.hour,
            initialFromMinutes: timeStart?.minute ?? timeNow.minute,
            initialToHour: timeEnd?.hour ?? timeNow.hour,
            initialToMinutes: timeEnd?.minute ?? timeNow.minute,
            editable: true,
            is24Format: true,
            disableTabInteraction: true,
            onSelect: (from, to) {
              Navigator.pop(context);

              bool correctPos = compareTwoTime(from, to);

              if (index > -1) {
                viewModel.updateTimeRange(
                  index,
                  timeRun!,
                  TimeRunModel(
                    idRun: timeRun.idRun,
                    fromTime: convertTime(correctPos ? from : to),
                    toTime: convertTime(correctPos ? to : from),
                  ),
                  camp: camp,
                );
              } else {
                viewModel.addTimeRange(
                  TimeRunModel(
                    fromTime: convertTime(correctPos ? from : to),
                    toTime: convertTime(correctPos ? to : from),
                  ),
                  camp: camp,
                );
              }
            },
            onCancel: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  Future<void> onTimeOnOffDeviceRangeTaped({
    required BuildContext context,
    required DirSettingViewModel viewModel,
  }) {
    final timeStart = viewModel.turnoffTime;
    final timeEnd = viewModel.turnonTime;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Thời gian bật tắt thiết bị',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColor.navSelected,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TimeRangePicker(
            initialFromHour: timeStart.hour,
            initialFromMinutes: timeStart.minute,
            initialToHour: timeEnd.hour,
            initialToMinutes: timeEnd.minute,
            editable: true,
            is24Format: true,
            disableTabInteraction: true,
            tabFromText: 'Giờ tắt',
            tabToText: 'Giờ khởi động',
            onSelect: (from, to) {
              Navigator.pop(context);

              viewModel.updateTimeOnOffDevice(to, from);
            },
            onCancel: () => Navigator.pop(context),
          ),
        );
      },
    );
  }
}
 // Row(
        //   children: [
        //     const Expanded(
        //       child: Text(
        //         'Cài đặt thời gian tắt thiết bị',
        //         style: TextStyle(
        //           fontSize: 14,
        //           fontWeight: FontWeight.bold,
        //           color: AppColor.navUnSelect,
        //         ),
        //       ),
        //     ),
        //     Transform.scale(
        //       scale: 0.8,
        //       child: Switch(
        //         value: viewModel.useOnOffTime,
        //         onChanged: viewModel.changeOnOffTime,
        //         activeColor: AppColor.white,
        //         activeTrackColor: AppColor.navSelected,
        //         inactiveThumbColor: AppColor.white,
        //         inactiveTrackColor: AppColor.bgInActiveSwitch,
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 5),
        // ExpandablePanel(
        //   controller: viewModel.expandableTimeOnOffController,
        //   collapsed: const SizedBox.shrink(),
        //   expanded: Row(
        //     children: [
        //       Expanded(
        //         child: LineCampDate(
        //           label: 'Giờ tắt máy',
        //           readOnly: false,
        //           content:
        //               '${viewModel.turnoffTime.hour.toString().padLeft(2, '0')}:${viewModel.turnoffTime.minute.toString().padLeft(2, '0')}',
        //           onTextTap: () => onTimeOnOffDeviceRangeTaped(
        //             context: context,
        //             viewModel: viewModel,
        //           ),
        //         ),
        //       ),
        //       const SizedBox(width: 20),
        //       Expanded(
        //         child: LineCampDate(
        //           label: 'Giờ khởi động máy',
        //           content:
        //               '${viewModel.turnonTime.hour.toString().padLeft(2, '0')}:${viewModel.turnonTime.minute.toString().padLeft(2, '0')}',
        //           readOnly: false,
        //           onTextTap: () => onTimeOnOffDeviceRangeTaped(
        //             context: context,
        //             viewModel: viewModel,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),