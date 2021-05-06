import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'list_sample.flamingo.dart';

class ListSample extends Document<ListSample> {
  ListSample({
    String? id,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
    Map<String, dynamic>? values,
    CollectionReference<Map<String, dynamic>>? collectionRef,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  List<String>? strList;

  @Field()
  List<int>? intList;

  @Field()
  List<double>? doubleList;

  @Field()
  List<bool>? boolList;

  @StorageField(isWriteNotNull: false)
  List<StorageFile>? filesA;

  @StorageField()
  List<StorageFile>? filesB;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  void log() {
    print('ListSample $id $strList $intList $doubleList $boolList $filesA');
    filesA?.forEach((d) => print('filesA ${d.toJson()}'));
    filesB?.forEach((d) => print('filesB ${d.toJson()}'));
  }
}
