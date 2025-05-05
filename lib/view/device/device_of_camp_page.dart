import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../models/camp/camp_model.dart';
import '../../view_models/device_of_camp.vm.dart';
import '../../widget/base_page.dart';
import '../camp/widgets/device_item.dart';

class DeviceOfCampPage extends StatefulWidget {
  final CampModel campaign;

  const DeviceOfCampPage({
    super.key,
    required this.campaign,
  });

  @override
  State<DeviceOfCampPage> createState() => _DeviceOfCampPageState();
}

class _DeviceOfCampPageState extends State<DeviceOfCampPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeviceOfCampViewModel>.reactive(
      viewModelBuilder: () => DeviceOfCampViewModel(
        context: context,
        campaign: widget.campaign,
      ),
      onViewModelReady: (viewModel) {
        viewModel.initialise();
      },
      builder: (context, viewModel, child) {
        return BasePage(
          showAppBar: true,
          showNotification: true,
          showLeadingAction: true,
          title: widget.campaign.campaignName ?? '',
          body: RefreshIndicator(
            onRefresh: viewModel.initialise,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: viewModel.listDevice.length,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (context, index) {
                return DeviceItem(
                  data: viewModel.listDevice[index],
                  showTitleName: true,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
