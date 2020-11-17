// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum PublicKey {
  domain,
}

extension PublicKeyExtension on PublicKey {
  String get value {
    switch (this) {
      case PublicKey.domain:
        return 'domain';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Public doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'domain', doc.domain);

  return data;
}

/// For load data
void _$fromData(Public doc, Map<String, dynamic> data) {
  doc.domain = Helper.valueFromKey<String>(data, 'domain');
}
