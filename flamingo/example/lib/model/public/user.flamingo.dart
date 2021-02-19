// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum UserKey {
  name,

  setting,
}

extension UserKeyExtension on UserKey {
  String get value {
    switch (this) {
      case UserKey.name:
        return 'name';
      case UserKey.setting:
        return 'setting';
      default:
        throw Exception('Invalid data key. key: FieldValueGenerator');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(User doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'name', doc.name);

  return data;
}

/// For load data
void _$fromData(User doc, Map<String, dynamic> data) {
  doc.name = Helper.valueFromKey<String>(data, 'name');
}
