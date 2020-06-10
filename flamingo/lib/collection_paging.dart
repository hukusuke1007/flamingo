import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'document.dart';

class CollectionPagingModel<T> {
  const CollectionPagingModel({
    @required this.documents,
    @required this.count,
  });
  final List<T> documents;
  final int count;
}

class CollectionPaging {
  CollectionPaging({
    @required this.query,
    @required this.limit,
  });

  final Query query;
  final int limit;
  DocumentSnapshot _startAfterDocument;
  List<Document> _documents = [];

  Future<List<T>> load<T extends Document<T>>({
    Source source = Source.serverAndCache,
  }) =>
      _load<T>(source: source);

  Future<List<T>> loadMore<T extends Document<T>>({
    bool isAll = false,
    Source source = Source.serverAndCache,
  }) async {
    final documents =
        await _load<T>(source: source, startAfterDocument: _startAfterDocument);
    if (isAll) {
      return _documents as List<T>;
    } else {
      return documents;
    }
  }

  Future<List<T>> _load<T extends Document<T>>({
    Source source = Source.serverAndCache,
    DocumentSnapshot startAfterDocument,
  }) async {
    var dataSource = query.limit(limit);
    if (startAfterDocument != null) {
      dataSource = dataSource.startAfterDocument(startAfterDocument);
    }
    final result = await dataSource.getDocuments(source: source);
    final documents = result.documents
        .map((e) =>
            Document<T>(snapshot: e, collectionRef: dataSource.reference())
                as T)
        .toList();
    if (documents.isNotEmpty) {
      _startAfterDocument = documents.last.snapshot;
    }
    if (_startAfterDocument == null) {
      _documents = documents;
    } else {
      _documents.addAll(documents);
    }
    return _documents as List<T>;
  }
}
