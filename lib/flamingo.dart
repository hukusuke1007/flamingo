import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

