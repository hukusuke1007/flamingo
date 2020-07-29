library flamingo;

import 'package:cloud_firestore/cloud_firestore.dart'
    show CollectionReference, DocumentReference, FirebaseFirestore;
import 'package:firebase_storage/firebase_storage.dart' show FirebaseStorage;

export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_storage/firebase_storage.dart';

export 'batch.dart';
export 'collection_paging.dart';
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
    FirebaseFirestore firestore,
    FirebaseStorage storage,
    DocumentReference root,
  }) {
    instance.firestore =
        firestore != null ? firestore : FirebaseFirestore.instance;
    instance.firebaseStorage =
        storage != null ? storage : FirebaseStorage.instance;
    instance.rootReference = root != null ? root : instance.firestore.doc('');
  }

  DocumentReference rootReference;
  FirebaseFirestore firestore;
  FirebaseStorage firebaseStorage;
}

DocumentReference get rootReference => Flamingo.instance.rootReference;
FirebaseFirestore get firestoreInstance => Flamingo.instance.firestore;
FirebaseStorage get storageInstance => Flamingo.instance.firebaseStorage;
CollectionReference collectionReference(String path) =>
    Flamingo.instance.rootReference.collection(path);
