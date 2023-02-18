import 'dart:math';

import '../flamingo.dart';

abstract class DistributedCounterRepository {
  Future<void> create(Counter counter);
  Future<void> increment(Counter counter, {int count});
  Future<int> load(Counter counter);
}

class DistributedCounter implements DistributedCounterRepository {
  @override
  Future<void> create(Counter counter) async =>
      _create(counter.parentRef, counter.collectionName, counter.numShards);

  @override
  Future<void> increment(Counter counter, {int? count}) async => _increment(
        counter.parentRef,
        counter.collectionName,
        counter.numShards,
        count: count,
      );

  @override
  Future<int> load(Counter counter) async {
    final count = await _load(counter.parentRef, counter.collectionName);
    counter.setCount(count);
    return count;
  }

  Future<void> _create(
    DocumentReference ref,
    String collectionName,
    int numShards,
  ) async {
    final batch = firestoreInstance.batch()
      ..set(
        ref,
        <String, dynamic>{'numShards': numShards},
        SetOptions(merge: true),
      );
    for (var i = 0; i < numShards; i++) {
      final shardRef = ref.collection(collectionName).doc(i.toString());
      batch.set(
        shardRef,
        <String, dynamic>{'count': 0},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
    return;
  }

  Future<void> _increment(
    DocumentReference ref,
    String collectionName,
    int numShards, {
    int? count,
  }) async {
    final shardId = Random().nextInt(numShards);
    final shardRef = ref.collection(collectionName).doc(shardId.toString());
    await shardRef
        .update(<String, dynamic>{'count': FieldValue.increment(count ?? 1)});
    return;
  }

  Future<int> _load(DocumentReference ref, String collectionName) async {
    var totalCount = 0;
    final snapshot = await ref.collection(collectionName).get();
    // ignore: avoid_function_literals_in_foreach_calls
    snapshot.docs.forEach((item) => totalCount += item.get('count') as int);
    return totalCount;
  }
}
