// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum UserKey {
  name,
  note,
  editAt,
  clearAt,
  isValue,

  setting,
}

extension UserKeyExtension on UserKey {
  String get value {
    switch (this) {
      case UserKey.name:
        return 'name';
      case UserKey.note:
        return 'note';
      case UserKey.editAt:
        return 'editAt';
      case UserKey.clearAt:
        return 'clearAt';
      case UserKey.isValue:
        return 'isValue';
      case UserKey.setting:
        return 'setting';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(User doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'name', doc.name);
  Helper.writeNotNull(data, 'note', doc.note);
  Helper.writeNotNull(data, 'editAt', doc.editAt);
  Helper.writeNotNull(data, 'clearAt', doc.clearAt);
  Helper.writeNotNull(data, 'isValue', doc.isValue);

  return data;
}

/// For load data
void _$fromData(User doc, Map<String, dynamic> data) {
  doc.name = Helper.valueFromKey<String?>(data, 'name', defaultValue: null);
  doc.note = Helper.valueFromKey<String?>(data, 'note', defaultValue: null);
  if (data['editAt'] is Map) {
    doc.editAt = Helper.timestampFromMap(data, 'editAt');
  } else {
    doc.editAt =
        Helper.valueFromKey<Timestamp?>(data, 'editAt', defaultValue: null);
  }

  if (data['clearAt'] is Map) {
    doc.clearAt = Helper.timestampFromMap(data, 'clearAt');
  } else {
    doc.clearAt =
        Helper.valueFromKey<Timestamp?>(data, 'clearAt', defaultValue: null);
  }

  doc.isValue = Helper.valueFromKey<bool?>(data, 'isValue', defaultValue: null);
}
