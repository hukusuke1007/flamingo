import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';
import 'enum/execute_type.dart';
import 'flamingo.dart';
import 'type/type.dart';

class Document<T> extends Base implements DocumentType {
  Document({
    String id,
    String documentPath,
    String collectionPath,
    this.snapshot,
    this.values,
    CollectionReference collectionRef,
  }) : assert(id == null || documentPath == null, 'Can be used only either of \'id\' or \'documentPath\'.'),
        assert(documentPath == null || collectionPath == null, 'Can be used only either of \'documentPath\' or \'collectionPath\'.'),
        assert(collectionPath == null || collectionRef == null, 'Can be used only either of \'collectionPath\' or \'collectionRef\'.')
  {
    if (documentPath != null) {
      /// From reference path.
      final _referenceDocument = Flamingo.instance.firestore.document(documentPath);
      _id = _referenceDocument.documentID;
      _collectionRef = _referenceDocument.parent();
      _reference = _referenceDocument;
    } else {
      /// From id.
      _id = id;

      /// From collectionPath or collectionRef.
      if (collectionPath != null) {
        _collectionRef = Flamingo.instance.firestore.collection(collectionPath);
      } else {
        if (collectionRef != null) {
          _collectionRef = collectionRef;
        } else {
          _collectionRef = collectionRootReference;
        }
      }

      if (id != null) {
        _reference = _collectionRef.document(_id);
      } else {
        _reference = _collectionRef.document();
        _id = _reference.documentID;
      }

      /// From snapshot.
      if (snapshot != null) {
        setSnapshot(snapshot); // setSnapshotでidが作られる
        _reference = _collectionRef.document(_id);
      }
    }

    /// From values
    if (values != null) {
      _fromAt(values);
      fromData(values);
    }

    /// Set path
    _collectionPath = _collectionRef.path;
    _documentPath = _reference.path;
  }

  static String path<T extends Document<DocumentType>>({String id}) {
    final collectionPath = Flamingo.instance.rootReference
        .collection(T.toString().toLowerCase())
        .path;
    return id != null ? '$collectionPath/$id' : collectionPath;
  }
  /// For constructor
  final DocumentSnapshot snapshot;
  final Map<String, dynamic> values;

  /// Field
  Timestamp createdAt;
  Timestamp updatedAt;

  String _id;
  String get id => _id;

  /// For reference
  String get modelName => toString().split(' ')[2].replaceAll("\'", '').toLowerCase();
  CollectionReference get collectionRootReference => Flamingo.instance.rootReference.collection(modelName);

  String _collectionPath;
  String get collectionPath => _collectionPath;

  String _documentPath;
  String get documentPath => _documentPath;

  CollectionReference _collectionRef;
  CollectionReference get collectionRef => _collectionRef;

  DocumentReference _reference;
  DocumentReference get reference => _reference;

  /// Data for save
  Map<String, dynamic> toData() => <String, dynamic>{};

  /// Data for load
  void fromData(Map<String, dynamic> data) {}

  /// Completed of create and update and delete.
  void onCompleted(ExecuteType executeType) {}

  /// Set snapshot and documentId.
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
