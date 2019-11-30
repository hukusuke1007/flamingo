import 'package:json_annotation/json_annotation.dart';
import '../base.dart';

class Model extends Base {
  Model({this.values}) {
    if (values != null) {
      fromData(values);
    }
  }

  @JsonKey(ignore: true)
  final Map<String, dynamic> values;

  Map<String, dynamic> toData() => <String, dynamic>{};

  /// Data for save
  void fromData(Map<String, dynamic> data) {}

  /// Data for load

}
