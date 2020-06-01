import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class ModelSample extends Document<ModelSample> {
  ModelSample({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values);

  String name;
  List<String> strList;
  Map<String, String> strMap;
  List<Map<String, String>> listStrMap;
  StorageFile file;
  String folderName = 'file';

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    write(data, 'name', name);
    write(data, 'strList', strList);
    write(data, 'strMap', strMap);
    write(data, 'listStrMap', listStrMap);
    writeStorage(data, folderName, file);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    name = valueFromKey<String>(data, 'name');
    strList = valueListFromKey<String>(data, 'strList');
    strMap = valueMapFromKey<String, String>(data, 'strMap');
    listStrMap = valueMapListFromKey<String, String>(data, 'listStrMap');
    file = storageFile(data, folderName);
  }

  void log() {
    print('ModelSample $id $name $strList $strMap $listStrMap ${file?.toJson()}');
  }

}