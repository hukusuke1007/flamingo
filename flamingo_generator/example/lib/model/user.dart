import 'package:flamingo/flamingo.dart';
import 'package:flamingo_generator/flamingo_generator.dart';

import 'cart.dart';

part 'user.value.g.dart';

class User extends Document<User> {
  User({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  String name;

  @Field(isWriteNotNull: false)
  String profile;

  @Field()
  Map<String, int> intMap;

  @Field()
  List<Map<String, int>> listIntMap;

  @ModelField()
  Cart cartA;

  @ModelField(isWriteNotNull: false)
  Cart cartB;

  @ModelField()
  List<Cart> carts;

  @StorageField()
  StorageFile fileA;

  @StorageField(isWriteNotNull: false, folderName: 'image')
  StorageFile fileB;

  @StorageField()
  List<StorageFile> filesA;

  @StorageField(isWriteNotNull: false)
  List<StorageFile> filesB;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
