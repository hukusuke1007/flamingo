import '../base.dart';

class Model extends Base {
  Model({this.values}) {
    if (values != null) {
      fromData(values);
    }
  }

  final Map<String, dynamic> values;

  /// Data for save
  Map<String, dynamic> toData() => <String, dynamic>{};

  /// Data for load
  void fromData(Map<String, dynamic> data) {}
}
