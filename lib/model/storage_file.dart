import 'package:json_annotation/json_annotation.dart';

part 'storage_file.g.dart';

@JsonSerializable(nullable: true)
class StorageFile {
  StorageFile({this.name, this.url, this.mimeType});

  @JsonKey(ignore: true)
  bool isDeleted = false;

  String name;
  String url;
  String mimeType;

  factory StorageFile.fromJson(Map<String, dynamic> json) => _$StorageFileFromJson(json);
  Map<String, dynamic> toJson() => _$StorageFileToJson(this);
}