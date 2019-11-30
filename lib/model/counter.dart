import 'package:cloud_firestore/cloud_firestore.dart';
import '../document.dart';

class Counter {
  Counter(Document parent, this.collectionName, this.numShards) {
    parentRef = parent.reference;
    path = parentRef.path;
  }

  int numShards;
  int count = 0;

  DocumentReference parentRef;
  String path;
  String collectionName;
}
