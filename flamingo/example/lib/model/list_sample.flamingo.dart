// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_sample.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum ListSampleKey {
  strList,
  intList,
  doubleList,
  boolList,

  filesA,
  filesB,
}

extension ListSampleKeyExtension on ListSampleKey {
  String get value {
    switch (this) {
      case ListSampleKey.strList:
        return 'strList';
      case ListSampleKey.intList:
        return 'intList';
      case ListSampleKey.doubleList:
        return 'doubleList';
      case ListSampleKey.boolList:
        return 'boolList';
      case ListSampleKey.filesA:
        return 'filesA';
      case ListSampleKey.filesB:
        return 'filesB';
      default:
        return toString();
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(ListSample doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'strList', doc.strList);
  Helper.writeNotNull(data, 'intList', doc.intList);
  Helper.writeNotNull(data, 'doubleList', doc.doubleList);
  Helper.writeNotNull(data, 'boolList', doc.boolList);

  Helper.writeStorageListNotNull(data, 'filesA', doc.filesA, isSetNull: true);
  Helper.writeStorageList(data, 'filesB', doc.filesB, isSetNull: true);

  return data;
}

/// For load data
void _$fromData(ListSample doc, Map<String, dynamic> data) {
  doc.strList = Helper.valueListFromKey<String>(data, 'strList');
  doc.intList = Helper.valueListFromKey<int>(data, 'intList');
  doc.doubleList = Helper.valueListFromKey<double>(data, 'doubleList');
  doc.boolList = Helper.valueListFromKey<bool>(data, 'boolList');

  doc.filesA = Helper.storageFiles(data, 'filesA');
  doc.filesB = Helper.storageFiles(data, 'filesB');
}
