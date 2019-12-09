import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'flamingo.dart';

class DocumentAccessor {
  Future save(Document document) async {
    try {
      final batch = Batch()..save(document);
      await batch.commit();
      document.onCompleted(ExecuteType.create);
    } on Exception {
      rethrow;
    }
  }

  Future<Increment<T>> increment<T extends num>(Increment<T> entity, DocumentReference reference, {
    num value,
    bool isClear,
  }) async {
    try {
      print(value);
      var updateValue = value;
      if (isClear != null && isClear) {
        updateValue = (T.toString() == 'double') ? 0.0 as T : 0 as T;
      }
      final batch = Batch()..updateRaw(
        entity.toData(updateValue, isClear: isClear),
        reference,
        isTimestamp: true,
      );
      await batch.commit();
      return Increment(entity.fieldName, value: updateValue as T, incrementValue: null);
    } on Exception {
      rethrow;
    }
  }

  Future update(Document document) async {
    try {
      final batch = Batch()..update(document);
      await batch.commit();
      document.onCompleted(ExecuteType.update);
    } on Exception {
      rethrow;
    }
  }

  Future delete(Document document) async {
    try {
      final batch = Batch()..delete(document);
      await batch.commit();
      document.onCompleted(ExecuteType.delete);
    } on Exception {
      rethrow;
    }
  }

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
      final documentSnapshot = await document.reference.get(source: source);
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
}
