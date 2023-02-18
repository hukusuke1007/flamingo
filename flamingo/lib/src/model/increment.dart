import 'package:cloud_firestore/cloud_firestore.dart';

class Increment<T extends num> {
  Increment({
    this.value,
    this.incrementValue,
  });
  final T? value;

  T? incrementValue;
  bool isClearValue = false;

  Map<String, dynamic> toData(
    num value, {
    required String fieldName,
    bool? isClear,
  }) =>
      <String, dynamic>{
        fieldName: isClear != true ? FieldValue.increment(value) : value,
      };

  Increment<T> onRefresh() {
    Increment<T> result;
    if (isClearValue) {
      final value = T.toString() == 'double' ? 0.0 : 0;
      result = Increment<T>(value: value as T);
    } else {
      if (incrementValue != null) {
        final value0 =
            value != null ? value! + incrementValue! : incrementValue;
        result = Increment<T>(value: value0! as T);
      } else {
        result = Increment<T>(value: value);
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
