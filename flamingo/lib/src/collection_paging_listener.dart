import 'dart:async';

import 'package:flamingo/flamingo.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

// TODO(shohei): リアルタイムアップデートのみのページング

class _PagingData<T extends Document<T>> {
  _PagingData({
    this.docs,
    this.startAfterDocument,
  });
  final List<T> docs;
  final DocumentSnapshot startAfterDocument;
}

/// CollectionPagingListener is SnapshotListener + Paging features.
class CollectionPagingListener<T extends Document<T>> {
  CollectionPagingListener({
    @required this.query,
    this.collectionReference,
    @required this.limit,
    @required this.decode,
  }) : assert(limit >= 1, 'You must set limit. value >= 1.');

  final Query query;
  final CollectionReference collectionReference;
  final int limit;
  final T Function(DocumentSnapshot, CollectionReference) decode;

  final BehaviorSubject<List<_PagingListener<T>>> _pagingListenerController =
      BehaviorSubject<List<_PagingListener<T>>>.seeded([]);

  ValueStream<List<T>> get data => _dataController.stream;
  int get count => _dataController.value.length;
  bool get hasMore => _hasMore;

  int _page = 0;
  bool _initLoaded = false;
  bool _hasMore = true;
  final BehaviorSubject<List<T>> _dataController =
      BehaviorSubject<List<T>>.seeded([]);
  DocumentSnapshot _startAfterDocument;

  /// To dispose SnapshotListener.
  Future<void> dispose() async {
    if (_pagingListenerController.value != null) {
      for (var item in _pagingListenerController.value) {
        await item.dispose();
      }
    }
    await _pagingListenerController.close();
    await _dataController.close();
  }

  /// Listen to snapshot from SnapshotListener.
  void fetch() {
    assert(_initLoaded == false);
    _pagingListenerController.add([
      _PagingListener(
        query: query,
        limit: limit,
        decode: decode,
        collectionReference: collectionReference,
      )
    ]);
    _fetch(_page);
    _initLoaded = true;
  }

  /// To load next page data using SnapshotListener.
  Future<void> loadMore({
    Source source = Source.serverAndCache,
  }) async {
    print('_hasMore $_hasMore');
    if (_hasMore) {
      _pagingListenerController.value.add(_PagingListener(
        query: query,
        limit: limit,
        decode: decode,
        collectionReference: collectionReference,
        startAfterDocument: _startAfterDocument,
      ));
      _pagingListenerController.add(_pagingListenerController.value);
      _page += 1;
      _fetch(_page);
    }
  }

  void _fetch(int page) {
    final pagingListener = _pagingListenerController.value[page];
    pagingListener.data.where((event) => event != null).map<List<T>>((event) {
      if (page == _page) {
        if (event.startAfterDocument != null) {
          _startAfterDocument = event.startAfterDocument;
        }
      }
      final last = _pagingListenerController.value.last;
      if (last.data.value.docs.length >= limit) {
        _hasMore = true;
      } else {
        _hasMore = false;
      }

      print(
          'fetch ${event.startAfterDocument} _hasMore: $_hasMore, page: $page, _page: $_page');
      return event.docs;
    }).listen((_) {
      final data = _pagingListenerController.value
          .expand((e) => e.data.value != null ? e.data.value.docs : <T>[])
          .toList();
      _dataController.add(data);
    });
  }
}

class _PagingListener<T extends Document<T>> {
  _PagingListener({
    @required this.query,
    @required this.limit,
    @required this.decode,
    this.collectionReference,
    this.startAfterDocument,
  }) : assert(limit >= 1, 'You must set limit. value >= 1.') {
    _fetch();
  }

  final Query query;
  final int limit;
  final T Function(DocumentSnapshot, CollectionReference) decode;
  final CollectionReference collectionReference;
  final DocumentSnapshot startAfterDocument;

  ValueStream<_PagingData<T>> get data => _dataController.stream;
  final BehaviorSubject<_PagingData<T>> _dataController =
      BehaviorSubject<_PagingData<T>>.seeded(null);

  StreamSubscription<QuerySnapshot> _disposer;

  Future<Stream<QuerySnapshot>> get _snapshots async {
    var _query = query.limit(limit);
    if (startAfterDocument != null) {
      _query = _query.startAfterDocument(startAfterDocument);
    }
    final qs = await _query.snapshots().first;
//    if (qs.docs.isNotEmpty) {
//      _query = _query.endAtDocument(qs.docs.last);
//    }
    return _query.endAtDocument(qs.docs.last).snapshots();
  }

  Future<void> dispose() async {
    await _disposer?.cancel();
    await _dataController.close();
  }

  void _fetch() async {
    _disposer ??= (await _snapshots).listen((event) {
      final docs =
          _dataController.value != null ? _dataController.value.docs : <T>[];

      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          docs.insert(change.newIndex, decode(change.doc, collectionReference));
        } else if (change.type == DocumentChangeType.modified) {
          docs
            ..removeAt(change.oldIndex)
            ..insert(change.newIndex, decode(change.doc, collectionReference));
        } else if (change.type == DocumentChangeType.removed) {
          docs.removeAt(change.oldIndex);
        }
      }
      _dataController.add(_PagingData(
        docs: docs,
        startAfterDocument: docs.isNotEmpty ? docs.last.snapshot : null,
      ));
    });
  }
}
