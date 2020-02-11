import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';
import 'enum/execute_type.dart';
import 'flamingo.dart';
import 'type/type.dart';

class Document<T> extends Base implements DocumentType {
  Document({
    String id,
    this.snapshot,
    this.values,
    CollectionReference collectionRef,
  }) {
    _id = id;
    if (collectionRef != null) {
      _collectionRef = collectionRef;
    } else {
      _collectionRef = collectionRootReference();
    }

    if (id != null) {
      _reference = _collectionRef.document(_id);
    } else {
      _reference = _collectionRef.document();
      _id = _reference.documentID;
    }

    if (snapshot != null) {
      setSnapshot(snapshot); // setSnapshotでidが作られる
      _reference = _collectionRef.document(_id);
    }

    if (values != null) {
      _fromAt(values);
      fromData(values);
    }

    _collectionPath = _collectionRef.path;
    _documentPath = _reference.path;
  }

  static String path<T extends Document<DocumentType>>({String id}) {
    final collectionPath = Flamingo.instance.rootReference
        .collection(T.toString().toLowerCase())
        .path;
    return id != null ? '$collectionPath/$id' : collectionPath;
  }

  /// Field
  Timestamp createdAt;
  Timestamp updatedAt;

  String _id;
  String get id => _id;

  /// Reference
  String _collectionPath;
  String get collectionPath => _collectionPath;

  String _documentPath;
  String get documentPath => _documentPath;

  CollectionReference _collectionRef;
  CollectionReference get collectionRef => _collectionRef;

  DocumentReference _reference;
  DocumentReference get reference => _reference;

  /// For constructor
  final DocumentSnapshot snapshot;
  final Map<String, dynamic> values;

  /// Public method.
  String modelName() {
    return toString().split(' ')[2].replaceAll("\'", '').toLowerCase();
  }

  CollectionReference collectionRootReference() {
    return Flamingo.instance.rootReference.collection(modelName());
  }

  /// Data for save
  Map<String, dynamic> toData() => <String, dynamic>{};

  /// Data for load
  void fromData(Map<String, dynamic> data) {}

  /// Completed create, update, delete.
  void onCompleted(ExecuteType executeType) {}

  void setSnapshot(DocumentSnapshot documentSnapshot) {
    _id = documentSnapshot.documentID;
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data;
      _fromAt(data);
      fromData(data);
    }
  }

  /// Private method
  void _fromAt(Map<String, dynamic> data) {
    const createdAtKey = 'createdAt';
    if (data[createdAtKey] is Map) {
      createdAt = timestampFromMap(data, createdAtKey);
    } else if (data[createdAtKey] is Timestamp) {
      createdAt = data[createdAtKey] as Timestamp;
    }

    const updatedAtKey = 'updatedAt';
    if (data[updatedAtKey] is Map) {
      updatedAt = timestampFromMap(data, updatedAtKey);
    } else if (data[updatedAtKey] is Timestamp) {
      updatedAt = data[updatedAtKey] as Timestamp;
    }
  }
}
