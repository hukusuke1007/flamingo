import 'package:cloud_firestore/cloud_firestore.dart'
    show
        CollectionReference,
        DocumentReference,
        FirebaseFirestore,
        PersistenceSettings,
        Settings;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' show FirebaseStorage;
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_storage/firebase_storage.dart';

export 'src/batch.dart';
export 'src/collection_paging.dart';
export 'src/collection_paging_listener.dart';
export 'src/constants.dart';
export 'src/distributed_counter.dart';
export 'src/document_accessor.dart';
export 'src/enum/execute_type.dart';
export 'src/helper/helper.dart';
export 'src/master/master.dart';
export 'src/model/collection.dart';
export 'src/model/counter.dart';
export 'src/model/document.dart';
export 'src/model/increment.dart';
export 'src/model/model.dart';
export 'src/model/storage_file.dart';
export 'src/run_transaction.dart';
export 'src/storage.dart';
export 'src/type/type.dart';

/// Flamingo
class Flamingo {
  /// Flamingo instance
  static Flamingo instance = Flamingo();

  /// Flamingo initializeApp. Required before using Firebase.
  static Future<void> initializeApp({
    String? name,
    FirebaseOptions? options,
    Settings? settings,
    String? rootPath,
    bool isWebCache = true,
  }) async {
    await Firebase.initializeApp(name: name, options: options);
    overrideWithSetting(
      settings: settings,
      rootPath: rootPath,
      isWebCache: isWebCache,
    );
  }

  /// Update Firebase instance and reference and settings
  static void overrideWithSetting({
    FirebaseFirestore? firestoreInstance,
    FirebaseStorage? storageInstance,
    Settings? settings,
    String? rootPath,
    required bool isWebCache,
  }) {
    if (settings != null) {
      FirebaseFirestore.instance.settings = settings;
    }
    if (kIsWeb && isWebCache) {
      FirebaseFirestore.instance.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
    }
    instance._firestore = firestoreInstance ?? FirebaseFirestore.instance;
    instance._firebaseStorage = storageInstance ?? FirebaseStorage.instance;
    instance._rootReference = instance.firestore.doc(rootPath ?? '/');
  }

  /// Set emulator
  static Future<void> configureEmulator({
    int firestorePort = 8080,
    int storagePort = 9099,
    bool persistenceEnabled = false,
    bool sslEnabled = false,
  }) async {
    FirebaseFirestore.instance.settings = getEmulatorSettings(
      port: firestorePort,
      persistenceEnabled: persistenceEnabled,
      sslEnabled: sslEnabled,
    );
    await configureStorageEmulator(port: storagePort);
  }

  /// Get emulator settings
  static Settings getEmulatorSettings({
    int port = 8080,
    bool persistenceEnabled = false,
    bool sslEnabled = false,
  }) =>
      Settings(
        persistenceEnabled: persistenceEnabled,
        host: '${Platform.isAndroid ? '10.0.2.2' : 'localhost'}:$port',
        sslEnabled: sslEnabled,
      );

  /// Setting Storage Emulator
  static Future<void> configureStorageEmulator({
    int port = 9199,
  }) =>
      FirebaseStorage.instance.useStorageEmulator(
        Platform.isAndroid ? '10.0.2.2' : 'localhost',
        port,
      );

  /// Clear cache
  static Future<void> clearCache() =>
      Flamingo.instance.firestore.clearPersistence();

  DocumentReference<Map<String, dynamic>> get rootReference => _rootReference;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get firebaseStorage => _firebaseStorage;

  late DocumentReference<Map<String, dynamic>> _rootReference;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _firebaseStorage;
}

/// Firestore Instance
FirebaseFirestore get firestoreInstance => Flamingo.instance.firestore;

/// FirebaseStorage Instance
FirebaseStorage get storageInstance => Flamingo.instance.firebaseStorage;

/// RootReference
DocumentReference<Map<String, dynamic>> get rootReference =>
    Flamingo.instance.rootReference;

/// CollectionReference
CollectionReference collectionReference(String path) =>
    Flamingo.instance.rootReference.collection(path);
