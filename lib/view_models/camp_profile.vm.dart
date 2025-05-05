import 'package:stacked/stacked.dart';

import '../models/camp/camp_model.dart';
import '../models/camp/camp_profile_model.dart';
import '../requests/camp/camp.request.dart';

class CampProfileViewModel extends BaseViewModel {
  CampProfileViewModel({required this.campModel});

  final CampModel campModel;
  final CampRequest _campRequest = CampRequest();

  final List<CampProfileModel> _listCampProfile = [];
  List<CampProfileModel> get listCampProfile => _listCampProfile;

  Future<void> initialise() async {
    setBusy(true);
    await _fetchCampProfile();
    setBusy(false);
  }

  Future<void> _fetchCampProfile() async {
    List<CampProfileModel> list = await _campRequest.getCampaignRunProfile(
      campaignId: campModel.campaignId,
      fromDate: campModel.fromDate,
      toDate: campModel.toDate,
    );
    _listCampProfile.clear();
    _listCampProfile.addAll(list);
  }
}
