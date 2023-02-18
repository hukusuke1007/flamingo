// import 'dart:async';
//
// import 'package:flamingo/flamingo.dart';
// import 'package:flutter/foundation.dart';
// import 'package:rxdart/rxdart.dart';
//
// /// やりたいことができなかった
//
// /// CollectionPagingListener is SnapshotListener + Paging features.
// class CollectionPagingListener<T extends Document<T>> {
//   CollectionPagingListener({
//     @required this.query,
//     this.collectionReference,
//     @required this.limit,
//     @required this.decode,
//   }) : assert(limit >= 1, 'You must set limit. value >= 1.');
//
//   final Query query;
//   final CollectionReference collectionReference;
//   final int limit;
//   final T Function(DocumentSnapshot, CollectionReference) decode;
//
//   ValueStream<List<T>> get data => _dataController.stream;
//   int get count => _dataController.value.length;
//   bool get hasMore => _hasMore;
//
//   final BehaviorSubject<List<_PagingListener<T>>> _pagingListenerController =
//       BehaviorSubject<List<_PagingListener<T>>>.seeded([]);
//
//   final BehaviorSubject<List<T>> _dataController =
//       BehaviorSubject<List<T>>.seeded([]);
//
//   int _page = 0;
//   bool _hasMore = true;
//   bool _initLoaded = false;
//   DocumentSnapshot _startAfterDocument;
//
//   /// To dispose SnapshotListener.
//   Future<void> dispose() async {
//     if (_pagingListenerController.value != null) {
//       for (var item in _pagingListenerController.value) {
//         await item.dispose();
//       }
//     }
//     await _pagingListenerController.close();
//     await _dataController.close();
//   }
//
//   /// Listen to snapshot from SnapshotListener.
//   void fetch() async {
//     assert(_initLoaded == false);
//     final pagingListener = _PagingListener(
//       query: query,
//       limit: limit,
//       decode: decode,
//       collectionReference: collectionReference,
//     );
//     _pagingListenerController.add([pagingListener]);
//     _fetch(_page);
//     _initLoaded = true;
//   }
//
//   /// To load next page data using SnapshotListener.
//   Future<void> loadMore() async {
//     print('_hasMore $_hasMore');
//     if (_hasMore) {
//       final pagingListener = _PagingListener(
//         query: query,
//         limit: limit,
//         decode: decode,
//         collectionReference: collectionReference,
//         startAfterDocument: _startAfterDocument,
//       );
//       final first =
//           await pagingListener.data.where((event) => event != null).first;
//       print('first ${first.length}');
//
//       if (first.length >= limit) {
//         _hasMore = true;
//       } else {
//         _hasMore = false;
//       }
//       _page += 1;
//       _pagingListenerController.value = _pagingListenerController.value
//         ..add(pagingListener);
//       _fetch(_page);
//     }
//   }
//
//   void _fetch(int page) {
//     final pagingListener = _pagingListenerController.value[page];
//     pagingListener.data.where((event) => event != null).listen((_) {
//       print(
//           'fetch startAfter ${_startAfterDocument?.id} _hasMore: $_hasMore, page: $page, _page: $_page');
//       final data =
//           _pagingListenerController.value.expand((e) => e.data.value).toList();
//       _startAfterDocument = data.last.snapshot;
//       _dataController.add(data);
//     });
//   }
// }
//
// class _PagingListener<T extends Document<T>> {
//   _PagingListener({
//     @required this.query,
//     @required this.limit,
//     @required this.decode,
//     this.collectionReference,
//     this.startAfterDocument,
//   }) : assert(limit >= 1, 'You must set limit. value >= 1.') {
//     _fetch();
//   }
//
//   final Query query;
//   final int limit;
//   final T Function(DocumentSnapshot, CollectionReference) decode;
//   final CollectionReference collectionReference;
//   final DocumentSnapshot startAfterDocument;
//
//   ValueStream<List<T>> get data => _dataController.stream;
//   final BehaviorSubject<List<T>> _dataController =
//       BehaviorSubject<List<T>>.seeded(null);
//
//   StreamSubscription<QuerySnapshot> _disposer;
//
//   Future<Stream<QuerySnapshot>> get _snapshots async {
//     var _query = query.limit(limit);
//     if (startAfterDocument != null) {
//       _query = _query.startAfterDocument(startAfterDocument);
//     }
//     final qs = await _query.snapshots().first;
//     return _query.endAtDocument(qs.docs.last).snapshots();
//   }
//
//   Future<void> dispose() async {
//     await _disposer?.cancel();
//     await _dataController.close();
//   }
//
//   void _fetch() async {
//     _disposer ??= (await _snapshots).listen((event) {
//       final docs =
//           _dataController.value != null ? _dataController.value : <T>[];
//       for (var change in event.docChanges) {
//         print(
//             'id: ${change.doc.id}, changeType: ${change.type}, oldIndex: ${change.oldIndex}, newIndex: ${change.newIndex} cache: ${change.doc.metadata.isFromCache}');
//
//         if (change.type == DocumentChangeType.added) {
//           docs.insert(change.newIndex, decode(change.doc, collectionReference));
//         } else if (change.type == DocumentChangeType.modified) {
//           final doc = decode(change.doc, collectionReference);
//           if (change.oldIndex == change.newIndex) {
//             docs[change.newIndex] = doc;
//           } else {
//             docs
//               ..removeAt(change.oldIndex)
//               ..insert(change.newIndex, doc);
//           }
//         } else if (change.type == DocumentChangeType.removed) {
//           docs.removeAt(change.oldIndex);
//         }
//       }
//       _dataController.add(docs);
//     });
//   }
// }
