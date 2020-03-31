import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class ListSample extends Document<ListSample> {
  ListSample({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values);

  List<String> strList;
  List<int> intList;
  List<double> doubleList;
  List<bool> boolList;

  List<StorageFile> filesA;
  List<StorageFile> filesB;
  static String get folderFilesAName => 'filesA';
  static String get folderFilesBName => 'filesB';

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'strList', strList);
    writeNotNull(data, 'intList', intList);
    writeNotNull(data, 'doubleList', doubleList);
    writeNotNull(data, 'boolList', boolList);
    writeStorageList(data, folderFilesAName, filesA);
    writeStorageListNotNull(data, folderFilesBName, filesB);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    strList = valueListFromKey<String>(data, 'strList');
    intList = valueListFromKey<int>(data, 'intList');
    doubleList = valueListFromKey<double>(data, 'doubleList');
    boolList = valueListFromKey<bool>(data, 'boolList');
    filesA = storageFiles(data, folderFilesAName);
    filesB = storageFiles(data, folderFilesBName);
  }

  void log() {
    print('ListSample $id $strList $intList $doubleList $boolList $filesA');
    filesA?.forEach((d) => print('filesA ${d.toJson()}'));
    filesB?.forEach((d) => print('filesB ${d.toJson()}'));
  }

}