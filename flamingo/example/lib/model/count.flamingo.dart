// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'count.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum CountKey {
  userId,
  count,
}

extension CountKeyExtension on CountKey {
  String get value {
    switch (this) {
      case CountKey.userId:
        return 'userId';
      case CountKey.count:
        return 'count';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Count doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'userId', doc.userId);
  Helper.writeNotNull(data, 'count', doc.count);

  return data;
}

/// For load data
void _$fromData(Count doc, Map<String, dynamic> data) {
  doc.userId = Helper.valueFromKey<String>(data, 'userId');
  doc.count = Helper.valueFromKey<int>(data, 'count');
}
