import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'credit_card.flamingo.dart';

class CreditCard extends Document<CreditCard> {
  CreditCard({
    String? id,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
    Map<String, dynamic>? values,
    CollectionReference<Map<String, dynamic>>? collectionRef,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  Increment<int> point = Increment<int>();

  @Field()
  Increment<double> score = Increment<double>();

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  /// Call after create, update, delete.
  @override
  void onCompleted(ExecuteType executeType) {
    point = point.onRefresh();
    score = score.onRefresh();
  }

  void log() {
    print('$id ${point.value} ${score.value}');
    // print('${point.incrementValue} ${score.incrementValue}');
  }
}
