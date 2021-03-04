import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'score.flamingo.dart';

class Score extends Document<Score> {
  Score({
    String? id,
  }) : super(id: id) {
    counter = Counter(this, ScoreKey.counter.value, numShards);
  }

  @Field()
  String? userId;

  /// DistributedCounter
  @SubCollection()
  late Counter counter;

  int numShards = 10;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  void log() {
    print('$id $userId ${counter.count}');
  }
}
