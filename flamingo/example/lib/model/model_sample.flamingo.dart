// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_sample.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum ModelSampleKey {
  name,
  strList,
  strMap,
  listStrMap,

  file,
}

extension ModelSampleKeyExtension on ModelSampleKey {
  String get value {
    switch (this) {
      case ModelSampleKey.name:
        return 'name';
      case ModelSampleKey.strList:
        return 'strList';
      case ModelSampleKey.strMap:
        return 'strMap';
      case ModelSampleKey.listStrMap:
        return 'listStrMap';
      case ModelSampleKey.file:
        return 'file';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(ModelSample doc) {
  final data = <String, dynamic>{};
  Helper.write(data, 'name', doc.name);
  Helper.write(data, 'strList', doc.strList);
  Helper.write(data, 'strMap', doc.strMap);
  Helper.write(data, 'listStrMap', doc.listStrMap);

  Helper.writeStorage(data, 'file', doc.file, isSetNull: true);

  return data;
}

/// For load data
void _$fromData(ModelSample doc, Map<String, dynamic> data) {
  doc.name = Helper.valueFromKey<String?>(data, 'name', defaultValue: null);
  doc.strList = Helper.valueListFromKey<String>(data, 'strList');
  doc.strMap = Helper.valueMapFromKey<String, String>(data, 'strMap');
  doc.listStrMap =
      Helper.valueMapListFromKey<String, String>(data, 'listStrMap');

  doc.file = Helper.storageFile(data, 'file');
}
