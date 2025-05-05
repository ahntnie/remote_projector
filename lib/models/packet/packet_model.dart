import 'package:json_annotation/json_annotation.dart';

part 'packet_model.g.dart';

@JsonSerializable()
class PacketModel {
  @JsonKey(name: 'packet_id')
  String? packetId;

  @JsonKey(name: 'name_packet')
  String? namePacket;

  String? price;

  @JsonKey(name: 'day_qty')
  String? dayQty;

  @JsonKey(name: 'month_qty')
  String? monthQty;

  @JsonKey(name: 'year_qty')
  String? yearQty;

  @JsonKey(name: 'is_trial')
  String? isTrial;

  String? detail;

  String? description;

  String? picture;

  @JsonKey(name: 'expire_date')
  String? expireDate;

  @JsonKey(name: 'limit_capacity')
  String? limitCapacity;

  @JsonKey(name: 'limit_qty')
  String? limitQty;

  @JsonKey(name: 'price_6_month')
  String? price6Month;

  @JsonKey(name: 'price_12_month')
  String? price12Month;

  @JsonKey(name: 'is_business')
  String? isBusiness;

  PacketModel({
    this.packetId,
    this.namePacket,
    this.price,
    this.price6Month,
    this.price12Month,
    this.dayQty,
    this.monthQty,
    this.yearQty,
    this.isTrial,
    this.detail,
    this.description,
    this.picture,
    this.expireDate,
    this.limitCapacity,
    this.limitQty,
    this.isBusiness,
  });

  factory PacketModel.fromJson(Map<String, dynamic> json) =>
      _$PacketModelFromJson(json);
  Map<String, dynamic> toJson() => _$PacketModelToJson(this);
}
