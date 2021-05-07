import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'point.flamingo.dart';

class Point extends Document<Point> {
  Point({
    String? id,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
    Map<String, dynamic>? values,
    CollectionReference<Map<String, dynamic>>? collectionRef,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  int? pointInt;

  @Field()
  double? pointDouble;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  void log() {
    print('Point $id $pointInt $pointDouble');
  }
}
