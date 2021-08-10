import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

import 'cart.dart';
import 'item.dart';

part 'user.flamingo.dart';

class User extends Document<User> {
  User({
    String? id,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
    Map<String, dynamic>? values,
  }) : super(id: id, snapshot: snapshot, values: values) {
    item = Collection(this, UserKey.item.value);
  }

  @Field()
  String? name;

  @Field(isWriteNotNull: false)
  String? profile;

  @Field()
  List<String>? strList;

  @Field()
  Map<String, int>? intMap;

  @Field()
  List<Map<String, int>>? listIntMap;

  @Field()
  Increment<int>? point = Increment<int>();

  @Field()
  Increment<double>? score = Increment<double>();

  @ModelField()
  Cart? cartA;

  @ModelField(isWriteNotNull: false)
  Cart? cartB;

  @ModelField()
  List<Cart>? carts;

  @StorageField()
  StorageFile? fileA;

  @StorageField(isWriteNotNull: false, folderName: 'image')
  StorageFile? fileB;

  @StorageField()
  List<StorageFile>? filesA;

  @StorageField(isWriteNotNull: false)
  List<StorageFile>? filesB;

  @SubCollection()
  Collection<Item>? item;

  String? dummyName;
  int? dummyAge;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
