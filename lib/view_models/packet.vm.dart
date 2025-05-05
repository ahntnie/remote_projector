import 'package:flutter/material.dart';
import 'package:remote_projector_2024/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:velocity_x/velocity_x.dart';

import '../app/app.locator.dart';
import '../app/utils.dart';
import '../models/packet/my_packet_model.dart';
import '../models/packet/packet_model.dart';
import '../models/response/response_result.dart';
import '../models/transaction/transaction_model.dart';
import '../requests/packet/packet.request.dart';
import '../widget/pop_up.dart';

class PacketViewModel extends BaseViewModel {
  late BuildContext _context;

  final PacketRequest _packetRequest = PacketRequest();
  final _navigationService = appLocator<NavigationService>();
  late TabController tabController;

  final List<PacketModel> _allPacket = [];
  get allPacket => _allPacket;

  final List<MyPacketModel> _listMyPacket = [];
  List<MyPacketModel> get listMyPacket => _listMyPacket;

  final List<TransactionModel> _listTransaction = [];
  get listTransaction => _listTransaction;

  int? _currentTab = 0;
  int? get currentTab => _currentTab;

  int payMonth = 1;

  Future<void> initialise(TickerProvider vsync) async {
    setBusy(true);
    tabController = TabController(length: 3, vsync: vsync);
    await _getAllPacket();
    await _getMyPacket();
    await _getTransaction();
    setBusy(false);
  }

  @override
  void dispose() {
    _allPacket.clear();
    _listTransaction.clear();
    tabController.dispose();

    super.dispose();
  }

  void setPayMonth(int month) {
    payMonth = month;
    notifyListeners();
  }

  void changeTab(int index) {
    _currentTab = index;
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> refreshMyPacket() async {
    setBusy(true);
    await _getMyPacket();
    setBusy(false);
  }

  Future<void> refreshAllPacket() async {
    setBusy(true);
    await _getAllPacket();
    setBusy(false);
  }

  Future<void> refreshTransaction() async {
    setBusy(true);
    await _getTransaction();
    setBusy(false);
  }

  Future<void> _getMyPacket() async {
    List<MyPacketModel> list = await _packetRequest.getPacketPurchased();

    _listMyPacket.clear();
    _listMyPacket.addAll(list);
    notifyListeners();
  }

  Future<void> _getAllPacket() async {
    List<PacketModel> list = await _packetRequest.getAllPacket();

    _allPacket.clear();
    _allPacket.addAll(list);
    notifyListeners();
  }

  Future<void> _getTransaction() async {
    List<TransactionModel> list = await _packetRequest.getTransaction();

    _listTransaction.clear();
    _listTransaction.addAll(list);
    notifyListeners();
  }

  void onPaymentTaped({PacketModel? packet, MyPacketModel? myPacket}) {
    bool checkNextStep = true;

    if (myPacket == null && packet != null) {
      for (MyPacketModel item in listMyPacket) {
        if (item.deleted.isEmptyOrNull) {
          if (item.packetId != packet.packetId ||
              !isBeforeNow(item.paymentDueDate)) {
            checkNextStep = false;
          }
        }
      }
    }

    if (checkNextStep) {
      _handleValidExpiredDate(
        packet: packet,
        myPacket: myPacket,
      );
    } else {
      showPopupTwoButton(
        title:
            'Để mua gói cước này, bạn phải hủy các gói cước khác đang hoạt động.\nĐồng ý hủy gói cước?',
        context: _context,
        isError: true,
        onLeftTap: () async {
          for (var item in listMyPacket) {
            if ((item.deleted == null || item.deleted!.isEmpty) &&
                (item.packetId != packet?.packetId ||
                    (item.packetId == packet?.packetId &&
                        !isBeforeNow(item.paymentDueDate)))) {
              bool canceled = await _handleCancelPacketById(
                item.paidId,
                showPopupSuccess: false,
                showPopupError: true,
              );

              if (!canceled) return;
            }
          }

          _handleValidExpiredDate(
            packet: packet,
            myPacket: myPacket,
          );
        },
      );
    }
  }

  void onCancelPacketTaped(String? paidId) {
    showPopupTwoButton(
      title: 'Bạn có chắc chắn hủy gói cước này không?',
      context: _context,
      onLeftTap: () async {
        bool canceled = await _handleCancelPacketById(
          paidId,
          showPopupSuccess: true,
          showPopupError: true,
        );

        if (canceled) {
          refreshMyPacket();
        }
      },
    );
  }

  void onRenewalPacketTaped(MyPacketModel myPacket) {
    _navigationService
        .navigateToPacketPaymentPage(
      packetViewModel: this,
      myPacket: myPacket,
    )
        .then((buySuccess) {
      if (buySuccess == true) {
        tabController.animateTo(1);
      }
    });
  }

  Future<void> onPaymentPacketTaped(MyPacketModel myPacket) async {
    setBusy(true);
    print('Vào onPaymentPacketTaped');
    switch (await _packetRequest.createPaymentUrl(myPacket)) {
      case ResultSuccess success:
        String? paymentUrl = success.value;
        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          await _navigationService.navigateToVietQRPaymentPage(
              paymentUrl: paymentUrl);
        }
        await refreshMyPacket();
        break;
      case ResultError _:
        await refreshMyPacket();
        break;
    }
    setBusy(false);
  }

