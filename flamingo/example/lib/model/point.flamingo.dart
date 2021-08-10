// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum PointKey {
  pointInt,
  pointDouble,
}

extension PointKeyExtension on PointKey {
  String get value {
    switch (this) {
      case PointKey.pointInt:
        return 'pointInt';
      case PointKey.pointDouble:
        return 'pointDouble';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Point doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'pointInt', doc.pointInt);
  Helper.writeNotNull(data, 'pointDouble', doc.pointDouble);

  return data;
}

/// For load data
void _$fromData(Point doc, Map<String, dynamic> data) {
  doc.pointInt =
      Helper.valueFromKey<int?>(data, 'pointInt', defaultValue: null);
  doc.pointDouble =
      Helper.valueFromKey<double?>(data, 'pointDouble', defaultValue: null);
}
