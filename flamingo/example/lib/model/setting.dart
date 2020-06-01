import 'package:flamingo/flamingo.dart';
import 'package:flamingo/document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Setting extends Document<Setting> {
  Setting({
    String id,
    DocumentSnapshot documentSnapshot,
    Map<String, dynamic> values,
    CollectionReference collectionRef,
  }): super(id: id, snapshot: documentSnapshot, values: values, collectionRef: collectionRef);

  bool isEnable;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'isEnable', isEnable);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    isEnable = valueFromKey<bool>(data, 'isEnable');
  }

  void log() {
    print('$id $isEnable $createdAt $updatedAt');
  }
}