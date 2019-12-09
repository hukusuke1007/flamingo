import 'package:cloud_firestore/cloud_firestore.dart';
import 'document.dart';
import 'flamingo.dart';

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

  void saveRaw(Map<String, dynamic> values, DocumentReference reference, {bool isTimestamp = false}) {
    try {
      final data = values;
      final nowAt = Timestamp.now();
      if (isTimestamp) {
        data['createdAt'] = nowAt;
        data['updatedAt'] = nowAt;
      }
      _writeBatch.setData(reference, data, merge: true);
    } on Exception {
      rethrow;
    }
  }

  void updateRaw(Map<String, dynamic> values, DocumentReference reference, {bool isTimestamp = false}) {
    try {
      final data = values;
      final nowAt = Timestamp.now();
      if (isTimestamp) {
        data['updatedAt'] = nowAt;
      }
      _writeBatch.updateData(reference, data);
    } on Exception {
      rethrow;
    }
  }

  void deleteWithReference(DocumentReference reference) {
    try {
      _writeBatch.delete(reference);
    } on Exception {
      rethrow;
    }
  }

  Future commit({Document document}) async {
    try {
      await _writeBatch.commit();
      document?.onCompleted();
    } on Exception {
      rethrow;
    }
  }
}
