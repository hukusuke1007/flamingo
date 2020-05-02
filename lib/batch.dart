import 'package:cloud_firestore/cloud_firestore.dart';
import 'document.dart';
import 'flamingo.dart';

class Batch {
  Batch() {
    _writeBatch = Flamingo.instance.firestore.batch();
  }
  bool get isAddedDocument => _batchDocument.isNotEmpty;
  int get addedDocumentCount => _batchDocument.length;

  WriteBatch _writeBatch;
  final List<_BatchDocument> _batchDocument = [];

  void save(Document document, {
    DocumentReference reference,
  }) {
    final data = document.toData();
    final nowAt = Timestamp.now();
    data['createdAt'] = nowAt;
    data['updatedAt'] = nowAt;
    document
      ..createdAt = nowAt
      ..updatedAt = nowAt;
    _writeBatch.setData(reference != null ? reference : document.reference, data, merge: true);
    _batchDocument.add(_BatchDocument(document, ExecuteType.create));
  }

  void update(Document document, {
    DocumentReference reference,
  }) {
    final data = document.toData();
    final nowAt = Timestamp.now();
    data['updatedAt'] = nowAt;
    document.updatedAt = nowAt;
    _writeBatch.updateData(reference != null ? reference : document.reference, data);
    _batchDocument.add(_BatchDocument(document, ExecuteType.update));
  }

  void delete(Document document, {
    DocumentReference reference,
  }) {
    _writeBatch.delete(reference != null ? reference : document.reference);
    _batchDocument.add(_BatchDocument(document, ExecuteType.delete));
  }

  void saveRaw(Map<String, dynamic> values, DocumentReference reference, {
    bool isTimestamp = false,
  }) {
    final data = values;
    final nowAt = Timestamp.now();
    if (isTimestamp) {
      data['createdAt'] = nowAt;
      data['updatedAt'] = nowAt;
    }
    _writeBatch.setData(reference, data, merge: true);
  }

  void updateRaw(Map<String, dynamic> values, DocumentReference reference, {
    bool isTimestamp = false,
  }) {
    final data = values;
    final nowAt = Timestamp.now();
    if (isTimestamp) {
      data['updatedAt'] = nowAt;
    }
    _writeBatch.updateData(reference, data);
  }

  void deleteWithReference(DocumentReference reference) {
    _writeBatch.delete(reference);
  }

  Future commit() async {
    await _writeBatch.commit();
    for (var item in _batchDocument) {
      item.document.onCompleted(item.executeType);
    }
    _batchDocument.clear();
  }
}

class _BatchDocument {
  _BatchDocument(this.document, this.executeType);
  final Document document;
  final ExecuteType executeType;
}