import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'base.dart';
import 'enum/execute_type.dart';
import 'flamingo.dart';
import 'type/type.dart';


class Document<T> extends Base implements DocumentType {
  /// Constructor
  Document({this.id, this.snapshot, this.values, this.collectionRef}) {
    CollectionReference collectionReference;
    if (collectionRef != null) {
      collectionReference = collectionRef;
    } else {
      collectionReference = collectionRootReference();
    }

    if (id != null) {
      reference = collectionReference.document(id);
    } else {
      reference = collectionReference.document();
      id = reference.documentID;
    }

    if (snapshot != null) {
      setSnapshot(snapshot); // setSnapshotでidが作られる
      reference = collectionReference.document(id);
    }

    if (values != null) {
      _fromAt(values);
      fromData(values);
    }

    collectionPath = collectionReference.path;
    documentPath = reference.path;
  }

  static String path<T extends Document<DocumentType>>({String id}) {
    final collectionPath = Flamingo.instance.rootReference
        .collection(T.toString().toLowerCase())
        .path;
    return id != null ? '$collectionPath/$id' : collectionPath;
  }

  /// Field
  @JsonKey(ignore: true)
  Timestamp createdAt;

  @JsonKey(ignore: true)
  Timestamp updatedAt;

  @JsonKey(ignore: true)
  String id;

  /// Reference
  @JsonKey(ignore: true)
  String collectionPath;

  @JsonKey(ignore: true)
  String documentPath;

  @JsonKey(ignore: true)
  final CollectionReference collectionRef;

  @JsonKey(ignore: true)
  DocumentReference reference;

  @JsonKey(ignore: true)
  final DocumentSnapshot snapshot;

  @JsonKey(ignore: true)
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
    id = documentSnapshot.documentID;
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data;
      _fromAt(data);
      fromData(data);
    }
  }

  /// Private method
  void _fromAt(Map<String, dynamic> data) {
    createdAt = data['createdAt'] as Timestamp;
    updatedAt = data['updatedAt'] as Timestamp;
  }
}
