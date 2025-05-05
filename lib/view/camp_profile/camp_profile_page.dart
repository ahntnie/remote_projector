import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../models/camp/camp_model.dart';
import '../../view_models/camp_profile.vm.dart';
import '../../widget/base_page.dart';
import 'widget/camp_profile_item.dart';

class CampProfilePage extends StatefulWidget {
  final CampModel campModel;

  const CampProfilePage({
    super.key,
    required this.campModel,
  });

  @override
  State<CampProfilePage> createState() => _CampProfilePageState();
}

class _CampProfilePageState extends State<CampProfilePage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CampProfileViewModel>.reactive(
      viewModelBuilder: () => CampProfileViewModel(campModel: widget.campModel),
      onViewModelReady: (viewModel) {
        viewModel.initialise();
      },
      builder: (context, viewModel, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          isBusy: viewModel.isBusy,
          title: 'Lịch sử chạy'.toUpperCase(),
          body: RefreshIndicator(
            onRefresh: viewModel.initialise,
            child: Stack(
              children: [
                if (viewModel.listCampProfile.isEmpty)
                  const Center(child: Text('Không có lịch sử nào hiện có')),
                ListView.builder(
                  itemCount: viewModel.listCampProfile.length,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemBuilder: (context, index) {
                    return CampProfileItem(
                        data: viewModel.listCampProfile[index]);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
