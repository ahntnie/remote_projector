import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../models/camp/camp_model.dart';
import '../../view_models/camp.vm.dart';
import '../../widget/base_page.dart';
import 'widgets/camp_item.dart';

class CampPage extends StatefulWidget {
  const CampPage({super.key});

  @override
  State<CampPage> createState() => _CampPageState();
}

class _CampPageState extends State<CampPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CampViewModel>.reactive(
      viewModelBuilder: () => CampViewModel(context: context),
      onViewModelReady: (viewModel) {
        viewModel.initialise();
      },
      builder: (context, viewModel, child) {
        return BasePage(
          isBusy: viewModel.isBusy,
          body: ScreenTypeLayout.builder(
            mobile: (BuildContext context) => _buildViewMobile(viewModel),
            desktop: (BuildContext context) => _buildViewWindows(viewModel),
          ),
        );
      },
    );
  }

  Widget _buildViewMobile(CampViewModel viewModel) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppColor.navSelected,
            labelColor: AppColor.navSelected,
            unselectedLabelColor: AppColor.unSelectedLabel,
            tabAlignment: TabAlignment.center,
            isScrollable: true,
            labelStyle: const TextStyle(fontSize: 16),
            tabs: [
              const Tab(text: 'Tất cả'),
              Tab(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    const Text('Chờ duyệt'),
                    if (viewModel.listVideoRequest.isNotEmpty)
                      Positioned(
                        top: -5,
                        right: -10,
                        child: IgnorePointer(
                          child: Container(
                            height: 15,
                            width: 15,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                viewModel.listVideoRequest.length > 99
                                    ? '99+'
                                    : '${viewModel.listVideoRequest.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Tab(text: 'Video đang chạy'),
              const Tab(text: 'Video đã tắt'),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                RefreshIndicator(
                  onRefresh: viewModel.initialise,
                  child: _lineViewAllCamp(viewModel),
                ),
                RefreshIndicator(
                  onRefresh: viewModel.initialise,
                  child: _lineViewCampRequest(viewModel),
                ),
                RefreshIndicator(
                  onRefresh: viewModel.initialise,
                  child: _lineViewCampRunning(viewModel: viewModel),
                ),
                RefreshIndicator(
                  onRefresh: viewModel.initialise,
                  child: _lineViewCampDisable(viewModel: viewModel),
                ),
              ],
            ),
          ),
          if (viewModel.removeMode)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: viewModel.onCancelRemoveMode,
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: 'Hủy',
                      color: AppColor.navUnSelect,
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Đã chọn ${viewModel.campSelected.length}',
                        style: const TextStyle(
                          color: AppColor.navUnSelect,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        width: 45,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: viewModel.onDeleteCampSelected,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            child: const Center(
                              child: Text(
                                'Xóa',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildViewWindows(CampViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                height: 40,
                padding: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tất cả video',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (!isMobile)
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: IconButton(
                          onPressed: viewModel.initialise,
                          icon: const Icon(Icons.refresh_outlined, size: 20),
                          tooltip: 'Làm mới video',
                          color: AppColor.navUnSelect,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: viewModel.initialise,
                  child: _lineViewAllCamp(viewModel, isMobile: false),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: AppColor.navUnSelect,
          height: double.infinity,
          width: 0.5,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        ),
        Expanded(
          child: DefaultTabController(
            initialIndex: 0,
            length: 3,
            child: Column(
              children: [
                TabBar(
                  indicatorColor: AppColor.navSelected,
                  labelColor: AppColor.navSelected,
                  unselectedLabelColor: AppColor.unSelectedLabel,
                  tabAlignment: TabAlignment.center,
                  isScrollable: true,
                  labelStyle: const TextStyle(fontSize: 16),
                  tabs: [
                    Tab(
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          const Text('Chờ duyệt'),
                          if (viewModel.listVideoRequest.isNotEmpty)
                            Positioned(
                              top: -5,
                              right: -10,
                              child: IgnorePointer(
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      viewModel.listVideoRequest.length > 99
                                          ? '99+'
                                          : '${viewModel.listVideoRequest.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Tab(text: 'Video đang chạy'),
                    const Tab(text: 'Video đã tắt'),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      RefreshIndicator(
                        onRefresh: viewModel.initialise,
                        child: _lineViewCampRequest(viewModel),
                      ),
                      RefreshIndicator(
                        onRefresh: viewModel.initialise,
                        child: _lineViewCampRunning(viewModel: viewModel),
                      ),
                      RefreshIndicator(
                        onRefresh: viewModel.initialise,
                        child: _lineViewCampDisable(viewModel: viewModel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _lineViewAllCamp(CampViewModel viewModel, {bool isMobile = true}) {
    return Stack(
      children: [
        if (viewModel.listAllVideo.isEmpty)
          const Center(child: Text('Không có video nào'))
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: viewModel.listAllVideo.length,
                  itemBuilder: (context, index) {
                    return CampItem(
                      data: viewModel.listAllVideo[index],
                      removeMode: viewModel.removeMode,
                      campSelected: viewModel.campSelected,
                      onEditTap: viewModel.removeMode
                          ? viewModel.onItemTapedInRemoveMode
                          : viewModel.onEditCampaignTaped,
                      onDeleteTap: viewModel.onDeleteCampaignTaped,
                      onHistoryTap: viewModel.onHistoryRunCampaignTaped,
                      onLongPress: viewModel.onItemTapedInRemoveMode,
                    );
                  },
                ),
              ),
              if (viewModel.removeMode && !isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: viewModel.onCancelRemoveMode,
                          icon: const Icon(Icons.close, size: 20),
                          tooltip: 'Hủy',
                          color: AppColor.navUnSelect,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Đã chọn ${viewModel.campSelected.length}',
                            style: const TextStyle(
                                color: AppColor.navUnSelect, fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            width: 45,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: viewModel.onDeleteCampSelected,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                child: const Center(
                                  child: Text(
                                    'Xóa',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
            ],
          ),
      ],
    );
  }

  Widget _lineViewCampRequest(CampViewModel viewModel) {
    return Stack(
      children: [
        if (viewModel.listVideoRequest.isEmpty)
          const Center(
            child: Text('Không có video nào đang chờ duyệt'),
          ),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: viewModel.listVideoRequest.length,
          itemBuilder: (context, index) {
            return CampItem(
              
              data: viewModel.listVideoRequest[index],
              removeMode: viewModel.removeMode,
              campSelected: viewModel.campSelected,
              onEditTap: viewModel.removeMode
                  ? viewModel.onItemTapedInRemoveMode
                  : viewModel.onEditCampaignTaped,
              onDeleteTap: viewModel.onDeleteCampaignTaped,
              onHistoryTap: viewModel.onHistoryRunCampaignTaped,
              onLongPress: viewModel.onItemTapedInRemoveMode,
            );
          },
        ),
      ],
    );
  }

  Widget _lineViewCampRunning({required CampViewModel viewModel}) {
    List<CampModel> listCampRunning = viewModel.listAllVideo
        .where((element) => element.status == '1' && element.approvedYn == '1')
        .toList();

    return Stack(
      children: [
        if (listCampRunning.isEmpty)
          const Center(child: Text('Không có video nào')),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: listCampRunning.length,
          itemBuilder: (context, index) {
            return CampItem(
              data: listCampRunning[index],
              removeMode: viewModel.removeMode,
              campSelected: viewModel.campSelected,
              onEditTap: viewModel.removeMode
                  ? viewModel.onItemTapedInRemoveMode
                  : viewModel.onEditCampaignTaped,
              onDeleteTap: viewModel.onDeleteCampaignTaped,
              onHistoryTap: viewModel.onHistoryRunCampaignTaped,
              onLongPress: viewModel.onItemTapedInRemoveMode,
            );
          },
        ),
      ],
    );
  }

  Widget _lineViewCampDisable({required CampViewModel viewModel}) {
    List<CampModel> listCampDisable = viewModel.listAllVideo
        .where((element) => element.status != '1' && element.approvedYn == '1')
        .toList();

    return Stack(
      children: [
        if (listCampDisable.isEmpty)
          const Center(child: Text('Không có video nào')),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: listCampDisable.length,
          itemBuilder: (context, index) {
            return CampItem(
              data: listCampDisable[index],
              removeMode: viewModel.removeMode,
              campSelected: viewModel.campSelected,
              onEditTap: viewModel.removeMode
                  ? viewModel.onItemTapedInRemoveMode
                  : viewModel.onEditCampaignTaped,
              onDeleteTap: viewModel.onDeleteCampaignTaped,
              onHistoryTap: viewModel.onHistoryRunCampaignTaped,
              onLongPress: viewModel.onItemTapedInRemoveMode,
            );
          },
        ),
      ],
    );
  }
}
