import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class MapSample extends Document<MapSample> {
  MapSample({String id, DocumentSnapshot snapshot, Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values);

  Map<String, String> strMap;
  Map<String, int> intMap;
  Map<String, double> doubleMap;
  Map<String, bool> boolMap;
  List<Map<String, String>> listStrMap;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'strMap', strMap);
    writeNotNull(data, 'intMap', intMap);
    writeNotNull(data, 'doubleMap', doubleMap);
    writeNotNull(data, 'boolMap', boolMap);
    writeNotNull(data, 'listStrMap', listStrMap);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    strMap = valueMapFromKey<String, String>(data, 'strMap');
    intMap = valueMapFromKey<String, int>(data, 'intMap');
    doubleMap = valueMapFromKey<String, double>(data, 'doubleMap');
    boolMap = valueMapFromKey<String, bool>(data, 'boolMap');
    listStrMap = valueMapListFromKey<String, String>(data, 'listStrMap');
  }

  void log() {
    print('MapSample $id $strMap $intMap $doubleMap $boolMap $listStrMap');
  }

}