// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camp_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CampModel _$CampModelFromJson(Map<String, dynamic> json) => CampModel(
      campaignId: json['campaign_id'] as String?,
      campaignName: json['campaign_name'] as String?,
      status: json['status'] as String?,
      videoId: json['video_id'] as String?,
      fromDate: json['from_date'] as String?,
      toDate: json['to_date'] as String?,
      fromTime: json['from_time'] as String?,
      toTime: json['to_time'] as String?,
      daysOfWeek: json['days_of_week'] as String?,
      videoType: json['video_type'] as String?,
      urlYoutube: json['url_youtobe'] as String?,
      urlUSP: json['url_usp'] as String?,
      customerId: json['customer_id'] as String?,
      computerId: json['computer_id'] as String?,
      idDir: json['id_dir'] as String?,
      idComputer: json['id_computer'] as String?,
      videoDuration: json['video_duration'] as String?,
      approvedYn: json['approved_yn'] as String?,
      defaultYn: json['default_yn'] as String?,
      runByDefaultYn: json['run_by_default_yn'] as String?,
      isNew: json['isNew'] as bool?,
    )
      ..acceptCount = json['accept_count'] as String?
      ..acceptCustomers = json['accept_customers'] as String?
      ..isOwner = json['is_owner'] as String?;

Map<String, dynamic> _$CampModelToJson(CampModel instance) => <String, dynamic>{
      'campaign_id': instance.campaignId,
      'campaign_name': instance.campaignName,
      'status': instance.status,
      'video_id': instance.videoId,
      'from_date': instance.fromDate,
      'to_date': instance.toDate,
      'from_time': instance.fromTime,
      'to_time': instance.toTime,
      'days_of_week': instance.daysOfWeek,
      'video_type': instance.videoType,
      'url_youtobe': instance.urlYoutube,
      'customer_id': instance.customerId,
      'url_usp': instance.urlUSP,
      'computer_id': instance.computerId,
      'id_dir': instance.idDir,
      'id_computer': instance.idComputer,
      'video_duration': instance.videoDuration,
      'approved_yn': instance.approvedYn,
      'default_yn': instance.defaultYn,
      'run_by_default_yn': instance.runByDefaultYn,
      'accept_count': instance.acceptCount,
      'accept_customers': instance.acceptCustomers,
      'is_owner': instance.isOwner,
      'isNew': instance.isNew,
    };
