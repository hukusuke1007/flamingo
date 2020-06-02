import 'flamingo.dart';

abstract class BatchRepository {
  bool get isAddedDocument;
  int get addedDocumentCount;
  void save(
    Document document, {
    DocumentReference reference,
  });
  void update(
    Document document, {
    DocumentReference reference,
  });
  void delete(
    Document document, {
    DocumentReference reference,
  });
  void saveRaw(
    Map<String, dynamic> values,
    DocumentReference reference, {
    bool isTimestamp = false,
    String createdFieldValueKey = documentCreatedAtKey,
    String updatedFieldValueKey = documentUpdatedAtKey,
  });
  void updateRaw(
    Map<String, dynamic> values,
    DocumentReference reference, {
    bool isTimestamp = false,
    String updatedFieldValueKey = documentUpdatedAtKey,
  });
  void deleteWithReference(DocumentReference reference);
  Future commit();
}

class Batch implements BatchRepository {
  Batch() {
    _writeBatch = Flamingo.instance.firestore.batch();
  }
  @override
  bool get isAddedDocument => _batchDocument.isNotEmpty;

  @override
  int get addedDocumentCount => _batchDocument.length;

  WriteBatch _writeBatch;
  final List<_BatchDocument> _batchDocument = [];

  @override
  void save(
    Document document, {
    DocumentReference reference,
  }) {
    final data = document.toData();
    final nowAt = Timestamp.now();
    data[document.createdFieldValueKey] = nowAt;
    data[document.updatedFieldValueKey] = nowAt;
    document
      ..createdAt = nowAt
      ..updatedAt = nowAt;
    _writeBatch.setData(
        reference != null ? reference : document.reference, data,
        merge: true);
    _batchDocument.add(_BatchDocument(document, ExecuteType.create));
  }

  @override
  void update(
    Document document, {
    DocumentReference reference,
  }) {
    final data = document.toData();
    final nowAt = Timestamp.now();
    data[document.updatedFieldValueKey] = nowAt;
    document.updatedAt = nowAt;
    _writeBatch.updateData(
        reference != null ? reference : document.reference, data);
    _batchDocument.add(_BatchDocument(document, ExecuteType.update));
  }

  @override
  void delete(
    Document document, {
    DocumentReference reference,
  }) {
    _writeBatch.delete(reference != null ? reference : document.reference);
    _batchDocument.add(_BatchDocument(document, ExecuteType.delete));
  }

  @override
  void saveRaw(
    Map<String, dynamic> values,
    DocumentReference reference, {
    bool isTimestamp = false,
    String createdFieldValueKey = documentCreatedAtKey,
    String updatedFieldValueKey = documentUpdatedAtKey,
  }) {
    final data = values;
    final nowAt = Timestamp.now();
    if (isTimestamp) {
      data[createdFieldValueKey] = nowAt;
      data[updatedFieldValueKey] = nowAt;
    }
    _writeBatch.setData(reference, data, merge: true);
  }

  @override
  void updateRaw(
    Map<String, dynamic> values,
    DocumentReference reference, {
    bool isTimestamp = false,
    String updatedFieldValueKey = documentUpdatedAtKey,
  }) {
    final data = values;
    final nowAt = Timestamp.now();
    if (isTimestamp) {
      data[updatedFieldValueKey] = nowAt;
    }
    _writeBatch.updateData(reference, data);
  }

  @override
  void deleteWithReference(DocumentReference reference) {
    _writeBatch.delete(reference);
  }

  @override
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
