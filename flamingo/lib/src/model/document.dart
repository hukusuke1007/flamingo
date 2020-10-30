import '../../flamingo.dart';
import '../base.dart';

class Document<T> extends Base implements DocumentType {
  Document({
    String id,
    String documentPath,
    String collectionPath,
    this.snapshot,
    this.values,
    CollectionReference collectionRef,
  })  : assert(id == null || documentPath == null,
            'Can be used only either of \'id\' or \'documentPath\'.'),
        // ignore: lines_longer_than_80_chars
        assert(
            documentPath == null || collectionPath == null,
            // ignore: lines_longer_than_80_chars
            'Can be used only either of \'documentPath\' or \'collectionPath\'.'),
        assert(
            collectionPath == null || collectionRef == null,
            // ignore: lines_longer_than_80_chars
            'Can be used only either of \'collectionPath\' or \'collectionRef\'.') {
    if (documentPath != null) {
      /// From reference path.
      final _referenceDocument = Flamingo.instance.firestore.doc(documentPath);
      _id = _referenceDocument.id;
      _collectionRef = _referenceDocument.parent;
      _reference = _referenceDocument;
    } else {
      /// Set id
      _id = id;

      /// Set collectionRef
      if (collectionPath != null) {
        _collectionRef = Flamingo.instance.firestore.collection(collectionPath);
      } else if (collectionRef != null) {
        _collectionRef = collectionRef;
      } else if (snapshot != null) {
        _collectionRef = snapshot.reference.parent;
      } else {
        _collectionRef = collectionRootReference;
      }

      /// Set reference
      if (id != null) {
        _reference = _collectionRef.doc(_id);
      } else {
        _reference = _collectionRef.doc();
        _id = _reference.id;
      }

      /// From snapshot
      if (snapshot != null) {
        setSnapshot(snapshot); // setSnapshotでidが作られる
        _reference = _collectionRef.doc(_id);
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

  static String path<T extends Document<DocumentType>>({
    String id,
    String collectionPath,
  }) {
    if (collectionPath != null) {
      return id != null ? '$collectionPath/$id' : collectionPath;
    } else {
      final _collectionPath = Flamingo.instance.rootReference
          .collection(T.toString().toLowerCase())
          .path;
      return id != null ? '$_collectionPath/$id' : _collectionPath;
    }
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
  String get modelName =>
      toString().split(' ')[2].replaceAll("\'", '').toLowerCase();
  CollectionReference get collectionRootReference =>
      Flamingo.instance.rootReference.collection(modelName);

  String _collectionPath;
  String get collectionPath => _collectionPath;

  String _documentPath;
  String get documentPath => _documentPath;

  CollectionReference _collectionRef;
  CollectionReference get collectionRef => _collectionRef;

  DocumentReference _reference;
  DocumentReference get reference => _reference;

  String get createdFieldValueKey => documentCreatedAtKey;
  String get updatedFieldValueKey => documentUpdatedAtKey;

  /// Data for save
  Map<String, dynamic> toData() => <String, dynamic>{};

  /// Data for load
  void fromData(Map<String, dynamic> data) {}

  /// Completed of create and update and delete.
  void onCompleted(ExecuteType executeType) {}

  /// Set snapshot and documentId.
  void setSnapshot(DocumentSnapshot documentSnapshot) {
    _id = documentSnapshot.id;
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data();
      _fromAt(data);
      fromData(data);
    }
  }

  /// Private method
  void _fromAt(Map<String, dynamic> data) {
    if (data[createdFieldValueKey] is Map) {
      createdAt = timestampFromMap(data, createdFieldValueKey);
    } else if (data[createdFieldValueKey] is Timestamp) {
      createdAt = data[createdFieldValueKey] as Timestamp;
    }

    if (data[updatedFieldValueKey] is Map) {
      updatedAt = timestampFromMap(data, updatedFieldValueKey);
    } else if (data[updatedFieldValueKey] is Timestamp) {
      updatedAt = data[updatedFieldValueKey] as Timestamp;
    }
  }
}
