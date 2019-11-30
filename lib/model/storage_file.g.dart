// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageFile _$StorageFileFromJson(Map<String, dynamic> json) {
  return StorageFile(
    name: json['name'] as String,
    path: json['path'] as String,
    url: json['url'] as String,
    mimeType: json['mimeType'] as String,
    additionalData: json['additionalData'] != null
        ? Map<String, dynamic>.from(json['additionalData'] as Map)
        : null,
    metadata: json['metadata'] != null
        ? Map<String, String>.from(json['metadata'] as Map)
        : null,
  );
}

Map<String, dynamic> _$StorageFileToJson(StorageFile instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'url': instance.url,
      'mimeType': instance.mimeType,
      'additionalData': instance.additionalData,
      'metadata': instance.metadata,
    };
