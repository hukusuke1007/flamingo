library flamingo;

import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, CollectionReference, Firestore;
import 'package:firebase_storage/firebase_storage.dart' show FirebaseStorage;

export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_storage/firebase_storage.dart';

export 'batch.dart';
export 'constants.dart';
export 'distributed_counter.dart';
export 'document.dart';
export 'document_accessor.dart';
export 'enum/execute_type.dart';
export 'helper/helper.dart';
export 'master/master.dart';
export 'model/collection.dart';
export 'model/counter.dart';
export 'model/increment.dart';
export 'model/model.dart';
export 'model/storage_file.dart';
export 'run_transaction.dart';
export 'storage.dart';
export 'type/type.dart';

class Flamingo {
  static Flamingo instance = Flamingo();
  static void configure({
    Firestore firestore,
    FirebaseStorage storage,
    DocumentReference root,
  }) {
    instance.firestore = firestore != null ? firestore : Firestore.instance;
    instance.firebaseStorage =
        storage != null ? storage : FirebaseStorage.instance;
    instance.rootReference =
        root != null ? root : instance.firestore.document('');
  }

  DocumentReference rootReference;
  Firestore firestore;
  FirebaseStorage firebaseStorage;
}

DocumentReference get rootReference => Flamingo.instance.rootReference;
Firestore get firestoreInstance => Flamingo.instance.firestore;
FirebaseStorage get storageInstance => Flamingo.instance.firebaseStorage;
CollectionReference collectionReference(String path) =>
    Flamingo.instance.rootReference.collection(path);
