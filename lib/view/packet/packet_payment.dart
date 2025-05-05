import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:remote_projector_2024/app/app_sp.dart';
import 'package:remote_projector_2024/app/app_sp_key.dart';
import 'package:stacked/stacked.dart';

import '../../app/utils.dart';
import '../../constants/app_color.dart';
import '../../models/config/config_model.dart';
import '../../models/packet/my_packet_model.dart';
import '../../models/packet/packet_model.dart';
import '../../view_models/packet.vm.dart';
import '../../widget/base_page.dart';
import '../../widget/button_custom.dart';

class PacketPaymentPage extends StatefulWidget {
  final PacketModel? packet;
  final MyPacketModel? myPacket;
  final PacketViewModel packetViewModel;

  const PacketPaymentPage({
    super.key,
    this.packet,
    this.myPacket,
    required this.packetViewModel,
  });

  @override
  State<PacketPaymentPage> createState() => _PacketPaymentPageState();
}

class _PacketPaymentPageState extends State<PacketPaymentPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PacketViewModel>.reactive(
      disposeViewModel: false,
      viewModelBuilder: () => widget.packetViewModel,
      builder: (context, viewModel, child) {
        return BasePage(
          showAppBar: true,
          title: 'Mua gói cước',
          showLeadingAction: true,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTopBadge(
                    packet: widget.packet, myPacket: widget.myPacket),
                if ((widget.myPacket?.isBusiness ??
                        widget.packet?.isBusiness) !=
                    '1')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text('Thời hạn: '),
                        DropdownButton<int>(
                          value: viewModel.payMonth,
                          items: const [
                            DropdownMenuItem<int>(
                              value: 1,
                              child: Text('1 tháng'),
                            ),
                            DropdownMenuItem<int>(
                              value: 6,
                              child: Text('6 tháng'),
                            ),
                            DropdownMenuItem<int>(
                              value: 12,
                              child: Text('12 tháng'),
                            ),
                          ],
                          onChanged: (int? value) {
                            if (value != null) {
                              viewModel.setPayMonth(value);
                              print('Chọn $value');
                            }
                          },
                        )
                      ],
                    ),
                  ),
                if ((widget.myPacket?.isBusiness ??
                        widget.packet?.isBusiness) ==
                    '1')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
"""THÔNG BÁO VỀ CHÍNH SÁCH THANH TOÁN GÓI CƯỚC DOANH NGHIỆP

Kính gửi Quý khách hàng,

Khi đăng ký gói cước Doanh nghiệp, chi phí dịch vụ sẽ được tính từ ngày mua gói cước đến ngày sao kê gần nhất là ngày ${AppSP.get(AppSPKey.statementDate).toString().padLeft(2, '0')} của tháng. 
Sau đó, các kỳ thanh toán tiếp theo sẽ được thực hiện đều đặn vào ngày ${AppSP.get(AppSPKey.statementDate).toString().padLeft(2, '0')} hàng tháng.

Ví dụ:

Nếu Quý khách đăng ký gói cước vào ngày 15/04/2025, hóa đơn đầu tiên sẽ được tính từ ngày 15/04/2025 đến ngày ${AppSP.get(AppSPKey.statementDate).toString().padLeft(2, '0')}/05/2025.
Từ kỳ tiếp theo, thanh toán sẽ được thực hiện vào ngày ${AppSP.get(AppSPKey.statementDate).toString().padLeft(2, '0')} mỗi tháng (${AppSP.get(AppSPKey.statementDate).toString().padLeft(2, '0')}/06/2025, ${AppSP.get(AppSPKey.statementDate).toString().padLeft(2, '0')}/07/2025, v.v.).
Quý khách vui lòng đảm bảo hoàn tất thanh toán đúng hạn để duy trì dịch vụ không bị gián đoạn. Mọi thắc mắc, 
xin vui lòng liên hệ bộ phận hỗ trợ khách hàng để được giải đáp.

Trân trọng,
Công ty TNHH Toàn Cầu GT
Hotline: ${ConfigModel.fromJson(jsonDecode(AppSP.get(AppSPKey.config))).hotline} | Email: ${ConfigModel.fromJson(jsonDecode(AppSP.get(AppSPKey.config))).email} | Website: www.gtglobal.com.vn"""),
                  )
              ],
            ),
          ),
          bottomNavigationBar:
              (widget.myPacket?.isTrial ?? widget.packet?.isTrial) == '1'
                  ? null
                  : ButtonCustom(
                      onPressed: () => viewModel.onPaymentTaped(
                        packet: widget.packet,
                        myPacket: widget.myPacket,
                      ),
                      height: 65,
                      title: 'Xác nhận',
                      textSize: 22,
                      borderRadius: 0,
                    ),
        );
      },
    );
  }

  Widget _buildTopBadge({PacketModel? packet, MyPacketModel? myPacket}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Image.asset(
            'assets/images/img_package.png',
            height: 120,
            width: 120,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gói cước ${myPacket?.namePacket ?? packet?.namePacket ?? ''}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                // RichText(
                //   text: TextSpan(
                //     style: const TextStyle(fontSize: 14.0, color: Colors.black),
                //     children: [
                //       const TextSpan(
                //         text: 'Thời hạn: ',
                //         style: TextStyle(
                //           fontSize: 14.0,
                //           color: Colors.black,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       TextSpan(
                //         text:
                //             '${(int.tryParse(myPacket?.yearQty ?? packet?.yearQty ?? '0') ?? 0) > 0 ? '${myPacket?.yearQty ?? packet?.yearQty} năm ' : ''}'
                //             '${(int.tryParse(myPacket?.monthQty ?? packet?.monthQty ?? '0') ?? 0) > 0 ? '${myPacket?.monthQty ?? packet?.monthQty} tháng ' : ''}'
                //             '${(int.tryParse(myPacket?.dayQty ?? packet?.dayQty ?? '0') ?? 0) > 0 ? '${myPacket?.dayQty ?? packet?.dayQty} ngày ' : ''}',
                //       ),
                //     ],
                //   ),
                // ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14.0, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: 'Ưu đãi: ',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                            'kết nối tối đa ${myPacket?.limitQty ?? packet?.limitQty} thiết bị và dung lượng lưu trữ ${formatBytes(int.tryParse(myPacket?.limitCapacity ?? packet?.limitCapacity ?? '0') ?? 0, decimals: 0)}',
                      ),
                    ],
                  ),
                ),
                Text(
                  '${formatNumber(myPacket?.price ?? packet?.price)}đ',
                  style: const TextStyle(color: AppColor.navSelected),
                ),
                Text(myPacket?.detail ?? packet?.detail ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferPayment() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                transferText(title: "Chủ tài khoản", data: ""),
                transferText(title: "Số tài khoản", data: ""),
                transferText(title: "Ngân hàng", data: ""),
                transferText(title: "Chi nhánh", data: ""),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  RichText transferText({required String title, required String data}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 18.0, color: AppColor.black),
        children: [
          TextSpan(
            text: '$title: ',
            style: const TextStyle(
              fontSize: 18.0,
              color: AppColor.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: data),
        ],
      ),
    );
  }
}
