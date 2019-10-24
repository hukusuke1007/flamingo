import 'package:cloud_firestore/cloud_firestore.dart';
import '../document.dart';

class Collection {
  Collection(Document parent, String collectionName) {
    ref = parent.reference.collection(collectionName);
    path = ref.path;
    this.collectionName = collectionName;
  }

  CollectionReference ref;
  String path;
  String collectionName;
}