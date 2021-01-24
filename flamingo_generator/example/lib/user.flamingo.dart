// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum UserKey {
  name,
  profile,
  strList,
  intMap,
  listIntMap,
  point,
  score,
  cartA,
  cartB,
  carts,
  fileA,
  fileB,
  filesA,
  filesB,
  item,
}

extension UserKeyExtension on UserKey {
  String get value {
    switch (this) {
      case UserKey.name:
        return 'name';
      case UserKey.profile:
        return 'profile';
      case UserKey.strList:
        return 'strList';
      case UserKey.intMap:
        return 'intMap';
      case UserKey.listIntMap:
        return 'listIntMap';
      case UserKey.point:
        return 'point';
      case UserKey.score:
        return 'score';
      case UserKey.cartA:
        return 'cartA';
      case UserKey.cartB:
        return 'cartB';
      case UserKey.carts:
        return 'carts';
      case UserKey.fileA:
        return 'fileA';
      case UserKey.fileB:
        return 'fileB';
      case UserKey.filesA:
        return 'filesA';
      case UserKey.filesB:
        return 'filesB';
      case UserKey.item:
        return 'item';
      default:
        throw Exception('Invalid data key. key: FieldValueGenerator');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(User doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'name', doc.name);
  Helper.write(data, 'profile', doc.profile);
  Helper.writeNotNull(data, 'strList', doc.strList);
  Helper.writeNotNull(data, 'intMap', doc.intMap);
  Helper.writeNotNull(data, 'listIntMap', doc.listIntMap);
  Helper.writeIncrement(data, doc.point, 'point');
  Helper.writeIncrement(data, doc.score, 'score');

  Helper.writeModelNotNull(data, 'cartA', doc.cartA);
  Helper.writeModel(data, 'cartB', doc.cartB);
  Helper.writeModelListNotNull(data, 'carts', doc.carts);

  Helper.writeStorageNotNull(data, 'fileA', doc.fileA, isSetNull: true);
  Helper.writeStorage(data, 'image', doc.fileB, isSetNull: true);
  Helper.writeStorageListNotNull(data, 'filesA', doc.filesA, isSetNull: true);
  Helper.writeStorageList(data, 'filesB', doc.filesB, isSetNull: true);

  return data;
}

/// For load data
void _$fromData(User doc, Map<String, dynamic> data) {
  doc.name = Helper.valueFromKey<String>(data, 'name');
  doc.profile = Helper.valueFromKey<String>(data, 'profile');
  doc.strList = Helper.valueListFromKey<String>(data, 'strList');
  doc.intMap = Helper.valueMapFromKey<String, int>(data, 'intMap');
  doc.listIntMap = Helper.valueMapListFromKey<String, int>(data, 'listIntMap');
  doc.point = Helper.valueFromIncrement<int>(data, 'point');
  doc.score = Helper.valueFromIncrement<double>(data, 'score');

  final _cartA = Helper.valueMapFromKey<String, dynamic>(data, 'cartA');
  if (_cartA != null) {
    doc.cartA = Cart(values: _cartA);
  } else {
    doc.cartA = null;
  }

  final _cartB = Helper.valueMapFromKey<String, dynamic>(data, 'cartB');
  if (_cartB != null) {
    doc.cartB = Cart(values: _cartB);
  } else {
    doc.cartB = null;
  }

  final _carts = Helper.valueMapListFromKey<String, dynamic>(data, 'carts');
  if (_carts != null) {
    doc.carts =
        _carts.where((d) => d != null).map((d) => Cart(values: d)).toList();
  } else {
    doc.carts = null;
  }

  doc.fileA = Helper.storageFile(data, 'fileA');
  doc.fileB = Helper.storageFile(data, 'image');
  doc.filesA = Helper.storageFiles(data, 'filesA');
  doc.filesB = Helper.storageFiles(data, 'filesB');
}
