import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class CreditCard extends Document<CreditCard> {
  CreditCard({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values) {
    point = Increment('point');
    score = Increment('score');
  }

  Increment<int> point;
  Increment<double> score;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeIncrement(data, point);
    writeIncrement(data, score);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    point = valueFromIncrement<int>(data, point.fieldName);
    score = valueFromIncrement<double>(data, score.fieldName);
  }

  /// For completed create, update, delete.
  @override
  void onCompleted() {
    point.onCompleted();
    score.onCompleted();
  }

  void log() {
    print('$id ${point.value} ${score.value}');
    print('${point.incrementValue} ${score.incrementValue}');
  }

}