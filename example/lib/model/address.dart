import 'package:flamingo/flamingo.dart';

class Address extends Model {
  Address({
    this.postCode,
    this.country,
    Map<String, dynamic> values,
  }): super(values: values);

  String postCode;
  String country;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'postCode', postCode);
    writeNotNull(data, 'country', country);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    postCode = valueFromKey<String>(data, 'postCode');
    country = valueFromKey<String>(data, 'country');
  }

}