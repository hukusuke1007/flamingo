import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'setting.flamingo.dart';

class Setting extends Document<Setting> {
  Setting({
    String? id,
    DocumentSnapshot? documentSnapshot,
    Map<String, dynamic>? values,
    CollectionReference? collectionRef,
  }) : super(
            id: id,
            snapshot: documentSnapshot,
            values: values,
            collectionRef: collectionRef);

  @Field()
  bool? isEnable;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  void log() {
    print('$id $isEnable $createdAt $updatedAt');
  }
}
