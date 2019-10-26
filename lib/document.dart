import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'flamingo.dart';

class Document<T> {

  static String path<T extends Document>({String id}) {
    final collectionPath = Flamingo.instance.rootReference.collection(T.toString().toLowerCase()).path;
    return id != null ? '$collectionPath/$id' : collectionPath;
  }

  /// Constructor
  Document({this.id, this.snapshot, this.values, this.collectionRef}) {
    CollectionReference collectionReference;
    if (this.collectionRef != null) {
      collectionReference = this.collectionRef;
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
  CollectionReference collectionRef;

  @JsonKey(ignore: true)
  DocumentReference reference;

  @JsonKey(ignore: true)
  DocumentSnapshot snapshot;

  @JsonKey(ignore: true)
  Map<String, dynamic> values;

  /// Public method.
  String modelName() {
    return this.toString().split(" ")[2].replaceAll("\'", "").toLowerCase();
  }

  CollectionReference collectionRootReference() {
    return Flamingo.instance.rootReference.collection(modelName());
  }

  Map<String, dynamic> toData() => Map<String, dynamic>(); /// Data for save
  void fromData(Map<String, dynamic> data){}               /// Data for load

  void setSnapshot(DocumentSnapshot documentSnapshot){
    id = documentSnapshot.documentID;
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data;
      _fromAt(data);
      fromData(data);
    }
  }

  void writeNotNull(Map<String, dynamic> data, String key, dynamic value) {
    if (value != null) {
      data[key] = value;
    }
  }

  T valueFromKey<T>(Map<String, dynamic> data, String key) => data[key] as T;

  T valueListFromKey<T extends List>(Map<String, dynamic> data, String key) {
    return (data[key] as List)?.map((e) => e as String)?.toList() as T;
  }

  bool isVal(Map<String, dynamic> data, String key) => data.containsKey(key);

  /// Private method
  void _fromAt(Map<String, dynamic> data) {
    createdAt = data['createdAt'] as Timestamp;
    updatedAt = data['updatedAt'] as Timestamp;
  }
}