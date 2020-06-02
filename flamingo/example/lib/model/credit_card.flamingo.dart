// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum CreditCardKey {
  point,
  score,
}

extension CreditCardKeyExtension on CreditCardKey {
  String get value {
    switch (this) {
      case CreditCardKey.point:
        return 'point';
      case CreditCardKey.score:
        return 'score';
      default:
        return toString();
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(CreditCard doc) {
  final data = <String, dynamic>{};
  Helper.writeIncrement(data, doc.point);
  Helper.writeIncrement(data, doc.score);

  return data;
}

/// For load data
void _$fromData(CreditCard doc, Map<String, dynamic> data) {
  doc.point = Helper.valueFromIncrement<int>(data, doc.point.fieldName);
  doc.score = Helper.valueFromIncrement<double>(data, doc.score.fieldName);
}
