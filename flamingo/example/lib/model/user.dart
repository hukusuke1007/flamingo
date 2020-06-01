import 'package:flamingo/flamingo.dart';
import 'package:flamingo_example/model/setting.dart';

class User extends Document<User> {
  User({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values) {
    setting = Collection(this, 'setting');
  }

  String name;
  Collection<Setting> setting;

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

  /// For completed create, update, delete.
  @override
  void onCompleted(ExecuteType executeType) {
    print('onCompleted $executeType');
  }

  void log() {
    print('User $id ${reference.path} $name $createdFieldValueKey $updatedFieldValueKey '
        '${createdAt?.toDate()} '
        '${updatedAt?.toDate()}');
  }

}