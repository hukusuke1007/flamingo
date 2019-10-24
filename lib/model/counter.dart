import 'package:cloud_firestore/cloud_firestore.dart';
import '../document.dart';

class Counter {
  Counter(Document parent, String collectionName, int numShards) {
    this.parentRef = parent.reference;
    this.path = this.parentRef.path;
    this.collectionName = collectionName;
    this.numShards = numShards;
  }

  int numShards;
  int count = 0;

  DocumentReference parentRef;
  String path;
  String collectionName;
}