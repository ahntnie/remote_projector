import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../models/camp/camp_model.dart';
import '../models/device/device_model.dart';
import '../requests/device/device.request.dart';

class DeviceOfCampViewModel extends BaseViewModel {
  DeviceOfCampViewModel({
    required this.context,
    required this.campaign,
  });

  final BuildContext context;
  final CampModel campaign;

  final DeviceRequest _deviceRequest = DeviceRequest();

  final List<Device> _listDevice = [];
  List<Device> get listDevice => _listDevice;

  Future<void> initialise() async {
    setBusy(true);
    await _fetchDeviceOfCampByCampaignId();
    setBusy(false);
  }

  @override
  void dispose() {
    _listDevice.clear();

    super.dispose();
  }

  Future<void> _fetchDeviceOfCampByCampaignId() async {
    List<Device> list =
        await _deviceRequest.getDeviceOfCampByCampaignId(campaign.campaignId);
    // if (campaign.idDir != null) {
    //   Set<String?> idSet = list.map((item) => item.computerId).toSet();
    //   List<Device> listInDir =
    //       await _deviceRequest.getDeviceByIdDir(int.tryParse(campaign.idDir!));
    //   list.addAll(listInDir.where((item) => !idSet.contains(item.computerId)));
    // }

    _listDevice.clear();
    _listDevice.addAll(list);
  }
}
