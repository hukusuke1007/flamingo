// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum SettingKey {
  isEnable,
}

extension SettingKeyExtension on SettingKey {
  String get value {
    switch (this) {
      case SettingKey.isEnable:
        return 'isEnable';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Setting doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'isEnable', doc.isEnable);

  return data;
}

/// For load data
void _$fromData(Setting doc, Map<String, dynamic> data) {
  doc.isEnable = Helper.valueFromKey<bool>(data, 'isEnable');
}
