library flamingo;

import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, Firestore;
import 'package:firebase_storage/firebase_storage.dart' show FirebaseStorage;

export 'package:flamingo/batch.dart';
export 'package:flamingo/distributed_counter.dart';
export 'package:flamingo/document.dart';
export 'package:flamingo/document_accessor.dart';
export 'package:flamingo/storage.dart';
export 'package:flamingo/run_transaction.dart';
export 'package:flamingo/helper/helper.dart';
export 'package:flamingo/master/master.dart';
export 'package:flamingo/model/collection.dart';
export 'package:flamingo/model/counter.dart';
export 'package:flamingo/model/storage_file.dart';
export 'package:flamingo/model/model.dart';
export 'package:flamingo/model/increment.dart';
export 'package:flamingo/enum/execute_type.dart';

class Flamingo {
  static Flamingo instance = Flamingo();
  static void configure(
      {Firestore firestore, FirebaseStorage storage, DocumentReference root}) {
    instance.firestore = firestore;
    instance.firebaseStorage = storage;
    instance.rootReference = root;
  }

  DocumentReference rootReference;
  Firestore firestore;
  FirebaseStorage firebaseStorage;
}

Firestore firestoreInstance() {
  return Flamingo.instance.firestore;
}

FirebaseStorage storageInstance() {
  return Flamingo.instance.firebaseStorage;
}
