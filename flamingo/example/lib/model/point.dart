import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class Point extends Document<Point> {
  Point({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values);

  int pointInt;
  double pointDouble;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'pointInt', pointInt);
    writeNotNull(data, 'pointDouble', pointDouble);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    print(data);
    pointInt = valueFromKey<int>(data, 'pointInt');
    pointDouble = valueFromKey<double>(data, 'pointDouble');
  }

  void log() {
    print('Point $id $pointInt $pointDouble');
  }

}