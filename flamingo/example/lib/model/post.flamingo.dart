// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum PostKey {
  file,
  files,
}

extension PostKeyExtension on PostKey {
  String get value {
    switch (this) {
      case PostKey.file:
        return 'file';
      case PostKey.files:
        return 'files';
      default:
        throw Exception('Invalid data key. key: FieldValueGenerator');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Post doc) {
  final data = <String, dynamic>{};

  Helper.writeStorageNotNull(data, 'file', doc.file, isSetNull: true);
  Helper.writeStorageListNotNull(data, 'files', doc.files, isSetNull: true);

  return data;
}

/// For load data
void _$fromData(Post doc, Map<String, dynamic> data) {
  doc.file = Helper.storageFile(data, 'file');
  doc.files = Helper.storageFiles(data, 'files');
}
