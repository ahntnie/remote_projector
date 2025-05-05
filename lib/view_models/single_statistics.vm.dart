import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../app/utils.dart';
import '../models/camp/camp_model.dart';
import '../models/camp/camp_profile_model.dart';
import '../requests/camp/camp.request.dart';
import 'edit_camp.vm.dart';

class SingleStatisticsViewModel extends BaseViewModel {
  late CampModel campaign;

  final CampRequest _campRequest = CampRequest();
  final Set<String?> _setIdCampProfile = {};

  final List<CampProfileModel> _listCampProfileAfterFirst = [];
  List<CampProfileModel> get listCampProfileAfterFirst =>
      _listCampProfileAfterFirst;

  int _total7Days = 0;
  int get total7Days => _total7Days;

  Future<void> initialise() async {
    DateTime timeNow = DateTime.now();
    campaign.listCampProfile = [];
    getCampProfile(
      timeGetProfile: Pair(
        DateFormat('yyyy-MM-dd')
            .format(timeNow.subtract(const Duration(days: 6))),
        DateFormat('yyyy-MM-dd').format(timeNow),
      ),
      isFirstFetch: true,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _setIdCampProfile.clear();
    _listCampProfileAfterFirst.clear();

    super.dispose();
  }

  void setInitData(BuildContext context, CampModel c) {
    campaign = c;
  }

  Future<void> getCampProfile({
    required Pair<String, String> timeGetProfile,
    bool isFirstFetch = false,
  }) async {
    List<CampProfileModel> listResponse =
        await _campRequest.getCampaignRunProfile(
      campaignId: campaign.campaignId,
      fromDate: timeGetProfile.first,
      toDate: timeGetProfile.second,
    );

    if (isFirstFetch) {
      campaign.listCampProfile = listResponse;
      _setIdCampProfile.addAll(listResponse
          .where((item) => isSameDay(
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(item.runTimeServer!),
              DateTime.now()))
          .map((item) => item.id)
          .toSet());
      _total7Days = listResponse.length;
      notifyListeners();
    } else {
      List<CampProfileModel> newElements = listResponse
          .where((item) => !_setIdCampProfile.contains(item.id))
          .toList();

      if (newElements.isNotEmpty) {
        _listCampProfileAfterFirst.addAll(newElements);
        _listCampProfileAfterFirst
            .sort((a, b) => b.runTimeServer!.compareTo(a.runTimeServer!));
        campaign.listCampProfile!.addAll(newElements);
        _setIdCampProfile.addAll(newElements.map((item) => item.id));
        _total7Days += newElements.length;

        notifyListeners();
      }
    }
  }
}
