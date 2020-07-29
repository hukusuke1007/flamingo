import 'dart:async';

import 'flamingo.dart';

abstract class DocumentAccessorRepository {
  Future save(Document document);
  Future<Increment<T>> increment<T extends num>(
    Increment<T> entity,
    DocumentReference reference, {
    num value,
    bool isClear,
  });
  Future update(Document document);
  Future delete(Document document);
  Future saveRaw(
    Map<String, dynamic> values,
    DocumentReference reference, {
    bool isTimestamp = false,
    String createdFieldValueKey = documentCreatedAtKey,
    String updatedFieldValueKey = documentUpdatedAtKey,
  });
  Future updateRaw(
    Map<String, dynamic> values,
    DocumentReference reference, {
    bool isTimestamp = false,
    String updatedFieldValueKey = documentUpdatedAtKey,
  });
  Future deleteWithReference(DocumentReference reference);
  Future<T> load<T extends Document<T>>(Document document, {Source source});
}

class DocumentAccessor implements DocumentAccessorRepository {
  @override
  Future save(Document document) async {
    try {
      final batch = Batch()..save(document);
      await batch.commit();
      document.onCompleted(ExecuteType.create);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<Increment<T>> increment<T extends num>(
    Increment<T> entity,
    DocumentReference reference, {
    num value,
    bool isClear,
  }) async {
    try {
      print(value);
      var updateValue = value;
      if (isClear != null && isClear) {
        updateValue = (T.toString() == 'double') ? 0.0 as T : 0 as T;
      }
      final batch = Batch()
        ..updateRaw(
          entity.toData(updateValue, isClear: isClear),
          reference,
          isTimestamp: true,
        );
      await batch.commit();
      return Increment(entity.fieldName,
          value: updateValue as T, incrementValue: null);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future update(Document document) async {
    try {
      final batch = Batch()..update(document);
      await batch.commit();
      document.onCompleted(ExecuteType.update);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future delete(Document document) async {
    try {
      final batch = Batch()..delete(document);
      await batch.commit();
      document.onCompleted(ExecuteType.delete);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<T> load<T extends Document<T>>(Document document,
      {Source source}) async {
    try {
      Document _document;
      if (source == null) {
        _document = await _load(document, Source.serverAndCache);
      } else {
        _document = await _load(document, source);
      }
      return _document as T;
    } on Exception {
      rethrow;
    }
  }

  Future<Document> _load(Document document, Source source) async {
    try {
      final documentSnapshot =
          await document.reference.get(GetOptions(source: source));
//      print('snapshot ${documentSnapshot.data}');
      if (documentSnapshot.data != null) {
        document.setSnapshot(documentSnapshot);
        return document;
      }
      return null;
    } on Exception {
      rethrow;
    }
  }

  @override
  Future saveRaw(
    Map<String, dynamic> values,
    DocumentReference reference, {
    bool isTimestamp = false,
    String createdFieldValueKey = documentCreatedAtKey,
    String updatedFieldValueKey = documentUpdatedAtKey,
  }) async {
    final data = values;
    final nowAt = Timestamp.now();
    if (isTimestamp) {
      data[createdFieldValueKey] = nowAt;
      data[updatedFieldValueKey] = nowAt;
    }
    final batch = Batch()..saveRaw(values, reference);
    await batch.commit();
  }

  @override
  Future updateRaw(
    Map<String, dynamic> values,
    DocumentReference reference, {
    bool isTimestamp = false,
    String updatedFieldValueKey = documentUpdatedAtKey,
  }) async {
    final data = values;
    final nowAt = Timestamp.now();
    if (isTimestamp) {
      data[updatedFieldValueKey] = nowAt;
    }
    final batch = Batch()..updateRaw(values, reference);
    await batch.commit();
  }

  @override
  Future deleteWithReference(DocumentReference reference) async {
    final batch = Batch()..deleteWithReference(reference);
    await batch.commit();
  }
}
