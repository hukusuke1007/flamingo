import '../../flamingo.dart';
import '../base.dart';

class Document<T> extends Base implements DocumentType {
  Document({
    String? id,
    String? documentPath,
    String? collectionPath,
    this.snapshot,
    this.values,
    CollectionReference<Map<String, dynamic>>? collectionRef,
  })  : assert(
          id == null || documentPath == null,
          'Can be used only either of \'id\' or \'documentPath\'.',
        ),
        // ignore: lines_longer_than_80_chars
        assert(
          documentPath == null || collectionPath == null,
          // ignore: lines_longer_than_80_chars
          'Can be used only either of \'documentPath\' or \'collectionPath\'.',
        ),
        assert(
          collectionPath == null || collectionRef == null,
          // ignore: lines_longer_than_80_chars
          'Can be used only either of \'collectionPath\' or \'collectionRef\'.',
        ) {
    if (documentPath != null) {
      /// From reference path.
      final referenceDocument = Flamingo.instance.firestore.doc(documentPath);
      _id = referenceDocument.id;
      _collectionRef = referenceDocument.parent;
      _reference = referenceDocument;
    } else {
      /// Set collectionRef
      if (collectionPath != null) {
        _collectionRef = Flamingo.instance.firestore.collection(collectionPath);
      } else if (collectionRef != null) {
        _collectionRef = collectionRef;
      } else if (snapshot != null) {
        _collectionRef = snapshot!.reference.parent;
      } else {
        _collectionRef = collectionRootReference;
      }

      /// Set reference and Id
      if (id != null) {
        _reference = _collectionRef.doc(id);
        _id = id;
      } else {
        _reference = _collectionRef.doc();
        _id = _reference.id;
      }

      /// From snapshot
      if (snapshot != null) {
        setSnapshot(snapshot!); // setSnapshotでidが作られる
        _reference = _collectionRef.doc(_id);
      }
    }

    /// From values
    if (values != null) {
      _fromAt(values!);
      fromData(values!);
    }

    /// Set path
    _collectionPath = _collectionRef.path;
    _documentPath = _reference.path;
  }

  static String path<T extends Document<DocumentType>>({
    String? id,
    String? collectionPath,
  }) {
    if (collectionPath != null) {
      return id != null ? '$collectionPath/$id' : collectionPath;
    } else {
      final collectionPath0 = Flamingo.instance.rootReference
          .collection(T.toString().toLowerCase())
          .path;
      return id != null ? '$collectionPath0/$id' : collectionPath0;
    }
  }

  /// For constructor
  final DocumentSnapshot<Map<String, dynamic>>? snapshot;
  final Map<String, dynamic>? values;

  /// Field
  Timestamp? _createdAt;
  Timestamp? get createdAt => _createdAt;

  Timestamp? _updatedAt;
  Timestamp? get updatedAt => _updatedAt;

  late String _id;
  String get id => _id;

  /// For reference
  String get modelName => toString()
      .replaceAll('*', '')
      .split(' ')[2]
      .replaceAll("'", '')
      .toLowerCase();

  CollectionReference<Map<String, dynamic>> get collectionRootReference =>
      Flamingo.instance.rootReference.collection(modelName);

  late String _collectionPath;
  String get collectionPath => _collectionPath;

  late String _documentPath;
  String get documentPath => _documentPath;

  late CollectionReference<Map<String, dynamic>> _collectionRef;
  CollectionReference<Map<String, dynamic>> get collectionRef => _collectionRef;

  late DocumentReference<Map<String, dynamic>> _reference;
  DocumentReference<Map<String, dynamic>> get reference => _reference;

  String get createdFieldValueKey => documentCreatedAtKey;
  String get updatedFieldValueKey => documentUpdatedAtKey;

  /// Data for save
  Map<String, dynamic> toData() => <String, dynamic>{};

  /// Data for load
  void fromData(Map<String, dynamic> data) {}

  /// Completed of create and update and delete.
  void onCompleted(ExecuteType executeType) {}

  /// Set snapshot and documentId.
  void setSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    _id = snap.id;
    if (snap.exists && snap.data() != null) {
      final data = snap.data()!;
      _fromAt(data);
      fromData(data);
    }
  }

  void setAt({
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  /// Private method
  void _fromAt(Map<String, dynamic> data) {
    if (data[createdFieldValueKey] is Map) {
      _createdAt = timestampFromMap(data, createdFieldValueKey);
    } else if (data[createdFieldValueKey] is Timestamp) {
      _createdAt = data[createdFieldValueKey] as Timestamp;
    }

    if (data[updatedFieldValueKey] is Map) {
      _updatedAt = timestampFromMap(data, updatedFieldValueKey);
    } else if (data[updatedFieldValueKey] is Timestamp) {
      _updatedAt = data[updatedFieldValueKey] as Timestamp;
    }
  }
}
