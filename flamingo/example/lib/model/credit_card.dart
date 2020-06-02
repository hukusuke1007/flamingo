import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'credit_card.flamingo.dart';

class CreditCard extends Document<CreditCard> {
  CreditCard({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values) {
    point = Increment(CreditCardKey.point.value);
    score = Increment(CreditCardKey.score.value);
  }

  @Field()
  Increment<int> point;

  @Field()
  Increment<double> score;

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
