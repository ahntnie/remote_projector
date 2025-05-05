import 'package:json_annotation/json_annotation.dart';

part 'resource_model.g.dart';

@JsonSerializable()
class ResourceModel {
  final String? path;
  final String? name;

  @JsonKey(name: 'creation_time')
  final String? creationTime;

  @JsonKey(name: 'modification_time')
  final String? modificationTime;

  @JsonKey(name: 'file_size')
  final int? fileSize;

  @JsonKey(name: 'file_type')
  final String? fileType;

  ResourceModel({
    this.path,
    this.name,
    this.creationTime,
    this.modificationTime,
    this.fileSize,
    this.fileType,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) =>
      _$ResourceModelFromJson(json);
  Map<String, dynamic> toJson() => _$ResourceModelToJson(this);
}
