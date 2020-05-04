import 'package:flamingo/flamingo.dart';
import 'package:flamingo_example/model/public/public.dart';
import 'setting.dart';

class User extends Public<User> {
  User({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values) {
    setting = Collection(this, 'setting');
  }

  @override
  CollectionReference get collectionRootReference =>
      super.collectionRootReference.document('v1').collection('users');

  String name;
  Collection<Setting> setting;

  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'name', name);
    return data;
  }

  @override
  void fromData(Map<String, dynamic> data) {
    name = valueFromKey<String>(data, 'name');
  }
}