import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'model_sample.flamingo.dart';

class ModelSample extends Document<ModelSample> {
  ModelSample({
    String? id,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
    Map<String, dynamic>? values,
    CollectionReference<Map<String, dynamic>>? collectionRef,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field(isWriteNotNull: false)
  String? name;

  @Field(isWriteNotNull: false)
  List<String>? strList;

  @Field(isWriteNotNull: false)
  Map<String, String>? strMap;

  @Field(isWriteNotNull: false)
  List<Map<String, String>>? listStrMap;

  @StorageField(isWriteNotNull: false)
  StorageFile? file;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  void log() {
    print(
        'ModelSample $id $name $strList $strMap $listStrMap ${file?.toJson()}');
  }
}
