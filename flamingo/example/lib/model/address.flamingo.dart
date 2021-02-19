// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum AddressKey {
  postCode,
  country,
}

extension AddressKeyExtension on AddressKey {
  String get value {
    switch (this) {
      case AddressKey.postCode:
        return 'postCode';
      case AddressKey.country:
        return 'country';
      default:
        throw Exception('Invalid data key. key: FieldValueGenerator');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Address doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'postCode', doc.postCode);
  Helper.writeNotNull(data, 'country', doc.country);

  return data;
}

/// For load data
void _$fromData(Address doc, Map<String, dynamic> data) {
  doc.postCode = Helper.valueFromKey<String>(data, 'postCode');
  doc.country = Helper.valueFromKey<String>(data, 'country');
}
