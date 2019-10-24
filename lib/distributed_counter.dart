import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/counter.dart';

class DistributedCounter {

   Future create(Counter counter) async {
     return await _create(counter.parentRef, counter.collectionName, counter.numShards);
   }

   Future increment(Counter counter, {int count}) async {
     return await _increment(counter.parentRef, counter.collectionName, counter.numShards, count: count);
   }

   Future<int> get(Counter counter) async {
     final count = await _get(counter.parentRef, counter.collectionName);
     counter.count = count;
     return count;
    }

   Future<void> _create(DocumentReference ref, String collectionName, int numShards) async {
    final batch = Firestore().batch();
    batch.setData(ref, {'numShards': numShards}, merge: true);
    for (var i = 0; i < numShards; i++) {
      final shardRef = ref.collection(collectionName).document(i.toString());
      batch.setData(shardRef, {'count': 0 }, merge: true);
    }
    return await batch.commit();
   }

   Future<void> _increment(DocumentReference ref, String collectionName, int numShards, {int count}) async {
     final shardId = Random().nextInt(numShards);
     print(shardId);
     final shardRef = ref.collection(collectionName).document(shardId.toString());
     return await shardRef.updateData({'count': FieldValue.increment(count != null ? count : 1)});
   }

   Future<int> _get(DocumentReference ref, String collectionName) async {
     int totalCount = 0;
     final snapshot = await ref.collection(collectionName).getDocuments();
     snapshot.documents.forEach((item) => totalCount += item['count'] as int);
     return totalCount;
   }
}

