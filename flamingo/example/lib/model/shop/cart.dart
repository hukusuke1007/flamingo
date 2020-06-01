import 'package:flamingo/flamingo.dart';

class Cart extends Model {
  Cart({
    this.ref,
    this.collectionRef,
    Map<String, dynamic> values,
  }): super(values: values);

  String ref;
  String collectionRef;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'ref', ref);
    writeNotNull(data, 'collectionRef', collectionRef);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    ref = valueFromKey<String>(data, 'ref');
    collectionRef = valueFromKey<String>(data, 'collectionRef');
  }

}