import 'package:cloud_firestore/cloud_firestore.dart';

class Increment<T extends num> {
  Increment(this.fieldName, {this.value, this.incrementValue});
  final String fieldName;
  final T value;
  T incrementValue;
  bool isClearValue = false;

  Map<String, dynamic> toData(num value, {bool isClear}) => <String, dynamic>{
    fieldName: isClear != true ? FieldValue.increment(value) : value,
  };

  void onCompleted() {
    _clear();
  }

  void _clear() {
    incrementValue = null;
    isClearValue = false;
  }
}
