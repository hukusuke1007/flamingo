import 'package:flamingo/flamingo.dart';

class Post extends Document<Post> {
  Post({
    String id
  }): super(id: id);

  /// Storage
  StorageFile file;
  List<StorageFile> files;
  static String get folderFileName => 'file';
  static String get folderFilesName => 'files';

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeStorage(data, folderFileName, file);
    writeStorageList(data, folderFilesName, files);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    file = storageFile(data, folderFileName);
    files = storageFiles(data, folderFilesName);
  }

  void log() {
    print('$id ${file?.toJson()} $files');
  }

}