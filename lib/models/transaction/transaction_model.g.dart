// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      transactionId: json['transaction_id'] as String?,
      paidId: json['paid_id'] as String?,
      regNumber: json['reg_number'] as String?,
      packetId: json['packet_id'] as String?,
      customerId: json['customer_id'] as String?,
      paymentDate: json['payment_date'] as String?,
      amount: json['amount'] as String?,
      refTransactionId: json['ref_transaction_id'] as String?,
      namePacket: json['name_packet'] as String?,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'transaction_id': instance.transactionId,
      'paid_id': instance.paidId,
      'reg_number': instance.regNumber,
      'packet_id': instance.packetId,
      'customer_id': instance.customerId,
      'payment_date': instance.paymentDate,
      'amount': instance.amount,
      'ref_transaction_id': instance.refTransactionId,
      'name_packet': instance.namePacket,
    };
