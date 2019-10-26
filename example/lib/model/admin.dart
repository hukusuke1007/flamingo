import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_example/model/setting.dart';

class Admin extends Document<Admin> {
  Admin({String id, DocumentSnapshot snapshot, Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values) {
    settingsA = Collection(this, 'settingsA');
    settingsB = Collection(this, 'settingsB');
    likeCounter = Counter(this, 'likeShards', numShards);
  }

  /// Document
  String uid;
  String name;
  int age;
  List<String> memos;

  /// DistributedCounter
  int numShards = 10;
  Counter likeCounter;

  /// SubCollection
  Collection<Setting> settingsA;
  Collection<Setting> settingsB;

  /// Storage
  StorageFile file;
  String folderName = 'file';

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'uid', uid);
    writeNotNull(data, 'name', name);
    writeNotNull(data, 'age', age);
    writeNotNull(data, 'memos', memos);
    if (file != null) {
      if (!file.isDeleted) {
        data[folderName] = file.toJson();
      } else {
        data[folderName] = FieldValue.delete();
      }
    }
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    this..uid = valueFromKey<String>(data, 'uid')
      ..name = valueFromKey<String>(data, 'name')
      ..age = valueFromKey<int>(data, 'age')
      ..numShards = valueFromKey<int>(data, 'numShards')
      ..memos = valueListFromKey<List<String>>(data, 'memos');
    if (isVal(data, folderName)) {
      file = StorageFile.fromJson(Helper.fromMap(data[folderName] as Map));
    }
  }

  void log() {
    print('$id $uid $name $age $numShards $createdAt $updatedAt');
    print('$memos');
    print('$file $settingsA $settingsB');
  }

}