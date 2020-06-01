// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// For save data
Map<String, dynamic> _$toData(Cart doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'itemA', doc.itemA);
  Helper.writeNotNull(data, 'itemB', doc.itemB);
  Helper.writeNotNull(data, 'itemC', doc.itemC);

  return data;
}

/// For load data
void _$fromData(Cart doc, Map<String, dynamic> data) {
  doc.itemA = Helper.valueFromKey<String>(data, 'itemA');
  doc.itemB = Helper.valueFromKey<int>(data, 'itemB');
  doc.itemC = Helper.valueFromKey<double>(data, 'itemC');
}
