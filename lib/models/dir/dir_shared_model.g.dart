// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dir_shared_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirSharedModel _$DirSharedModelFromJson(Map<String, dynamic> json) =>
    DirSharedModel(
      idDir: json['id_dir'] as String?,
      nameDir: json['name_dir'] as String?,
      customerId: json['customer_id'] as String?,
      customerIdTo: json['customer_idto'] as String?,
      customerName: json['customer_name'] as String?,
      typeDir: json['type_dir'] as String?,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$DirSharedModelToJson(DirSharedModel instance) =>
    <String, dynamic>{
      'id_dir': instance.idDir,
      'name_dir': instance.nameDir,
      'customer_id': instance.customerId,
      'customer_idto': instance.customerIdTo,
      'type_dir': instance.typeDir,
      'customer_name': instance.customerName,
      'phone_number': instance.phoneNumber,
      'email': instance.email,
    };
