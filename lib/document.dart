import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'flamingo.dart';
import 'type/type.dart';

class Document<T> implements DocumentType {
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
    final collectionPath = Flamingo.instance.rootReference.collection(T.toString().toLowerCase()).path;
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
  CollectionReference collectionRef;

  @JsonKey(ignore: true)
  DocumentReference reference;

  @JsonKey(ignore: true)
  DocumentSnapshot snapshot;

  @JsonKey(ignore: true)
  Map<String, dynamic> values;

  /// Public method.
  String modelName() {
    return toString().split(' ')[2].replaceAll("\'", '').toLowerCase();
  }

  CollectionReference collectionRootReference() {
    return Flamingo.instance.rootReference.collection(modelName());
  }

  Map<String, dynamic> toData() => <String, dynamic>{}; /// Data for save
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

  void writeStorage(Map<String, dynamic> data, String key, StorageFile storageFile,) {
    if (storageFile != null) {
      if (!storageFile.isDeleted) {
        data[key] = storageFile.toJson();
      } else {
        data[key] = FieldValue.delete();
      }
    }
  }

  void writeStorageList(Map<String, dynamic> data, String key, List<StorageFile> storageFiles) {
    if (storageFiles != null) {
      if (storageFiles.isNotEmpty) {
        data[key] = storageFiles.map((d) => d.toJson()).toList();
      } else {
        data[key] = FieldValue.delete();
      }
    }
  }

  StorageFile storageFile(Map<String, dynamic> data, String folderName) {
    final fileMap = valueMapFromKey<String, dynamic>(data, folderName);
    if (fileMap != null) {
      return StorageFile.fromJson(fileMap);
    } else {
      return null;
    }
  }

  List<StorageFile> storageFiles(Map<String, dynamic> data, String folderName) {
    final fileMapList = valueMapListFromKey<String, dynamic>(data, folderName);
    if (fileMapList != null) {
      return fileMapList.map((d) => StorageFile.fromJson(d)).toList();
    } else {
      return null;
    }
  }

  T valueFromKey<T>(Map<String, dynamic> data, String key) => data[key] as T;
  Map<T, U> valueMapFromKey<T, U>(Map<String, dynamic> data, String key) => isVal(data, key) ? Map<T, U>.from(Helper.fromMap(data[key] as Map)) : null;
  List<T> valueListFromKey<T>(Map<String, dynamic> data, String key) => (data[key] as List)?.map((dynamic e) => e as T)?.toList();
  List<Map<T, U>> valueMapListFromKey<T, U>(Map<String, dynamic> data, String key)  => isVal(data, key) ? (data[key] as List).map((dynamic d) => Map<T, U>.from(d as Map)).toList() : null;

  bool isVal(Map<String, dynamic> data, String key) => data.containsKey(key);

  /// Private method
  void _fromAt(Map<String, dynamic> data) {
    createdAt = data['createdAt'] as Timestamp;
    updatedAt = data['updatedAt'] as Timestamp;
  }
}