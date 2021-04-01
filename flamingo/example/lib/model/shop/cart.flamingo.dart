// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum CartKey {
  ref,
  collectionRef,
}

extension CartKeyExtension on CartKey {
  String get value {
    switch (this) {
      case CartKey.ref:
        return 'ref';
      case CartKey.collectionRef:
        return 'collectionRef';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Cart doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'ref', doc.ref);
  Helper.writeNotNull(data, 'collectionRef', doc.collectionRef);

  return data;
}

/// For load data
void _$fromData(Cart doc, Map<String, dynamic> data) {
  doc.ref = Helper.valueFromKey<String?>(data, 'ref');
  doc.collectionRef = Helper.valueFromKey<String?>(data, 'collectionRef');
}
