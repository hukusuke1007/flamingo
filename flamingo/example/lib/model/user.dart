import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:flamingo_example/model/setting.dart';

part 'user.flamingo.dart';

class User extends Document<User> {
  User({
    String? id,
    DocumentSnapshot? snapshot,
    Map<String, dynamic>? values,
    CollectionReference? collectionRef,
  }) : super(
            id: id,
            snapshot: snapshot,
            values: values,
            collectionRef: collectionRef) {
    setting = Collection(this, UserKey.setting.value);
  }

  @Field()
  String? name;

  @Field()
  Timestamp? editAt;

  @Field()
  Timestamp? clearAt;

  @SubCollection()
  late Collection<Setting> setting;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  /// For completed create, update, delete.
  @override
  void onCompleted(ExecuteType executeType) {
    print('onCompleted $executeType');
  }

  void log() {
    print(
        'User $modelName $id ${reference.path} $name $createdFieldValueKey $updatedFieldValueKey '
        '${createdAt?.toDate()} '
        '${updatedAt?.toDate()}');
  }
}
