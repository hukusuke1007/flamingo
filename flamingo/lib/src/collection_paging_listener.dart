import 'dart:async';

import 'package:flamingo/flamingo.dart';
import 'package:rxdart/rxdart.dart';

class DocumentChangeData<T extends Document<T>> {
  DocumentChangeData({
    required this.doc,
    required this.docChange,
  });
  final T doc;
  final DocumentChange docChange;
}

/// CollectionPagingListener is SnapshotListener + Paging features.
class CollectionPagingListener<T extends Document<T>> {
  CollectionPagingListener({
    required this.query,
    this.initialLimit,
    this.pagingLimit,
    required this.decode,
  })  : _limit = initialLimit,
        _pagingListenerController =
            _PagingListener(query: query, limit: initialLimit, decode: decode);

  final Query<Map<String, dynamic>> query;
  final int? initialLimit;
  final int? pagingLimit;
  final T Function(DocumentSnapshot<Map<String, dynamic>>) decode;

  ValueStream<List<T>> get data => _dataController.stream;
  Stream<List<DocumentChangeData<T>>> get docChanges =>
      _docChangesController.stream;
  int get count => _dataController.value.length;
  bool get hasMore => _hasMore;

  final _PagingListener<T> _pagingListenerController;
  final BehaviorSubject<List<T>> _dataController =
      BehaviorSubject<List<T>>.seeded([]);
  final PublishSubject<List<DocumentChangeData<T>>> _docChangesController =
      PublishSubject<List<DocumentChangeData<T>>>();

  StreamSubscription<List<T>>? _disposer;

  bool _hasMore = true;
  bool _initLoaded = false;
  int? _limit;

  /// To dispose SnapshotListener.
  Future<void> dispose() async {
    await _pagingListenerController.dispose();
    await _dataController.close();
    await _docChangesController.close();
    await _disposer?.cancel();
  }

  /// Listen to snapshot from SnapshotListener.
  void fetch() {
    assert(_initLoaded == false);
    _disposer = _pagingListenerController.data.listen((event) {
      if (_limit != null) {
        _hasMore = event.length >= _limit!;
      } else {
        _hasMore = false;
      }
      _dataController.add(event);
    });

    _pagingListenerController.docChanges
        .where((event) => event.isNotEmpty)
        .pipe(_docChangesController);
    _pagingListenerController.onLoad.add(_limit);
    _initLoaded = true;
  }

  /// To load next page data using SnapshotListener.
  void loadMore() {
    if (_hasMore && _limit != null && pagingLimit != null) {
      _limit = _limit! + pagingLimit!;
      _pagingListenerController.onLoad.add(_limit);
    }
  }
}

class _PagingListener<T extends Document<T>> {
  _PagingListener({
    required this.query,
    this.limit,
    required this.decode,
    this.collectionReference,
  }) {
    _loadController.switchMap<int>(Stream.value).listen(_fetch);
  }

  final Query<Map<String, dynamic>> query;
  final int? limit;
  final T Function(DocumentSnapshot<Map<String, dynamic>>) decode;
  final CollectionReference? collectionReference;

  ValueStream<List<T>> get data => _dataController.stream;
  Stream<List<DocumentChangeData<T>>> get docChanges =>
      _docChangesController.stream;
  Sink<int?> get onLoad => _loadController.sink;

  final BehaviorSubject<List<T>> _dataController =
      BehaviorSubject<List<T>>.seeded([]);
  final PublishSubject<List<DocumentChangeData<T>>> _docChangesController =
      PublishSubject<List<DocumentChangeData<T>>>();
  final PublishSubject<int> _loadController = PublishSubject<int>();

  StreamSubscription<QuerySnapshot>? _disposer;

  Future<void> dispose() async {
    await _disposer?.cancel();
    await _dataController.close();
    await _docChangesController.close();
    await _loadController.close();
  }

  Future<void> _fetch(int? limit) async {
    if (_disposer != null) {
      await _disposer?.cancel();
      _disposer = null;
      _dataController.value.clear();
    }
    var dataSource = query;
    if (limit != null) {
      dataSource = dataSource.limit(limit);
    }
    _disposer = dataSource.snapshots().listen((event) {
      final docs = _dataController.value;
      final changes = <DocumentChangeData<T>>[];
      for (final change in event.docChanges) {
        final doc = decode(change.doc);
        if (change.type == DocumentChangeType.added) {
          docs.insert(change.newIndex, doc);
        } else if (change.type == DocumentChangeType.modified) {
          if (change.oldIndex == change.newIndex) {
            docs[change.newIndex] = doc;
          } else {
            docs
              ..removeAt(change.oldIndex)
              ..insert(change.newIndex, doc);
          }
        } else if (change.type == DocumentChangeType.removed) {
          docs.removeAt(change.oldIndex);
        }
        changes.add(DocumentChangeData<T>(doc: doc, docChange: change));
      }
      _dataController.add(docs);
      _docChangesController.add(changes);
    });
  }
}
