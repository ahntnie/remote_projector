import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../models/statistics/camp_all_statistics.dart';
import '../../view_models/camp_statistics_all.vm.dart';
import '../../widget/base_page.dart';
import 'widget/line_case_color_profile.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CampStatisticsAllViewModel>.reactive(
      viewModelBuilder: () => CampStatisticsAllViewModel(),
      onViewModelReady: (viewModel) {
        viewModel.setContext(context);
        viewModel.initialise();
      },
      builder: (context, viewModel, child) {
        return BasePage(
          isBusy: viewModel.isBusy,
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

  Widget _buildViewMobile(CampStatisticsAllViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: viewModel.refreshStatistics,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(),
          SliverFillRemaining(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButtonFormField(
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      itemHeight: 30,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        labelText: 'Chọn hệ thống',
                        hintText: 'Chọn hệ thống',
                        labelStyle:
                            const TextStyle(fontSize: 12, color: Colors.black),
                        hintStyle:
                            const TextStyle(fontSize: 12, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      value: viewModel.selectedDir,
                      items: [
                        ...viewModel.listDir.map((dir) {
                          return DropdownMenuItem(
                            value: dir,
                            child: Text(dir.dirName ?? ''),
                          );
                        }),
                      ],
                      onChanged: viewModel.onChangeDir,
                    ),
                  ),
                ),
                SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: AppColor.navSelected,
                  ),
                  series: getSourceSeries(viewModel),
                  backgroundColor: Colors.transparent,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Thời gian: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColor.navUnSelect,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: viewModel.onDateRangeTaped,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              '${convertTimeString2(viewModel.timeGetProfile?.first ?? DateFormat('yyyy-MM-dd').format(DateTime.now()))} - ${convertTimeString2(viewModel.timeGetProfile?.second ?? DateFormat('yyyy-MM-dd').format(DateTime.now()))}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColor.black,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: viewModel.listAllCamp.length,
                    itemBuilder: (context, index) {
                      return LineCaseColorProfile(
                        label: viewModel.listAllCamp[index].campaignName,
                        color: viewModel.listAllCamp[index].colorChart,
                        onLabelTap: () =>
                            viewModel.onSingleStatisticCampaignTaped(index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewWindows(CampStatisticsAllViewModel viewModel) {
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
            Align(
              alignment: Alignment.topRight,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButtonFormField(
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  itemHeight: 30,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    labelText: "Chọn hệ thống",
                    hintText: "Chọn hệ thống",
                    labelStyle:
                        const TextStyle(fontSize: 12, color: Colors.black),
                    hintStyle:
                        const TextStyle(fontSize: 12, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  value: viewModel.selectedDir,
                  items: [
                    ...viewModel.listDir.map((dir) {
                      return DropdownMenuItem(
                        value: dir,
                        child: Text(dir.dirName ?? ''),
                      );
                    }),
                  ],
                  onChanged: viewModel.onChangeDir,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Thời gian: ',
                    style: TextStyle(fontSize: 14, color: AppColor.navUnSelect),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: viewModel.onDateRangeTaped,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          '${convertTimeString2(viewModel.timeGetProfile?.first ?? DateFormat('yyyy-MM-dd').format(DateTime.now()))} - ${convertTimeString2(viewModel.timeGetProfile?.second ?? DateFormat('yyyy-MM-dd').format(DateTime.now()))}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColor.black,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: viewModel.listAllCamp.length,
                itemBuilder: (context, index) {
                  return LineCaseColorProfile(
                    label: viewModel.listAllCamp[index].campaignName,
                    color: viewModel.listAllCamp[index].colorChart,
                    onLabelTap: () =>
                        viewModel.onSingleStatisticCampaignTaped(index),
                  );
                },
              ),
            ),
          ],
        )),
      ],
    );
  }

  List<StackedColumnSeries<CampAllStatistics, String>> getSourceSeries(
      CampStatisticsAllViewModel viewModel) {
    if (viewModel.timeGetProfile == null) return [];

    List<StackedColumnSeries<CampAllStatistics, String>> listReturn = [];
    List<CampAllStatistics> listStatistics = viewModel.divideDataByTimePeriod();
    viewModel.listAllCamp.forEachIndexed((index, value) {
      listReturn.add(StackedColumnSeries(
        dataSource: listStatistics,
        xValueMapper: (item, _) => item.label,
        yValueMapper: (item, _) => item.data[index],
        name: value.campaignName,
        color: value.colorChart ?? Colors.white,
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelAlignment: ChartDataLabelAlignment.middle,
          showZeroValue: false,
          textStyle: TextStyle(color: Colors.black),
        ),
      ));
    });

    return listReturn;
  }
}
