import 'package:json_annotation/json_annotation.dart';

part 'storage_file.g.dart';

@JsonSerializable(nullable: true)
class StorageFile {
  StorageFile({this.name, this.url, this.mimeType});
  factory StorageFile.fromJson(Map<String, dynamic> json) => _$StorageFileFromJson(json);

  @JsonKey(ignore: true)
  bool isDeleted = false;

  String name;
  String url;
  String mimeType;

  Map<String, dynamic> toJson() => _$StorageFileToJson(this);
}