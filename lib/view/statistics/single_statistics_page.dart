import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../models/camp/camp_model.dart';
import '../../models/camp/camp_profile_model.dart';
import '../../models/statistics/camp_all_statistics.dart';
import '../../view_models/edit_camp.vm.dart';
import '../../view_models/single_statistics.vm.dart';
import '../../widget/base_page.dart';
import 'widget/new_profile_item.dart';

class SingleStatisticsPage extends StatefulWidget {
  final CampModel camp;

  const SingleStatisticsPage({
    super.key,
    required this.camp,
  });

  @override
  State<SingleStatisticsPage> createState() => _SingleStatisticsPageState();
}

class _SingleStatisticsPageState extends State<SingleStatisticsPage> {
  bool fetchNewProfile = true;

  @override
  void dispose() {
    fetchNewProfile = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SingleStatisticsViewModel>.reactive(
      viewModelBuilder: () => SingleStatisticsViewModel(),
      onViewModelReady: (viewModel) async {
        viewModel.setInitData(context, widget.camp);
        await viewModel.initialise();
        Future.delayed(const Duration(seconds: 10), () {
          if (fetchNewProfile) loadNewCampProfile(viewModel);
        });
      },
      builder: (context, viewModel, child) {
        return BasePage(
          showAppBar: true,
          title: viewModel.campaign.campaignName,
          showLeadingAction: true,
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ScreenTypeLayout.builder(
              mobile: (BuildContext context) => _buildViewMobile(viewModel),
              desktop: (BuildContext context) => _buildViewWindows(viewModel),
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewMobile(SingleStatisticsViewModel viewModel) {
    return Column(
      children: [
        SfCartesianChart(
          primaryXAxis: const CategoryAxis(),
          tooltipBehavior:
              TooltipBehavior(enable: true, color: AppColor.navSelected),
          series: getSourceSeries(viewModel),
          backgroundColor: Colors.transparent,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Tổng 7 ngày: ${viewModel.total7Days}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.navUnSelect,
                ),
              ),
            ],
          ),
        ),
        const Row(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Thời gian',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  'Máy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  'Liên kết',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: viewModel.listCampProfileAfterFirst.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return NewResponseItem(
                data: viewModel.listCampProfileAfterFirst[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildViewWindows(SingleStatisticsViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(),
            tooltipBehavior:
                TooltipBehavior(enable: true, color: AppColor.navSelected),
            series: getSourceSeries(viewModel),
            backgroundColor: Colors.transparent,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Tổng 7 ngày: ${viewModel.total7Days}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.navUnSelect,
                      ),
                    ),
                  ],
                ),
              ),
              const Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'Thời gian',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        'Máy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        'Liên kết',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: viewModel.listCampProfileAfterFirst.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return NewResponseItem(
                      data: viewModel.listCampProfileAfterFirst[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<LineSeries<CampSingleStatistics, String>> getSourceSeries(
      SingleStatisticsViewModel viewModel) {
    if (viewModel.campaign.listCampProfile == null ||
        viewModel.campaign.listCampProfile!.isEmpty) return [];

    List<LineSeries<CampSingleStatistics, String>> listReturn = [];
    List<CampSingleStatistics> dividedData = [];

    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 6));

    final difference = endDate.difference(startDate).inDays;
    for (int i = 0; i <= difference; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));

      int total = 0;
      for (var item
          in viewModel.campaign.listCampProfile ?? <CampProfileModel>[]) {
        if (item.runTimeServer != null) {
          DateTime time = DateTime.parse(item.runTimeServer!);
          if (isSameDay(currentDate, time)) {
            total = total + 1;
          }
        }
      }
      dividedData.add(CampSingleStatistics(
        day: getFormattedDate(currentDate),
        data: total,
      ));
    }

    listReturn.add(LineSeries<CampSingleStatistics, String>(
      dataSource: dividedData,
      xValueMapper: (item, _) => item.day,
      yValueMapper: (item, _) => item.data,
      color: widget.camp.colorChart ?? AppColor.black,
      name: viewModel.campaign.campaignName,
      dataLabelSettings: const DataLabelSettings(
        isVisible: true,
        labelAlignment: ChartDataLabelAlignment.top,
        textStyle: TextStyle(color: Colors.black),
      ),
    ));

    return listReturn;
  }

  void loadNewCampProfile(SingleStatisticsViewModel viewModel) {
    if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
      DateTime timeNow = DateTime.now();
      var time = Pair(
        DateFormat('yyyy-MM-dd').format(timeNow),
        DateFormat('yyyy-MM-dd').format(timeNow),
      );
      viewModel.getCampProfile(timeGetProfile: time);
    }

    Future.delayed(const Duration(seconds: 10), () {
      if (fetchNewProfile) loadNewCampProfile(viewModel);
    });
  }
}
