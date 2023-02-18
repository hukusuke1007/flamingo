import 'package:cloud_firestore/cloud_firestore.dart';

import '../type/type.dart';
import 'document.dart';

class Collection<T extends Document<DocumentType>> {
  Collection(Document<DocumentType> parent, this.name)
      : ref = parent.reference.collection(name),
        path = parent.reference.collection(name).path;

  final CollectionReference<Map<String, dynamic>> ref;
  final String path;
  final String name;
}
