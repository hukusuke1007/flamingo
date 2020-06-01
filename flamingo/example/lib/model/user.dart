import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:flamingo_example/model/setting.dart';

part 'user.value.g.dart';

class User extends Document<User> {
  User({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values) {
    setting = Collection(this, 'setting');
  }

  @Field()
  String name;

  Collection<Setting> setting;

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
        'User $id ${reference.path} $name $createdFieldValueKey $updatedFieldValueKey '
        '${createdAt?.toDate()} '
        '${updatedAt?.toDate()}');
  }
}