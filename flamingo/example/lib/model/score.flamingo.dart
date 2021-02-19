// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum ScoreKey {
  userId,

  counter,
}

extension ScoreKeyExtension on ScoreKey {
  String get value {
    switch (this) {
      case ScoreKey.userId:
        return 'userId';
      case ScoreKey.counter:
        return 'counter';
      default:
        throw Exception('Invalid data key. key: FieldValueGenerator');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Score doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'userId', doc.userId);

  return data;
}

/// For load data
void _$fromData(Score doc, Map<String, dynamic> data) {
  doc.userId = Helper.valueFromKey<String>(data, 'userId');
}
