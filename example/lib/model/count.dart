import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class Count extends Document<Count> {
  Count({String id, DocumentSnapshot snapshot, Map<String, dynamic> values, CollectionReference collectionRef,
  }): super(id: id, snapshot: snapshot, values: values, collectionRef: collectionRef);

  String userId;
  int count = 0;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'userId', userId);
    writeNotNull(data, 'count', count);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    userId = valueFromKey<String>(data, 'userId');
    count = valueFromKey<int>(data, 'count');
  }

  void log() {
    print('$id $userId $count');
  }

}