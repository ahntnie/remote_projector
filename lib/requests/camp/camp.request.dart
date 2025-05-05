import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../constants/app_api.dart';
import '../../constants/app_constants.dart';
import '../../models/camp/camp_model.dart';
import '../../models/camp/camp_profile_model.dart';
import '../../models/camp/camp_statistics_model.dart';
import '../../models/camp/time_run_model.dart';
import '../../models/response/response_result.dart';
import '../../models/user/user.dart';

class CampRequest {
  final Dio _dio = Dio();

  Future<List<TimeRunModel>> getTimeRunCampById(String? campaignId) async {
    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.getTimeRunByCampId}/$campaignId',
      );

      final responseData = jsonDecode(response.data);

      List<dynamic> list = responseData['camp_list_time'];
      List<TimeRunModel> listTime = list.isNotEmpty
          ? list.map((e) => TimeRunModel.fromJson(e)).toList()
          : [];

      return listTime;
    } catch (_) {}

    return [];
  }

  Future<List<TimeRunModel>> getTimeRunCampById_1(
      String? campaignId, String? idDir) async {
    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.getTimeRunByCampId1}/$campaignId/$idDir',
      );
      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['camp_list_time'];
      List<TimeRunModel> listTime = list.isNotEmpty
          ? list.map((e) => TimeRunModel.fromJson(e)).toList()
          : [];

      return listTime;
    } catch (_) {}

    return [];
  }

  Future<List<CampStatisticsModel>> getCampaignRunProfileGeneral(
      {String? fromDate, String? toDate}) async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
      final formData = FormData.fromMap({
        'customer_id': currentUser.customerId,
        'from_date': fromDate,
        'to_date': toDate,
      });

      final response = await _dio.post(
        '${Api.hostApi}${Api.getStatisticsCampaignRunProfileGeneral}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Profile_list'];
      List<CampStatisticsModel> listCampStatistic = list.isNotEmpty
          ? list.map((e) => CampStatisticsModel.fromJson(e)).toList()
          : [];

      return listCampStatistic;
    } catch (_) {}

    return [];
  }

  Future<void> addTimeRunByCampaignId(
      TimeRunModel time, String? campaignId) async {
    final formData = FormData.fromMap({
      'campaign_id': campaignId,
      'from_time': time.fromTime,
      'to_time': time.toTime,
    });
    try {
      await _dio.post(
        '${Api.hostApi}${Api.addTimeRunByCampaignId}',
        data: formData,
      );
    } catch (_) {}
  }

  Future<void> updateTimeRunByIdRun(TimeRunModel time) async {
    final formData = FormData.fromMap({
      'id_run': time.idRun,
      'from_time': time.fromTime,
      'to_time': time.toTime,
    });
    
    try {
      await _dio.post(
        '${Api.hostApi}${Api.updateTimeRunByIdRun}',
        data: formData,
      );
    } catch (_) {}
  }

  Future<void> updateRunByDefaultByCampaignId(
      String? campaignId, bool used) async {
    try {
      await _dio.get(
        '${Api.hostApi}${Api.updateRunByDefaultByCampaignId}/$campaignId/${used ? '1' : '0'}',
      );
    } catch (_) {}
  }

  Future<void> deleteTimeRunByIdRun(TimeRunModel time) async {
    try {
      await _dio.get(
        '${Api.hostApi}${Api.deleteTimRunByIdRun}/${time.idRun}',
      );
    } catch (_) {}
  }

  Future<List<CampModel>> getCampSharedByIdCustomer() async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

      final response = await _dio.get(
        '${Api.hostApi}${Api.getCampSharedByIdCustomer}/${currentUser.customerId}',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Camp_list'];
      List<CampModel> listCamp = list.isNotEmpty
          ? list.map((e) => CampModel.fromJson(e)).toList()
          : [];

      return listCamp;
    } catch (_) {}

    return [];
  }

  Future<List<CampModel>> getAllCampByIdCustomer() async {
    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));

      final response = await _dio.get(
        '${Api.hostApi}${Api.getAllCampByIdCustomer}/${currentUser.customerId}',
      );
      print('api: ${Api.hostApi}${Api.getAllCampByIdCustomer}/${currentUser.customerId}');
      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['camp_list'];
      List<CampModel> listCamp = list.isNotEmpty
          ? list.map((e) => CampModel.fromJson(e)).toList()
          : [];

      return listCamp;
    } catch (_) {}

    return [];
  }

  Future<List<CampModel>> getCampByIdDeviceWithFilter(String? deviceId,
      {String? status = 'all'}) async {
    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.getCampByIdDevice}/$deviceId/$status',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Camp_list'];
      List<CampModel> listCamp = list.isNotEmpty
          ? list.map((e) => CampModel.fromJson(e)).toList()
          : [];

      return listCamp;
    } catch (_) {}

    return [];
  }

  Future<List<CampModel>> getCampByIdDirectoryWithFilter(String? dirId,
      {String status = 'all'}) async {
    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.getCampaignByDirectoryId}/$dirId/$status',
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Camp_list'];
      List<CampModel> listCamp = list.isNotEmpty
          ? list.map((e) => CampModel.fromJson(e)).toList()
          : [];
      for (var camp in listCamp) {
        camp.listTimeRun = await getTimeRunCampById(camp.campaignId);
      }
      return listCamp;
    } catch (_) {}

    return [];
  }

  Future<ResponseResult<String?>> createCamp(CampModel camp) async {
    dynamic error;

    final formData = FormData.fromMap({
      ...camp.toJson(),
      'url_yotobe': camp.urlYoutube,
    });
    try {
      final response = await _dio.post(
        '${Api.hostApi}${Api.createCamp}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);
      int status = responseData['status'];

      if (status == AppConstants.statusSuccess) {
        return ResponseResult.success(responseData['msg']);
      } else if (status == AppConstants.statusShowMessage) {
        return ResponseResult.error(responseData['msg']);
      }
    } catch (e) {
      error = e;
    }

    return getErrorFromException(error: error);
  }

  Future<ResponseResult<bool>> updateCamp(CampModel camp) async {
    dynamic error;
    final formData = FormData.fromMap({
      ...camp.toJson(),
      'url_yotobe': camp.urlYoutube,
    });

    try {
      final response = await _dio.post(
        '${Api.hostApi}${Api.updateCampById}/${camp.campaignId}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);
      int status = responseData['status'];
      print('responseData: $responseData');
      if (status == AppConstants.statusSuccess) {
        return ResponseResult.success(true);
      } else if (status == AppConstants.statusShowMessage) {
        return ResponseResult.error(responseData['msg']);
      }
    } catch (e) {
      error = e;
    }

    return getErrorFromException(error: error);
  }

  Future<ResponseResult<bool>> updateDefaultCampById(String? campaignId) async {
    dynamic error;

    try {
      final response = await _dio.get(
        '${Api.hostApi}/${Api.updateDefaultCampById}/$campaignId',
      );
      final responseData = jsonDecode(response.data);
      int status = responseData['status'];

      if (status == AppConstants.statusSuccess) {
        return ResponseResult.success(true);
      } else if (status == AppConstants.statusShowMessage) {
        return ResponseResult.error(responseData['msg']);
      }
    } catch (e) {
      error = e;
    }

    return getErrorFromException(error: error);
  }

  Future<ResponseResult<bool>> deleteCamp(String? campaignId) async {
    dynamic error;

    try {
      final response = await _dio.get(
        '${Api.hostApi}${Api.deleteCampById}/$campaignId',
      );

      final responseData = jsonDecode(response.data);
      int status = responseData['status'];

      if (status == AppConstants.statusSuccess) {
        return ResponseResult.success(true);
      } else if (status == AppConstants.statusShowMessage) {
        return ResponseResult.error(responseData['msg']);
      }
    } catch (e) {
      error = e;
    }

    return getErrorFromException(error: error);
  }

  Future<List<CampProfileModel>> getCampaignRunProfile(
      {String? campaignId, String? fromDate, String? toDate}) async {
    final formData = FormData.fromMap({
      'campaign_id': campaignId,
      'from_date': fromDate,
      'to_date': toDate,
    });

    try {
      final response = await _dio.post(
        '${Api.hostApi}${Api.getCampaignRunProfile}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['Profile_list'];
      List<CampProfileModel> listCamp = list.isNotEmpty
          ? list.map((e) => CampProfileModel.fromJson(e)).toList()
          : [];

      return listCamp;
    } catch (_) {}

    return [];
  }

  Future<ResponseResult<bool>> updateStatusApproveCampaign(
      String? campaignId, int? status) async {
    final formData = FormData.fromMap({
      'approved_yn': status,
      'customer_id': User.fromJson(
        jsonDecode(AppSP.get(AppSPKey.userInfo)),
      ).customerId,
    });

    dynamic error;

    try {
      final response = await _dio.post(
        '${Api.hostApi}${Api.updateStatusCampaign}/$campaignId',
        data: formData,
      );
      final responseData = jsonDecode(response.data);
      int status = responseData['status'];

      if (status == AppConstants.statusSuccess) {
        return ResponseResult.success(true);
      } else if (status == AppConstants.statusShowMessage) {
        return ResponseResult.error(responseData['msg']);
      }
    } catch (e) {
      error = e;
    }

    return getErrorFromException(error: error);
  }
}
