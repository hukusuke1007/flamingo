import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'map_sample.flamingo.dart';

class MapSample extends Document<MapSample> {
  MapSample({
    String? id,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
    Map<String, dynamic>? values,
    CollectionReference<Map<String, dynamic>>? collectionRef,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  Map<String, String>? strMap;

  @Field()
  Map<String, int>? intMap;

  @Field()
  Map<String, double>? doubleMap;

  @Field()
  Map<String, bool>? boolMap;

  @Field()
  List<Map<String, String>>? listStrMap;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  void log() {
    print('MapSample $id $strMap $intMap $doubleMap $boolMap $listStrMap');
  }
}
