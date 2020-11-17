// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_sample.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum MapSampleKey {
  strMap,
  intMap,
  doubleMap,
  boolMap,
  listStrMap,
}

extension MapSampleKeyExtension on MapSampleKey {
  String get value {
    switch (this) {
      case MapSampleKey.strMap:
        return 'strMap';
      case MapSampleKey.intMap:
        return 'intMap';
      case MapSampleKey.doubleMap:
        return 'doubleMap';
      case MapSampleKey.boolMap:
        return 'boolMap';
      case MapSampleKey.listStrMap:
        return 'listStrMap';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(MapSample doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'strMap', doc.strMap);
  Helper.writeNotNull(data, 'intMap', doc.intMap);
  Helper.writeNotNull(data, 'doubleMap', doc.doubleMap);
  Helper.writeNotNull(data, 'boolMap', doc.boolMap);
  Helper.writeNotNull(data, 'listStrMap', doc.listStrMap);

  return data;
}

/// For load data
void _$fromData(MapSample doc, Map<String, dynamic> data) {
  doc.strMap = Helper.valueMapFromKey<String, String>(data, 'strMap');
  doc.intMap = Helper.valueMapFromKey<String, int>(data, 'intMap');
  doc.doubleMap = Helper.valueMapFromKey<String, double>(data, 'doubleMap');
  doc.boolMap = Helper.valueMapFromKey<String, bool>(data, 'boolMap');
  doc.listStrMap =
      Helper.valueMapListFromKey<String, String>(data, 'listStrMap');
}
