import 'package:flamingo/flamingo.dart';

class Post extends Document<Post> {
  Post({
    String id
  }): super(id: id);

  /// Storage
  StorageFile file;
  String folderName = 'file';

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeStorage(data, folderName, file);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    file = storageFile(data, folderName);
  }

  void log() {
    print('$id ${file?.toJson()}');
  }

}