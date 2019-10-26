import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/counter.dart';

class DistributedCounter {

   Future create(Counter counter) async => _create(counter.parentRef, counter.collectionName, counter.numShards);

   Future increment(Counter counter, {int count}) async => _increment(counter.parentRef, counter.collectionName, counter.numShards, count: count);

   Future<int> load(Counter counter) async {
     final count = await _load(counter.parentRef, counter.collectionName);
     counter.count = count;
     return count;
    }

   Future<void> _create(DocumentReference ref, String collectionName, int numShards) async {
    final batch = Firestore().batch()
      ..setData(ref, <String, dynamic>{'numShards': numShards}, merge: true);
    for (var i = 0; i < numShards; i++) {
      final shardRef = ref.collection(collectionName).document(i.toString());
      batch.setData(shardRef, <String, dynamic>{'count': 0 }, merge: true);
    }
    await batch.commit();
    return;
   }

   Future<void> _increment(DocumentReference ref, String collectionName, int numShards, {int count}) async {
     final shardId = Random().nextInt(numShards);
     final shardRef = ref.collection(collectionName).document(shardId.toString());
     await shardRef.updateData(<String, dynamic>{'count': FieldValue.increment(count != null ? count : 1)});
     return;
   }

   Future<int> _load(DocumentReference ref, String collectionName) async {
     var totalCount = 0;
     final snapshot = await ref.collection(collectionName).getDocuments();
     snapshot.documents.forEach((item) => totalCount += item['count'] as int);
     return totalCount;
   }
}

