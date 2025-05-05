// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceModel _$ResourceModelFromJson(Map<String, dynamic> json) =>
    ResourceModel(
      path: json['path'] as String?,
      name: json['name'] as String?,
      creationTime: json['creation_time'] as String?,
      modificationTime: json['modification_time'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt(),
      fileType: json['file_type'] as String?,
    );

Map<String, dynamic> _$ResourceModelToJson(ResourceModel instance) =>
    <String, dynamic>{
      'path': instance.path,
      'name': instance.name,
      'creation_time': instance.creationTime,
      'modification_time': instance.modificationTime,
      'file_size': instance.fileSize,
      'file_type': instance.fileType,
    };
