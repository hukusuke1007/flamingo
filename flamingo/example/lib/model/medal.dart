import 'package:flamingo/flamingo.dart';

class Medal extends Model {
  Medal({
    this.name,
    Map<String, dynamic> values,
  }): super(values: values);

  String name;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'name', name);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    name = valueFromKey<String>(data, 'name');
  }

}