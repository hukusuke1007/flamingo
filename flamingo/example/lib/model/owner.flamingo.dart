// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum OwnerKey {
  name,
  address,
  medals,
}

extension OwnerKeyExtension on OwnerKey {
  String get value {
    switch (this) {
      case OwnerKey.name:
        return 'name';
      case OwnerKey.address:
        return 'address';
      case OwnerKey.medals:
        return 'medals';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Owner doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'name', doc.name);

  Helper.writeModelNotNull(data, 'address', doc.address);
  Helper.writeModelListNotNull(data, 'medals', doc.medals);

  return data;
}

/// For load data
void _$fromData(Owner doc, Map<String, dynamic> data) {
  doc.name = Helper.valueFromKey<String?>(data, 'name', defaultValue: null);

  final _address = Helper.valueMapFromKey<String, dynamic>(data, 'address');
  if (_address != null) {
    doc.address = Address(values: _address);
  } else {
    doc.address = null;
  }

  final _medals = Helper.valueMapListFromKey<String, dynamic>(data, 'medals');
  if (_medals != null) {
    doc.medals = _medals.map((d) => Medal(values: d)).toList();
  } else {
    doc.medals = null;
  }
}
