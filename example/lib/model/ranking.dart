import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';
import 'count.dart';

class Ranking extends Document<Ranking> {
  Ranking({String id, DocumentSnapshot snapshot, Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values) {
    count = Collection(this, 'count');
  }

  String title;
  Collection<Count> count;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'name', title);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    title = valueFromKey<String>(data, 'title');
  }

  void log() {
    print('$id $title');
  }

}