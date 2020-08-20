import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import 'model/document.dart';

class CollectionPagingListener<T extends Document<T>> {
  CollectionPagingListener({
    @required this.query,
    this.collectionReference,
    @required this.initialLimit,
    @required this.pagingLimit,
    @required this.decode,
  });

  final Query query;
  final CollectionReference collectionReference;
  final int initialLimit;
  final int pagingLimit;
  final T Function(DocumentSnapshot, CollectionReference) decode;

  ValueStream<List<T>> get data => _dataController.stream;
  int get count => _dataController.value.length;

  bool _initLoaded = false;
  final BehaviorSubject<List<T>> _dataController =
      BehaviorSubject<List<T>>.seeded([]);
  DocumentSnapshot _startAfterDocument;
  StreamSubscription<QuerySnapshot> _disposer;

  Future<void> dispose() async {
    await _disposer?.cancel();
    await _dataController.close();
  }

  void fetch() async {
    assert(_disposer != null,
        'Already set disposer. If you want to re-fetch, fetch after dispose');
    final _query = query.limit(initialLimit);
    _disposer ??= _query.snapshots().listen((event) {
      // TODO(shohei): delete log
      print(
          'snapshot listen isNotEmpty: ${event.docs.isNotEmpty} docChanges: ${event.docChanges.length}');
      if (_initLoaded) {
        final docs = _dataController.value;
        for (var change in event.docChanges) {
          // TODO(shohei): delete log
          print(
              'id: ${change.doc.id}, changeType: ${change.type}, cache: ${change.doc.metadata.isFromCache}');
          final data = decode(change.doc, collectionReference);
          if (change.type == DocumentChangeType.added) {
            if (!change.doc.metadata.isFromCache) {
              docs.insert(0, data);
            }
          } else if (change.type == DocumentChangeType.modified) {
            // TODO(shohei): modify
            final index =
                docs.indexWhere((element) => element.id == change.doc.id);
            docs[index] = data;
          } else if (change.type == DocumentChangeType.removed) {
            docs.removeWhere((element) => element.id == change.doc.id);
          }
        }
        _dataController.add(docs);
      } else {
        _dataController.add(
            event.docs.map((e) => decode(e, collectionReference)).toList());
        _startAfterDocument = event.docs.last;
        _initLoaded = true;
      }
    });
  }

  Future<void> refresh({
    Source source = Source.serverAndCache,
  }) async {
    final documents = await _load(limit: initialLimit, source: source);
    final data = documents.map((e) => decode(e, collectionReference)).toList();
    _dataController.add(data);
  }

  Future<void> loadMore({
    Source source = Source.serverAndCache,
  }) async {
    if (_startAfterDocument == null) {
      return;
    }
    final documents = await _load(
        limit: pagingLimit,
        source: source,
        startAfterDocument: _startAfterDocument);
    final data = _dataController.value
      ..addAll(documents.map((e) => decode(e, collectionReference)));
    _dataController.add(data);
  }

  Future<List<DocumentSnapshot>> _load({
    int limit = 20,
    Source source = Source.serverAndCache,
    DocumentSnapshot startAfterDocument,
  }) async {
    var dataSource = query.limit(limit);
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
