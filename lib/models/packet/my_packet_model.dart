import 'package:json_annotation/json_annotation.dart';

part 'my_packet_model.g.dart';

@JsonSerializable()
class MyPacketModel {
  @JsonKey(name: 'paid_id')
  String? paidId;

  @JsonKey(name: 'packet_code')
  String? packetCode;

  @JsonKey(name: 'reg_number')
  String? regNumber;

  @JsonKey(name: 'name_packet')
  String? namePacket;

  String? price;

  @JsonKey(name: 'expire_date')
  String? expireDate;

  @JsonKey(name: 'day_qty')
  String? dayQty;

  @JsonKey(name: 'month_qty')
  String? monthQty;

  @JsonKey(name: 'year_qty')
  String? yearQty;

  @JsonKey(name: 'is_trial')
  String? isTrial;

  String? picture;
  String? description;
  String? detail;

  @JsonKey(name: 'customer_id')
  String? customerId;

  String? pay;

  @JsonKey(name: 'created_date')
  String? createdDate;

  @JsonKey(name: 'created_by')
  String? createdBy;

  @JsonKey(name: 'last_MDF_by')
  String? lastMDFBy;

  @JsonKey(name: 'last_MDF_date')
  String? lastMDFDate;

  String? deleted;

  @JsonKey(name: 'register_date')
  String? registerDate;

  @JsonKey(name: 'payment_date')
  String? paymentDate;

  @JsonKey(name: 'valid_date')
  String? validDate;

  @JsonKey(name: 'type_pay')
  String? typePay;

  @JsonKey(name: 'packet_id')
  String? packetId;

  String? type;

  @JsonKey(name: 'limit_capacity')
  String? limitCapacity;

  @JsonKey(name: 'limit_qty')
  String? limitQty;

  @JsonKey(name: 'payment_due_date')
  String? paymentDueDate;

  @JsonKey(name: 'price_6_month')
  String? price6Month;

  @JsonKey(name: 'price_12_month')
  String? price12Month;

  @JsonKey(name: 'is_business')
  String? isBusiness;

  @JsonKey(name: 'pay_month')
  String? payMonth;

  MyPacketModel({
    this.dayQty,
    this.monthQty,
    this.yearQty,
    this.isTrial,
    this.paidId,
    this.packetCode,
    this.regNumber,
    this.namePacket,
    this.price,
    this.price6Month,
    this.price12Month,
    this.isBusiness,
    this.expireDate,
    this.picture,
    this.description,
    this.detail,
    this.customerId,
    this.pay,
    this.createdDate,
    this.createdBy,
    this.lastMDFBy,
    this.lastMDFDate,
    this.deleted,
    this.registerDate,
    this.paymentDate,
    this.validDate,
    this.typePay,
    this.packetId,
    this.type,
    this.limitCapacity,
    this.limitQty,
    this.paymentDueDate,
    this.payMonth,
  });

  factory MyPacketModel.fromJson(Map<String, dynamic> json) =>
      _$MyPacketModelFromJson(json);
  Map<String, dynamic> toJson() => _$MyPacketModelToJson(this);
}
