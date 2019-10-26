import 'package:cloud_firestore/cloud_firestore.dart';
import 'document.dart';
import 'batch.dart';
import 'dart:async';

class DocumentAccessor {

  Future save(Document document) async {
    try {
//      final data = document.toData();
//      final nowAt = Timestamp.now();
//      data['createdAt'] = nowAt;
//      data['updatedAt'] = nowAt;
//      document.createdAt = nowAt;
//      document.updatedAt = nowAt;
//      await document.reference.setData(data, merge: true);
      final batch = Batch();
      batch.save(document);
      await batch.commit();
    } catch (error) {
      throw error;
    }
  }

  Future update(Document document) async {
    try {
//      final data = document.toData();
//      final nowAt = Timestamp.now();
//      data['updatedAt'] = nowAt;
//      document.updatedAt = nowAt;
//      await document.reference.updateData(data);
      final batch = Batch();
      batch.update(document);
      await batch.commit();
    } catch (error) {
      throw error;
    }
  }

  Future delete(Document document) async {
    try {
//      await document.reference.delete();
      final batch = Batch();
      batch.delete(document);
      await batch.commit();
    } catch (error) {
      throw error;
    }
  }

  Future<T> load<T extends Document>(Document document, {Source source}) async {
    try {
      if (source == null) {
        await _load(document, Source.serverAndCache);
      } else {
        await _load(document, source);
      }
      return document as T;
    } catch (error) {
      throw error;
    }
  }

  Future _load(Document document, Source source) async {
    try {
      final documentSnapshot = await document.reference.get(source: source);
//      print('snapshot ${documentSnapshot.data}');
      document.setSnapshot(documentSnapshot);
    } catch (error) {
      throw error;
    }
  }
}

