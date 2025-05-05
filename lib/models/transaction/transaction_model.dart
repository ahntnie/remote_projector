import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  @JsonKey(name: 'transaction_id')
  final String? transactionId;

  @JsonKey(name: 'paid_id')
  final String? paidId;

  @JsonKey(name: 'reg_number')
  final String? regNumber;

  @JsonKey(name: 'packet_id')
  final String? packetId;

  @JsonKey(name: 'customer_id')
  final String? customerId;

  @JsonKey(name: 'payment_date')
  final String? paymentDate;

  final String? amount;

  @JsonKey(name: 'ref_transaction_id')
  final String? refTransactionId;

  @JsonKey(name: 'name_packet')
  final String? namePacket;

  TransactionModel({
    this.transactionId,
    this.paidId,
    this.regNumber,
    this.packetId,
    this.customerId,
    this.paymentDate,
    this.amount,
    this.refTransactionId,
    this.namePacket,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}
