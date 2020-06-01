// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// For save data
Map<String, dynamic> _$toData(User doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'name', doc.name);
  Helper.write(data, 'profile', doc.profile);
  Helper.writeNotNull(data, 'intMap', doc.intMap);
  Helper.writeNotNull(data, 'listIntMap', doc.listIntMap);

  Helper.writeModelNotNull(data, 'cartA', doc.cartA);
  Helper.writeModel(data, 'cartB', doc.cartB);
  Helper.writeModelListNotNull(data, 'carts', doc.carts);

  Helper.writeStorageNotNull(data, 'fileA', doc.fileA, isSetNull: false);
  Helper.writeStorage(data, 'image', doc.fileB, isSetNull: false);
  Helper.writeStorageListNotNull(data, 'filesA', doc.filesA, isSetNull: false);
  Helper.writeStorageList(data, 'filesB', doc.filesB, isSetNull: false);

  return data;
}

/// For load data
void _$fromData(User doc, Map<String, dynamic> data) {
  doc.name = Helper.valueFromKey<String>(data, 'name');
  doc.profile = Helper.valueFromKey<String>(data, 'profile');
  doc.intMap = Helper.valueMapFromKey<String, int>(data, 'intMap');
  doc.listIntMap = Helper.valueMapListFromKey<String, int>(data, 'listIntMap');

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
