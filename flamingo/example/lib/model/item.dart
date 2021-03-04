import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'item.flamingo.dart';

class Item extends Document<Item> {
  Item({
    String? id,
    DocumentSnapshot? snapshot,
    Map<String, dynamic>? values,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  String? name;

  /// Custom field key of createdAt and updatedAt.
  @override
  String get createdFieldValueKey => 'createdDate';

  @override
  String get updatedFieldValueKey => 'updatedDate';

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  void log() {
    print(
        'Item $id ${reference.path} $name $createdFieldValueKey $updatedFieldValueKey '
        '${createdAt?.toDate()} '
        '${updatedAt?.toDate()}');
  }
}
