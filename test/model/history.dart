import 'package:flamingo/flamingo.dart';
import 'package:flamingo/document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class History extends Document<History> {
  History({String id, DocumentSnapshot documentSnapshot, Map<String, dynamic> values,
  }): super(id: id, snapshot: documentSnapshot, values: values);

  String userId;

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
    this.userId = valueFromKey<String>(data, 'userId');
  }
}