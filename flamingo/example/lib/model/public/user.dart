import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

import 'public.dart';
import 'setting.dart';

part 'user.flamingo.dart';

class User extends Public<User> {
  User({
    String? id,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
    Map<String, dynamic>? values,
    CollectionReference<Map<String, dynamic>>? collectionRef,
  }) : super(
            id: id,
            snapshot: snapshot,
            values: values,
            collectionRef: collectionRef) {
    setting = Collection(this, UserKey.setting.value);
  }

  @override
  CollectionReference<Map<String, dynamic>> get collectionRootReference =>
      super.collectionRootReference.doc('v1').collection('users');

  @Field()
  String? name;

  @SubCollection()
  late Collection<Setting> setting;

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
