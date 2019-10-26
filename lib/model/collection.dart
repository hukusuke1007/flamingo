import 'package:cloud_firestore/cloud_firestore.dart';
import '../document.dart';

class Collection {
  Collection(Document parent, String name) {
    ref = parent.reference.collection(name);
    path = ref.path;
    this.name = name;
  }
  CollectionReference ref;
  String path;
  String name;
}