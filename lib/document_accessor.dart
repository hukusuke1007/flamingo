import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'batch.dart';
import 'document.dart';

class DocumentAccessor {

  Future save(Document document) async {
    try {
      final batch = Batch()
        ..save(document);
      await batch.commit();
    } on Exception {
      rethrow;
    }
  }

  Future update(Document document) async {
    try {
      final batch = Batch()
        ..update(document);
      await batch.commit();
    } on Exception {
      rethrow;
    }
  }

  Future delete(Document document) async {
    try {
      final batch = Batch()
        ..delete(document);
      await batch.commit();
    } on Exception {
      rethrow;
    }
  }

  Future<T> load<T extends Document<T>>(Document document, {Source source}) async {
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

