import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import 'model/document.dart';

enum LoadType {
  refresh,
  paging,
  listen,
}

class Snapshot {
  Snapshot({
    @required this.querySnapshot,
    @required this.type,
  });
  final QuerySnapshot querySnapshot;
  final LoadType type;
}

class CollectionPagingListener<T extends Document<T>> {
  CollectionPagingListener({
    @required this.query,
    this.collectionReference,
    @required this.limit,
    @required this.decode,
  })  : initialLimit = limit,
        pagingLimit = limit,
        assert(limit != null || limit >= 1, 'You must set limit. value >= 1.');

  final Query query;
  final CollectionReference collectionReference;
  final int limit;
  final int initialLimit;
  final int pagingLimit;
  final T Function(DocumentSnapshot, CollectionReference) decode;

  final _documentAccessor = DocumentAccessor();

  ValueStream<List<T>> get data => _dataController.stream;
  Sink<List<T>> get onData => _dataController.sink;
  ValueStream<Snapshot> get snapshot => _querySnapshotController.stream;
  int get count => _dataController.value.length;
  bool get hasMore => _hasMore;

  bool _initLoaded = false;
  bool _hasMore = true;
  final BehaviorSubject<List<T>> _dataController =
      BehaviorSubject<List<T>>.seeded([]);
  final BehaviorSubject<Snapshot> _querySnapshotController =
      BehaviorSubject<Snapshot>.seeded(null);
  DocumentSnapshot _startAfterDocument;
  StreamSubscription<QuerySnapshot> _disposer;

  Future<void> dispose() async {
    await _disposer?.cancel();
    await _querySnapshotController.close();
    await _dataController.close();
  }

  Future<void> detach() async {
    await _disposer?.cancel();
    _disposer = null;
    _querySnapshotController.add(null);
    _dataController.add([]);
  }

  void fetch() {
    assert(_disposer == null,
        'Already set disposer. If you want to re-fetch, fetch after call detach() func ');
    _querySnapshotController
        .where((event) => event != null)
        .asyncExpand<List<T>>((event) {
      final snapshot = event.querySnapshot;
      // TODO(shohei): delete log
      print(
          'querySnapshot type: ${event.type}, isNotEmpty: ${snapshot.docs.isNotEmpty} docChanges: ${snapshot.docChanges.length}');
      final docs = _dataController.value;
      if (event.type == LoadType.listen) {
        print('docChanges ${snapshot.docChanges.length}');
        for (var change in snapshot.docChanges) {
          print(
              'id: ${change.doc.id}, changeType: ${change.type}, oldIndex: ${change.oldIndex}, newIndex: ${change.newIndex} cache: ${change.doc.metadata.isFromCache}');
          final data = decode(change.doc, collectionReference);
          if (change.type == DocumentChangeType.added) {
            if (_initLoaded) {
              // 範囲外での更新の場合は古いものは削除する
              final index =
                  docs.indexWhere((element) => element.id == change.doc.id);
              if (index != -1) {
                docs.removeAt(index);
              }
            }
            docs.insert(change.newIndex, data);
            if (initialLimit >= docs.length) {
              _startAfterDocument = snapshot.docs.last;
            }
          } else if (change.type == DocumentChangeType.modified) {
            docs
              ..removeAt(change.oldIndex)
              ..insert(
                  change.newIndex, decode(change.doc, collectionReference));
          } else if (change.type == DocumentChangeType.removed) {
            // 範囲内での削除をするため
            // 新規追加や範囲外での更新をすると範囲内で保持しているものも削除対象になるため
            // addedのドキュメントのnewIndexが0以外の場合は削除操作のため削除実施する
            final addedDoc = snapshot.docChanges.firstWhere(
                (element) => element.type == DocumentChangeType.added,
                orElse: () => null);
            if (addedDoc != null && addedDoc.newIndex != 0) {
              docs.removeAt(change.oldIndex);
            } else if (change.oldIndex == addedDoc.newIndex) {
              docs.removeAt(change.oldIndex);
            }
          }
        }
        if (!_initLoaded) {
          _initLoaded = true;
        }
      } else if (event.type == LoadType.refresh) {
        docs
          ..clear()
          ..addAll(snapshot.docs.map((e) => decode(e, collectionReference)));
      } else if (event.type == LoadType.paging) {
        if (snapshot.docs.isNotEmpty) {
          docs.addAll(snapshot.docs.map((e) => decode(e, collectionReference)));
        }
      }
      return Stream.value(docs);
    }).listen(_dataController.add);

    _disposer ??= query.limit(initialLimit).snapshots().listen((event) =>
        _querySnapshotController
            .add(Snapshot(querySnapshot: event, type: LoadType.listen)));
  }

  Future<void> refresh({
    Source source = Source.serverAndCache,
  }) async {
    final snapshot = await _load(limit: initialLimit, source: source);
    _querySnapshotController
        .add(Snapshot(querySnapshot: snapshot, type: LoadType.refresh));
  }

  Future<void> loadMore({
    Source source = Source.serverAndCache,
  }) async {
    if (_startAfterDocument == null) {
      return;
    }
    final snapshot = await _load(
        limit: pagingLimit,
        source: source,
        startAfterDocument: _startAfterDocument);
    _querySnapshotController
        .add(Snapshot(querySnapshot: snapshot, type: LoadType.paging));
  }

  Future<void> deleteDoc(T document) async {
    final docs = _dataController.value.toList();
    if (docs.isEmpty) {
      return;
    }
    final index = docs.indexWhere((element) => element.id == document.id);
    // 監視範囲外のドキュメントは削除リスナーが動かないためキャッシュを削除する
    if (initialLimit < index + 1) {
      docs.removeWhere((element) => element.id == document.id);
      _dataController.add(docs);
    }
    await _documentAccessor.delete(document);
  }

  Future<QuerySnapshot> _load({
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
      _startAfterDocument = result.docs.toList().last;
      _hasMore = true;
    } else {
      _hasMore = false;
    }
    return result;
  }
}
