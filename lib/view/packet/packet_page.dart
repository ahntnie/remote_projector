import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../view_models/packet.vm.dart';
import '../../widget/base_page.dart';
import 'widgets/my_packet_item.dart';
import 'widgets/packet_item.dart';
import 'widgets/transaction_item.dart';

class PacketPage extends StatefulWidget {
  const PacketPage({super.key});

  @override
  State<PacketPage> createState() => _PacketPageState();
}

class _PacketPageState extends State<PacketPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late PacketViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = PacketViewModel();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      viewModel.refreshMyPacket();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PacketViewModel>.reactive(
      viewModelBuilder: () => viewModel,
      onViewModelReady: (viewModel) {
        viewModel.setContext(context);
        viewModel.initialise(this);
      },
      builder: (context, viewModel, child) {
        return BasePage(
          isBusy: viewModel.isBusy,
          body: Column(
            children: [
              TabBar(
                controller: viewModel.tabController,
                indicatorColor: AppColor.navSelected,
                labelColor: AppColor.navSelected,
                unselectedLabelColor: AppColor.unSelectedLabel,
                tabAlignment: TabAlignment.center,
                isScrollable: true,
                labelStyle: const TextStyle(fontSize: 16),
                tabs: const [
                  Tab(text: 'Gói cước cung cấp'),
                  Tab(text: 'Gói cước đã mua'),
                  Tab(text: 'Giao dịch'),
                ],
                onTap: (tabIndex) {
                  if (!isMobile && tabIndex == viewModel.currentTab) {
                    switch (tabIndex) {
                      case 0:
                        viewModel.refreshAllPacket();
                        break;
                      case 1:
                        viewModel.refreshMyPacket();
                        break;
                      case 2:
                        viewModel.refreshTransaction();
                        break;
                    }
                  }
                  viewModel.changeTab(tabIndex);
                },
              ),
              Expanded(
                child: TabBarView(
                  controller: viewModel.tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    RefreshIndicator(
                      onRefresh: viewModel.refreshAllPacket,
                      child: _lineViewAllPacket(viewModel),
                    ),
                    RefreshIndicator(
                      onRefresh: viewModel.refreshMyPacket,
                      child: _lineViewMyPacket(viewModel),
                    ),
                    RefreshIndicator(
                      onRefresh: viewModel.refreshMyPacket,
                      child: _lineViewTransaction(viewModel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _lineViewAllPacket(PacketViewModel viewModel) {
    return Stack(
      children: [
        if (viewModel.allPacket.isEmpty)
          const Center(child: Text('Không có gói cước nào')),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: viewModel.allPacket.length,
          itemBuilder: (context, index) {
            bool showBuyPacket = true;
            for (var element in viewModel.listMyPacket) {
              if (element.packetId == viewModel.allPacket[index].packetId &&
                  isBeforeNow(element.paymentDueDate)) {
                showBuyPacket = false;
              }
            }
            return PackageItem(
              showBuyPacket: showBuyPacket,
              data: viewModel.allPacket[index],
              buttonLabel: 'Mua gói cước',
              badgeImage: Image.asset('assets/images/img_package.png'),
              onBuyTap: viewModel.onPacketTaped,
            );
          },
        ),
      ],
    );
  }

  Widget _lineViewMyPacket(PacketViewModel viewModel) {
    return Stack(
      children: [
        if (viewModel.listMyPacket.isEmpty)
          const Center(child: Text('Không có gói cước đã mua nào')),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: viewModel.listMyPacket.length,
          itemBuilder: (context, index) {
            return MyPackageItem(
              data: viewModel.listMyPacket[index],
              onCancelTap: viewModel.onCancelPacketTaped,
              onRenewalTap: viewModel.onRenewalPacketTaped,
              onPaymentTap: viewModel.onPaymentPacketTaped,
            );
          },
        )
      ],
    );
  }

  Widget _lineViewTransaction(PacketViewModel viewModel) {
    return Stack(
      children: [
        if (viewModel.listTransaction.isEmpty)
          const Center(child: Text('Không có giao dịch nào')),
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: viewModel.listTransaction.length,
          itemBuilder: (context, index) {
            return TransactionItem(data: viewModel.listTransaction[index]);
          },
        )
      ],
    );
  }
}
