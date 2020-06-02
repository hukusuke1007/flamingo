// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum RankingKey {
  title,

  count,
}

extension RankingKeyExtension on RankingKey {
  String get value {
    switch (this) {
      case RankingKey.title:
        return 'title';
      case RankingKey.count:
        return 'count';
      default:
        return toString();
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Ranking doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'title', doc.title);

  return data;
}

/// For load data
void _$fromData(Ranking doc, Map<String, dynamic> data) {
  doc.title = Helper.valueFromKey<String>(data, 'title');
}
