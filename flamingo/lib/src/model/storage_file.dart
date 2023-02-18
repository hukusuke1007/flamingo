part 'storage_file.g.dart';

class StorageFile {
  StorageFile({
    required this.name,
    required this.path,
    required this.url,
    this.mimeType = 'application/octet-stream',
    this.additionalData = const <String, dynamic>{},
    this.metadata = const <String, String>{},
  });
  factory StorageFile.fromJson(Map<String, dynamic> json) =>
      _$StorageFileFromJson(json);

  bool get isDeleted => _isDeleted;
  bool _isDeleted = false;

  final String name;
  final String path;
  final String url;
  final String mimeType;
  final Map<String, dynamic>? additionalData;
  final Map<String, String>? metadata;

  Map<String, dynamic> toJson() => _$StorageFileToJson(this);

  void deleted() => _isDeleted = true;
}
