import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/src/type/type.dart';

import 'document.dart';

class Counter {
  Counter(Document<DocumentType> parent, this.collectionName, this.numShards)
      : parentRef = parent.reference,
        path = parent.reference.path;

  final int numShards;

  int get count => _count;
  int _count = 0;

  final DocumentReference parentRef;
  final String path;
  final String collectionName;

  // ignore: use_setters_to_change_properties
  void setCount(int value) => _count = value;
}
