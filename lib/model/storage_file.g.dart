// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageFile _$StorageFileFromJson(Map<String, dynamic> json) {
  return StorageFile(
    name: json['name'] as String,
    url: json['url'] as String,
    mimeType: json['mimeType'] as String,
    metadata: json['metadata'] != null ? Map<String, String>.from(json['metadata'] as Map) : null,
  );
}

Map<String, dynamic> _$StorageFileToJson(StorageFile instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'mimeType': instance.mimeType,
      'metadata': instance.metadata,
    };
