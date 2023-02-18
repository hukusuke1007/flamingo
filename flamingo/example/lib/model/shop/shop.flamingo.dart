// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum ShopKey {
  name,
  cart,
  carts,
}

extension ShopKeyExtension on ShopKey {
  String get value {
    switch (this) {
      case ShopKey.name:
        return 'name';
      case ShopKey.cart:
        return 'cart';
      case ShopKey.carts:
        return 'carts';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Shop doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'name', doc.name);

  Helper.writeModelNotNull(data, 'cart', doc.cart);
  Helper.writeModelListNotNull(data, 'carts', doc.carts);

  return data;
}

/// For load data
void _$fromData(Shop doc, Map<String, dynamic> data) {
  doc.name = Helper.valueFromKey<String?>(data, 'name', defaultValue: null);

  final _cart = Helper.valueMapFromKey<String, dynamic>(data, 'cart');
  if (_cart != null) {
    doc.cart = Cart(values: _cart);
  } else {
    doc.cart = null;
  }

  final _carts = Helper.valueMapListFromKey<String, dynamic>(data, 'carts');
  if (_carts != null) {
    doc.carts = _carts.map((d) => Cart(values: d)).toList();
  } else {
    doc.carts = null;
  }
}
