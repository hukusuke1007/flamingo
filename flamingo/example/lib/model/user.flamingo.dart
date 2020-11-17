// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum UserKey {
  name,
  editAt,
  clearAt,

  setting,
}

extension UserKeyExtension on UserKey {
  String get value {
    switch (this) {
      case UserKey.name:
        return 'name';
      case UserKey.editAt:
        return 'editAt';
      case UserKey.clearAt:
        return 'clearAt';
      case UserKey.setting:
        return 'setting';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(User doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'name', doc.name);
  Helper.writeNotNull(data, 'editAt', doc.editAt);
  Helper.writeNotNull(data, 'clearAt', doc.clearAt);

  return data;
}

/// For load data
void _$fromData(User doc, Map<String, dynamic> data) {
  doc.name = Helper.valueFromKey<String>(data, 'name');
  if (data['editAt'] is Map) {
    doc.editAt = Helper.timestampFromMap(data, 'editAt');
  } else {
    doc.editAt = Helper.valueFromKey<Timestamp>(data, 'editAt');
  }

  if (data['clearAt'] is Map) {
    doc.clearAt = Helper.timestampFromMap(data, 'clearAt');
  } else {
    doc.clearAt = Helper.valueFromKey<Timestamp>(data, 'clearAt');
  }
}
