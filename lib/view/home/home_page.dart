import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../constants/app_color.dart';
import '../../view_models/home.vm.dart';
import '../../widget/base_page.dart';
import '../../widget/button_custom.dart';
import '../navigation_bar/nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => HomeViewModel(context: context),
      onViewModelReady: (viewModel) {
        viewModel.initialise();
      },
      builder: (_, viewModel, child) {
        return PopScope(
          canPop: viewModel.currentIndex == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              viewModel.changeIndexPage(0);
            }
          },
          child: Stack(
            children: [
              BasePage(
                showAppBar: true,
                showNotification: true,
                title: viewModel.title[viewModel.currentIndex].toUpperCase(),
                body: viewModel.pages[viewModel.currentIndex],
                bottomNavigationBar: HomeNavigationBar(
                  currentIndex: viewModel.currentIndex,
                  onTabSelected: viewModel.changeIndexPage,
                ),
              ),
              if (viewModel.updateAvailable)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: AppColor.black.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Tải xuống bản cập nhật',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColor.black,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '${viewModel.tempPath != null ? 'Đã tải xong' : viewModel.isUpdate ? 'Đang tải' : 'Tạm dừng'}${viewModel.isUpdate ? ':' : ''} ',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColor.black,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                          TextSpan(
                                            text: viewModel.isUpdate
                                                ? '${(viewModel.progress * 100).toStringAsFixed(2)} %'
                                                : '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColor.black,
                                              fontWeight: FontWeight.w400,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (viewModel.isUpdate)
                                const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(),
                                ),
                            ],
                          ),
                          ButtonCustom(
                            onPressed: viewModel.cancelDownloadTaped,
                            title: viewModel.tempPath != null
                                ? 'Cài đặt'
                                : viewModel.isUpdate
                                    ? 'Hủy'
                                    : 'Tải xuống',
                            textSize: 20,
                            margin: const EdgeInsets.only(top: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
