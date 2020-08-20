import 'package:cloud_firestore/cloud_firestore.dart';

import '../document.dart';
import '../type/type.dart';

class Collection<T extends Document<DocumentType>> {
  Collection(Document parent, this.name) {
    ref = parent.reference.collection(name);
    path = ref.path;
  }
  CollectionReference ref;
  String path;
  String name;
}