  void onPacketTaped(PacketModel packet) {
    _navigationService
        .navigateToPacketPaymentPage(
      packetViewModel: this,
      packet: packet,
    )
        .then((buySuccess) {
      if (buySuccess == true) {
        tabController.animateTo(1);
      }
    });
  }

  void _handleValidExpiredDate({PacketModel? packet, MyPacketModel? myPacket}) {
    bool checkStopStep = true;
    for (MyPacketModel item in listMyPacket) {
      if (item.deleted.isEmptyOrNull &&
          (item.packetId == myPacket?.packetId ||
              item.packetId == packet?.packetId)) {
        // bool check = isCurrentDateBefore30Days(item.expireDate);
        bool check = item.isBusiness == '1'
            ? !isBeforeNow(item.paymentDueDate)
            : isCurrentDateBefore30Days(item.expireDate);
        checkStopStep = checkStopStep && check;
      }
    }

    if (checkStopStep) {
      if (packet != null) {
        // print('Mua gói mới');
        _handleBuyPacket(packet);
      } else if (myPacket != null) {
        //print('Gia hạn gói');

        _handleRenewalPacket(myPacket);
      }
    } else {
      showErrorString(
        context: _context,
        error: 'Gói cước phải còn dưới 30 ngày sử dụng mới có thể gia hạn!',
      );
    }
  }

  Future<void> _handleBuyPacket(PacketModel packet) async {
    switch (await _packetRequest.buyPacketByCustomerId(
        packet, packet.isBusiness == '1' ? null : payMonth)) {
      case ResultSuccess _:
        _getMyPacket();
        showPopupSingleButton(
          title:
              'Yêu cầu mua gói cước thành công, vui lòng tiến hành thanh toán',
          context: _context,
          barrierDismissible: false,
          onButtonTap: () {
            _navigationService.back(result: true);
          },
        );
        break;
      case ResultError error:
        showResultError(context: _context, error: error);
        break;
    }
  }

  Future<void> _handleRenewalPacket(MyPacketModel packet) async {
    switch (await _packetRequest.renewalPacketByCustomerId(
        packet, packet.isBusiness == '1' ? null : payMonth)) {
      case ResultSuccess _:
        _getMyPacket();
        showPopupSingleButton(
          title:
              'Yêu cầu gia hạn gói cước thành công, vui lòng tiến hành thanh toán',
          context: _context,
          barrierDismissible: false,
          onButtonTap: () {
            _navigationService.back(result: true);
          },
        );
        break;
      case ResultError error:
        showResultError(context: _context, error: error);
        break;
    }
  }

  Future<bool> _handleCancelPacketById(String? paidId,
      {bool showPopupSuccess = false, bool showPopupError = false}) async {
    switch (await _packetRequest.cancelPacketById(paidId)) {
      case ResultSuccess success:
        if (success.value) {
          _onCancelPacketSuccess(paidId, showPopupSuccess);
          return true;
        }
        break;
      case ResultError error:
        if (showPopupError) showResultError(context: _context, error: error);
        break;
    }

    return false;
  }

  void _onCancelPacketSuccess(String? paidId, bool showPopup) {
    _listMyPacket.firstWhere((item) => item.paidId == paidId).deleted = 'y';
    notifyListeners();

    if (showPopup) {
      showPopupSingleButton(
        title: 'Yêu cầu hủy gói cước thành công',
        context: _context,
      );
    }
  }
}
