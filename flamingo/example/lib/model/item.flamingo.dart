// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum ItemKey {
  name,
}

extension ItemKeyExtension on ItemKey {
  String get value {
    switch (this) {
      case ItemKey.name:
        return 'name';
      default:
        throw Exception('Invalid data key. key: FieldValueGenerator');
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
