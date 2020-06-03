import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

import 'public.dart';
import 'setting.dart';

part 'user.flamingo.dart';

class User extends Public<User> {
  User({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values) {
    setting = Collection(this, UserKey.setting.value);
  }

  @override
  CollectionReference get collectionRootReference =>
      super.collectionRootReference.document('v1').collection('users');

  @Field()
  String name;

  @SubCollection()
  Collection<Setting> setting;

  @override
  Map<String, dynamic> toData() => <String, dynamic>{
        ...super.toData(),
        ..._$toData(this),
      };

  @override
  void fromData(Map<String, dynamic> data) {
    super.fromData(data);
    _$fromData(this, data);
  }
}
