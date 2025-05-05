import 'package:json_annotation/json_annotation.dart';

part 'device_shared_model.g.dart';

@JsonSerializable()
class DeviceSharedModel {
  @JsonKey(name: 'computer_id')
  final String? computerId;

  @JsonKey(name: 'computer_name')
  final String? computerName;

  @JsonKey(name: 'seri_computer')
  final String? serialComputer;

  @JsonKey(name: 'customer_id')
  final String? customerIdTo;

  @JsonKey(name: 'id_dir')
  final String? idDir;

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'customer_name')
  final String? customerName;

  @JsonKey(name: 'computer_token')
  final String? computerToken;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'lasted_alive_time')
  final String? lastedAliveTime;

  @JsonKey(name: 'rom_memory_total')
  String? romMemoryTotal;

  @JsonKey(name: 'rom_memory_used')
  String? romMemoryUsed;

  @JsonKey(name: 'is_owner')
  bool? isShareOwner;

  DeviceSharedModel({
    this.computerId,
    this.computerName,
    this.serialComputer,
    this.customerIdTo,
    this.customerName,
    this.idDir,
    this.type,
    this.phoneNumber,
    this.computerToken,
    this.email,
    this.lastedAliveTime,
    this.romMemoryTotal,
    this.romMemoryUsed,
    this.isShareOwner,
  });

  factory DeviceSharedModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceSharedModelFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceSharedModelToJson(this);
}
