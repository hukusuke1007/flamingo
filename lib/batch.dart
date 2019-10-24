import 'package:cloud_firestore/cloud_firestore.dart';
import 'flamingo.dart';
import 'document.dart';

class Batch {
  Batch() {
    _writeBatch = batch();
  }

  WriteBatch _writeBatch;

  void save(Document document) {
    try {
      final data = document.toData();
      final nowAt = Timestamp.now();
      data['createdAt'] = nowAt;
      data['updatedAt'] = nowAt;
      document.createdAt = nowAt;
      document.updatedAt = nowAt;
      _writeBatch.setData(document.reference, data, merge: true);
    } catch (error) {
      throw error;
    }
  }

  void update(Document document) {
    try {
      final data = document.toData();
      final nowAt = Timestamp.now();
      data['updatedAt'] = nowAt;
      document.updatedAt = nowAt;
      _writeBatch.updateData(document.reference, data);
    } catch (error) {
      throw error;
    }
  }

  void delete(Document document) {
    try {
      _writeBatch.delete(document.reference);
    } catch (error) {
      throw error;
    }
  }

  Future commit() async {
    try {
      await _writeBatch.commit();
    } catch (error) {
      throw error;
    }
  }
}