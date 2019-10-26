import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class Score extends Document<Score> {
  Score({String id, DocumentSnapshot snapshot, Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values) {
    value = Counter(this, 'shards', numShards);
  }

  /// Document
  String userId;

  /// DistributedCounter
  int numShards = 10;
  Counter value;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'userId', userId);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    userId = valueFromKey<String>(data, 'userId');
  }

  void log() {
    print('$id $userId ${value.count}');
  }

}