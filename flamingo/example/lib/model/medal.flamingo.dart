// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medal.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum MedalKey {
  name,
}

extension MedalKeyExtension on MedalKey {
  String get value {
    switch (this) {
      case MedalKey.name:
        return 'name';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Medal doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'name', doc.name);

  return data;
}

/// For load data
void _$fromData(Medal doc, Map<String, dynamic> data) {
  doc.name = Helper.valueFromKey<String>(data, 'name');
}
