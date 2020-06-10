import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/document.dart';
import 'package:flutter/foundation.dart';

class CollectionPaging<T extends Document<T>> {
  CollectionPaging({
    @required this.query,
    @required this.limit,
    @required this.decode,
  });

  final Query query;
  final int limit;
  final T Function(DocumentSnapshot, CollectionReference) decode;
  DocumentSnapshot _startAfterDocument;
  List<DocumentSnapshot> _documents = [];

  Future<List<D>> load<D extends Document<D>>({
    Source source = Source.serverAndCache,
  }) async {
    final documents = await _load(source: source);
    return documents
        .map((e) => decode(e, query.reference()))
        .cast<D>()
        .toList();
  }

  Future<List<D>> loadMore<D extends Document<D>>({
    bool isAll = false,
    Source source = Source.serverAndCache,
  }) async {
    final documents = await _load(
        isAll: isAll, source: source, startAfterDocument: _startAfterDocument);
    return documents
        .map((e) => decode(e, query.reference()))
        .cast<D>()
        .toList();
  }

  Future<List<DocumentSnapshot>> _load({
    bool isAll = false,
    Source source = Source.serverAndCache,
    DocumentSnapshot startAfterDocument,
  }) async {
    var dataSource = query.limit(limit);
    if (startAfterDocument != null) {
      dataSource = dataSource.startAfterDocument(startAfterDocument);
    }
    final result = await dataSource.getDocuments(source: source);
    final documents = result.documents.toList();

    if (documents.isNotEmpty) {
      _startAfterDocument = documents.last;
    }
    if (_startAfterDocument == null) {
      _documents = documents;
    } else {
      _documents.addAll(documents);
    }
    if (isAll) {
      return _documents;
    } else {
      return documents;
    }
  }
}
