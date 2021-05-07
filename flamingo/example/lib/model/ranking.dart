import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

import 'count.dart';

part 'ranking.flamingo.dart';

class Ranking extends Document<Ranking> {
  Ranking({
    String? id,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
    Map<String, dynamic>? values,
    CollectionReference<Map<String, dynamic>>? collectionRef,
  }) : super(
            id: id,
            snapshot: snapshot,
            values: values,
            collectionRef: collectionRef) {
    count = Collection(this, RankingKey.count.value);
  }

  @Field()
  String? title;

  @SubCollection()
  Collection<Count>? count;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  void log() {
    print('$id $title');
  }
}
