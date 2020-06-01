// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// FieldValueKey
enum UserFieldValueKey {
  name,
}

extension UserFieldValueKeyExtension on UserFieldValueKey {
  String get value {
    switch (this) {
      case UserFieldValueKey.name:
        return 'name';

      default:
        return toString();
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
