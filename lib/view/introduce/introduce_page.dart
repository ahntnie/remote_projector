import 'package:flutter/material.dart';

import '../../models/config/config_model.dart';
import '../../widget/base_page.dart';
import '../../widget/line_info.dart';

class IntroducePage extends StatefulWidget {
  final ConfigModel configModel;

  const IntroducePage({
    super.key,
    required this.configModel,
  });

  @override
  State<IntroducePage> createState() => _IntroducePageState();
}

class _IntroducePageState extends State<IntroducePage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: 'Giới thiệu',
      showLeadingAction: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              LineInfo(
                firstText: 'Tên công ty',
                secondsText: widget.configModel.companyName,
                canCopy: true,
              ),
              LineInfo(
                firstText: 'Địa chỉ',
                secondsText: widget.configModel.companyAddress,
                canCopy: true,
              ),
              LineInfo(
                firstText: 'Mã số thuế',
                secondsText: widget.configModel.taxCode,
              ),
              LineInfo(
                firstText: 'Hotline',
                secondsText: widget.configModel.hotline,
                canCopy: true,
              ),
              LineInfo(
                firstText: 'Đại diện',
                secondsText: widget.configModel.representative,
              ),
              LineInfo(
                firstText: 'Email',
                secondsText: widget.configModel.email,
                canCopy: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
