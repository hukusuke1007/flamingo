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

  Increment<T> onRefresh() {
    Increment<T> result;
    if (isClearValue) {
      final _value = T.toString() == 'double' ? 0.0 : 0;
      result = Increment<T>(fieldName, value: _value as T);
    } else {
      if (incrementValue != null) {
        final _value = value != null ? value + incrementValue : incrementValue;
        result = Increment<T>(fieldName, value: _value as T);
      } else {
        result = Increment<T>(fieldName, value: value);
      }
    }
    _clear();
    return result;
  }

  void _clear() {
    incrementValue = null;
    isClearValue = false;
  }
}
