// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// FieldValueKey
enum ItemFieldValueKey {
  name,
}

extension ItemFieldValueKeyExtension on ItemFieldValueKey {
  String get value {
    switch (this) {
      case ItemFieldValueKey.name:
        return 'name';
      default:
        return toString();
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Item doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'name', doc.name);

  return data;
}

/// For load data
void _$fromData(Item doc, Map<String, dynamic> data) {
  doc.name = Helper.valueFromKey<String>(data, 'name');
}
