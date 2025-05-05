import 'package:json_annotation/json_annotation.dart';

part 'dir_shared_model.g.dart';

@JsonSerializable()
class DirSharedModel {
  @JsonKey(name: 'id_dir')
  final String? idDir;

  @JsonKey(name: 'name_dir')
  final String? nameDir;

  @JsonKey(name: 'customer_id')
  final String? customerId;

  @JsonKey(name: 'customer_idto')
  final String? customerIdTo;

  @JsonKey(name: 'type_dir')
  final String? typeDir;

  @JsonKey(name: 'customer_name')
  final String? customerName;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @JsonKey(name: 'email')
  final String? email;

  DirSharedModel({
    this.idDir,
    this.nameDir,
    this.customerId,
    this.customerIdTo,
    this.customerName,
    this.typeDir,
    this.phoneNumber,
    this.email,
  });

  factory DirSharedModel.fromJson(Map<String, dynamic> json) =>
      _$DirSharedModelFromJson(json);
  Map<String, dynamic> toJson() => _$DirSharedModelToJson(this);
}
