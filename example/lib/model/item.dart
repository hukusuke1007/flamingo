import 'package:flamingo/flamingo.dart';
import 'package:flamingo_example/model/setting.dart';

class Item extends Document<Item> {
  Item({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values);

  String name;

  /// Custom field key of createdAt and updatedAt.
  @override
  String get createdFieldValueKey => 'createdDate';

  @override
  String get updatedFieldValueKey => 'updatedDate';

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

  void log() {
    print('Item $id ${reference.path} $name $createdFieldValueKey $updatedFieldValueKey '
        '${createdAt?.toDate()} '
        '${updatedAt?.toDate()}');
  }

}