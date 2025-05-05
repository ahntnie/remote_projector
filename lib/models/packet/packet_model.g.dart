// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PacketModel _$PacketModelFromJson(Map<String, dynamic> json) => PacketModel(
      packetId: json['packet_id'] as String?,
      namePacket: json['name_packet'] as String?,
      price: json['price'] as String?,
      price6Month: json['price_6_month'] as String?,
      price12Month: json['price_12_month'] as String?,
      dayQty: json['day_qty'] as String?,
      monthQty: json['month_qty'] as String?,
      yearQty: json['year_qty'] as String?,
      isTrial: json['is_trial'] as String?,
      detail: json['detail'] as String?,
      description: json['description'] as String?,
      picture: json['picture'] as String?,
      expireDate: json['expire_date'] as String?,
      limitCapacity: json['limit_capacity'] as String?,
      limitQty: json['limit_qty'] as String?,
      isBusiness: json['is_business'] as String?,
    );

Map<String, dynamic> _$PacketModelToJson(PacketModel instance) =>
    <String, dynamic>{
      'packet_id': instance.packetId,
      'name_packet': instance.namePacket,
      'price': instance.price,
      'day_qty': instance.dayQty,
      'month_qty': instance.monthQty,
      'year_qty': instance.yearQty,
      'is_trial': instance.isTrial,
      'detail': instance.detail,
      'description': instance.description,
      'picture': instance.picture,
      'expire_date': instance.expireDate,
      'limit_capacity': instance.limitCapacity,
      'limit_qty': instance.limitQty,
      'price_6_month': instance.price6Month,
      'price_12_month': instance.price12Month,
      'is_business': instance.isBusiness,
    };
