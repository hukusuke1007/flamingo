import 'package:cloud_firestore/cloud_firestore.dart';
import 'flamingo.dart';
import 'document.dart';

class Batch {
  Batch() {
    _writeBatch = Flamingo.instance.firestore.batch();
  }

  WriteBatch _writeBatch;

  void save(Document document) {
    try {
      final data = document.toData();
      final nowAt = Timestamp.now();
      data['createdAt'] = nowAt;
      data['updatedAt'] = nowAt;
      document
        ..createdAt = nowAt
        ..updatedAt = nowAt;
      _writeBatch.setData(document.reference, data, merge: true);
    } on Exception {
      rethrow;
    }
  }

  void update(Document document) {
    try {
      final data = document.toData();
      final nowAt = Timestamp.now();
      data['updatedAt'] = nowAt;
      document.updatedAt = nowAt;
      _writeBatch.updateData(document.reference, data);
    } on Exception {
      rethrow;
    }
  }

  void delete(Document document) {
    try {
      _writeBatch.delete(document.reference);
    } on Exception {
      rethrow;
    }
  }

  Future commit() async {
    try {
      await _writeBatch.commit();
    } on Exception {
      rethrow;
    }
  }
}
