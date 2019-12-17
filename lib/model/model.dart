import '../base.dart';

class Model extends Base {
  Model({this.values}) {
    if (values != null) {
      fromData(values);
    }
  }

  final Map<String, dynamic> values;

  Map<String, dynamic> toData() => <String, dynamic>{};

  /// Data for save
  void fromData(Map<String, dynamic> data) {}

  /// Data for load

}
