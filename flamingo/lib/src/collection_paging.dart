import 'package:cloud_firestore/cloud_firestore.dart';

import 'model/document.dart';

class CollectionPaging<T extends Document<T>> {
  CollectionPaging({
    required this.query,
    this.limit,
    required this.decode,
  });

  final Query<Map<String, dynamic>> query;
  final int? limit;
  final T Function(DocumentSnapshot<Map<String, dynamic>>) decode;
  DocumentSnapshot<Map<String, dynamic>>? _startAfterDocument;

  Future<List<T>> load({
    Source source = Source.serverAndCache,
    Function(List<T>)? fromCache,
  }) async {
    if (fromCache != null) {
      try {
        final cacheDocuments = await _load(source: Source.cache);
        fromCache(cacheDocuments.map(decode).cast<T>().toList());
      } on Exception catch (_) {
        fromCache([]);
      }
    }
    final documents = await _load(source: source);
    return documents.map(decode).cast<T>().toList();
  }

  Future<List<T>> loadMore({
    Source source = Source.serverAndCache,
  }) async {
    final documents =
        await _load(source: source, startAfterDocument: _startAfterDocument);
    return documents.map(decode).cast<T>().toList();
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _load({
    Source source = Source.serverAndCache,
    DocumentSnapshot? startAfterDocument,
  }) async {
    var dataSource = query;
    if (limit != null) {
      dataSource = dataSource.limit(limit!);
    }
    if (startAfterDocument != null) {
      dataSource = dataSource.startAfterDocument(startAfterDocument);
    }
    final result = await dataSource.get(GetOptions(source: source));
    final documents = result.docs.toList();

    if (documents.isNotEmpty) {
      _startAfterDocument = documents.last;
    }
    return documents;
  }
}
