class Value {
  const Value(this.value) : assert(value != null);
  final String value;
}

class FieldValue {
  const FieldValue({this.isWriteNotNull = true});
  final bool isWriteNotNull;
}
