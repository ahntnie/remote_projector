// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_shared_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceSharedModel _$DeviceSharedModelFromJson(Map<String, dynamic> json) =>
    DeviceSharedModel(
      computerId: json['computer_id'] as String?,
      computerName: json['computer_name'] as String?,
      serialComputer: json['seri_computer'] as String?,
      customerIdTo: json['customer_id'] as String?,
      customerName: json['customer_name'] as String?,
      idDir: json['id_dir'] as String?,
      type: json['type'] as String?,
      phoneNumber: json['phone_number'] as String?,
      computerToken: json['computer_token'] as String?,
      email: json['email'] as String?,
      lastedAliveTime: json['lasted_alive_time'] as String?,
      romMemoryTotal: json['rom_memory_total'] as String?,
      romMemoryUsed: json['rom_memory_used'] as String?,
      isShareOwner: json['is_owner'] as bool?,
    );

Map<String, dynamic> _$DeviceSharedModelToJson(DeviceSharedModel instance) =>
    <String, dynamic>{
      'computer_id': instance.computerId,
      'computer_name': instance.computerName,
      'seri_computer': instance.serialComputer,
      'customer_id': instance.customerIdTo,
      'id_dir': instance.idDir,
      'type': instance.type,
      'customer_name': instance.customerName,
      'computer_token': instance.computerToken,
      'phone_number': instance.phoneNumber,
      'email': instance.email,
      'lasted_alive_time': instance.lastedAliveTime,
      'rom_memory_total': instance.romMemoryTotal,
      'rom_memory_used': instance.romMemoryUsed,
      'is_owner': instance.isShareOwner,
    };
