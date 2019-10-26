import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class Post extends Document<Post> {
  Post({String id}): super(id: id);

  /// Storage
  StorageFile file;
  String folderName = 'file';

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
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
    if (isVal(data, folderName)) {
      file = StorageFile.fromJson(Helper.fromMap(data[folderName] as Map));
    }
  }

  void log() {
    print('$id ${file?.toJson()}');
  }

}