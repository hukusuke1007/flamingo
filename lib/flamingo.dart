library flamingo;

import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference, Firestore, WriteBatch;
import 'package:firebase_storage/firebase_storage.dart' show FirebaseStorage;

export 'package:flamingo/batch.dart';
export 'package:flamingo/distributed_counter.dart';
export 'package:flamingo/document.dart';
export 'package:flamingo/document_accessor.dart';
export 'package:flamingo/storage.dart';
export 'package:flamingo/transaction.dart';
export 'package:flamingo/helper/helper.dart';
export 'package:flamingo/master/master.dart';
export 'package:flamingo/model/collection.dart';
export 'package:flamingo/model/counter.dart';
export 'package:flamingo/model/storage_file.dart';
export 'package:flamingo/batch.dart';

class Flamingo {
  static final instance = Flamingo();
  static configure(DocumentReference reference) {
    instance.rootReference = reference;
  }
  DocumentReference rootReference;
}

Firestore firestore() {
  return Firestore.instance;
}

WriteBatch batch() {
  return Firestore().batch();
}

FirebaseStorage firebaseStorage() {
  return FirebaseStorage.instance;
}