// import 'dart:async';
//
// import 'package:flamingo/flamingo.dart';
// import 'package:flutter/foundation.dart';
// import 'package:rxdart/rxdart.dart';
//
// /// [多分使えるけど推奨しない]
//
// /// OperationType for Snapshot.
// enum OperationType {
//   refresh,
//   paging,
//   listen,
//   deleteWithOutOfScope,
//   clear,
// }
//
// /// Snapshot for CollectionPagingListener.
// class PagingSnapshot {
//   PagingSnapshot({
//     this.querySnapshot,
//     this.documentSnapshot,
//     @required this.type,
//   }) : assert(querySnapshot == null || documentSnapshot == null,
//             'Can be used only either of \'querySnapshot\' or \'documentSnapshot\'.');
//   final QuerySnapshot querySnapshot;
//   final DocumentSnapshot documentSnapshot;
//   final OperationType type;
// }
//
// /// CollectionPagingListener is SnapshotListener + Paging features.
// /// To paging using startAfterDocument.
// ///
// /// [Note] If delete document of limit out of scope, use "deleteDoc" in CollectionPagingListener.
// /// Because of not transferred snapshot from SnapshotListener if delete to document of limit out of scope.
// class CollectionPagingListener<T extends Document<T>> {
//   CollectionPagingListener({
//     @required this.query,
//     this.collectionReference,
//     @required this.limit,
//     @required this.decode,
//   })  : assert(limit >= 1, 'You must set limit. value >= 1.'),
//         initialLimit = limit,
//         pagingLimit = limit {
//     _configure();
//   }
//
//   final Query query;
//   final CollectionReference collectionReference;
//   final int limit;
//   final int initialLimit;
//   final int pagingLimit;
//   final T Function(DocumentSnapshot, CollectionReference) decode;
//
//   ValueStream<PagingSnapshot> get snapshot => _snapshotController.stream;
//   Sink<PagingSnapshot> get onSnapshot => _snapshotController.sink;
//   ValueStream<List<T>> get data => _dataController.stream;
//   int get count => _dataController.value.length;
//   bool get hasMore => _hasMore;
//   bool get isFetched => _disposer != null || false;
//
//   final _documentAccessor = DocumentAccessor();
//
//   bool _initLoaded = false;
//   bool _hasMore = true;
//   final BehaviorSubject<List<T>> _dataController =
//       BehaviorSubject<List<T>>.seeded([]);
//   final BehaviorSubject<PagingSnapshot> _snapshotController =
//       BehaviorSubject<PagingSnapshot>.seeded(null);
//   DocumentSnapshot _startAfterDocument;
//   StreamSubscription<QuerySnapshot> _disposer;
//
//   /// To dispose SnapshotListener.
//   Future<void> dispose() async {
//     await _disposer?.cancel();
//     await _snapshotController.close();
//     await _dataController.close();
//   }
//
//   /// If you want to re-fetch, fetch after call detach() func
//   Future<void> detach() async {
//     await _disposer?.cancel();
//     _disposer = null;
//     _snapshotController.add(PagingSnapshot(type: OperationType.clear));
//     _initLoaded = false;
//     _startAfterDocument = null;
//   }
//
//   /// Listen to snapshot from SnapshotListener.
//   void fetch() {
//     assert(!isFetched,
//         'Already fetched. If you want to re-fetch, fetch after call detach() func ');
//     _disposer ??= query.limit(initialLimit).snapshots().listen((event) =>
//         _snapshotController.add(
//             PagingSnapshot(querySnapshot: event, type: OperationType.listen)));
//   }
//
//   /// To clear and reload documents from get API.
//   Future<void> refresh({
//     Source source = Source.serverAndCache,
//   }) async {
//     final snapshot = await _load(limit: initialLimit, source: source);
//     _snapshotController.add(
//         PagingSnapshot(querySnapshot: snapshot, type: OperationType.refresh));
//   }
//
//   /// To load next page data using startAfterDocument from get API.
//   Future<void> loadMore({
//     Source source = Source.serverAndCache,
//   }) async {
//     if (_startAfterDocument == null) {
//       return;
//     }
//     final snapshot = await _load(
//         limit: pagingLimit,
//         source: source,
//         startAfterDocument: _startAfterDocument);
//     _snapshotController.add(
//         PagingSnapshot(querySnapshot: snapshot, type: OperationType.paging));
//   }
//
//   /// If delete document of limit out of scope, use this.
//   Future<void> deleteDoc(T document) async {
//     final docs = _dataController.value.toList();
//     if (docs.isEmpty) {
//       return;
//     }
//     final index = docs.indexWhere((element) => element.id == document.id);
//     // 監視範囲外のドキュメントは削除リスナーが動かないためキャッシュを削除する
//     if (initialLimit < index + 1) {
//       final doc = docs.firstWhere((element) => element.id == document.id,
//           orElse: () => null);
//       if (doc != null) {
//         _snapshotController.add(PagingSnapshot(
//             documentSnapshot: doc.snapshot,
//             type: OperationType.deleteWithOutOfScope));
//       }
//     }
//     await _documentAccessor.delete(document);
//   }
//
//   Future<QuerySnapshot> _load({
//     int limit = 20,
//     Source source = Source.serverAndCache,
//     DocumentSnapshot startAfterDocument,
//   }) async {
//     var dataSource = query.limit(limit);
//     if (startAfterDocument != null) {
//       dataSource = dataSource.startAfterDocument(startAfterDocument);
//     }
//     final result = await dataSource.get(GetOptions(source: source));
//     final documents = result.docs.toList();
//
//     if (documents.isNotEmpty) {
//       _startAfterDocument = result.docs.toList().last;
//       _hasMore = true;
//     } else {
//       _hasMore = false;
//     }
//     return result;
//   }
//
//   void _configure() {
//     _snapshotController
//         .where((event) => event != null)
//         .asyncExpand<List<T>>((event) {
//       final querySnapshot = event.querySnapshot;
//       final docs = _dataController.value;
// //      print('eventType: ${event.type}');
//       if (event.type == OperationType.listen) {
//         // print('docChanges ${querySnapshot.docChanges.length}');
//         for (var change in querySnapshot.docChanges) {
// //          print(
// //              'id: ${change.doc.id}, changeType: ${change.type}, oldIndex: ${change.oldIndex}, newIndex: ${change.newIndex} cache: ${change.doc.metadata.isFromCache}');
//           final data = decode(change.doc, collectionReference);
//           if (change.type == DocumentChangeType.added) {
//             if (_initLoaded) {
//               // 範囲外での更新の場合は古いものは削除する
//               final index =
//                   docs.indexWhere((element) => element.id == change.doc.id);
//               if (index != -1) {
//                 docs.removeAt(index);
//               }
//             }
//             docs.insert(change.newIndex, data);
//             if (initialLimit >= docs.length) {
//               _startAfterDocument = querySnapshot.docs.last;
//             }
//           } else if (change.type == DocumentChangeType.modified) {
//             docs
//               ..removeAt(change.oldIndex)
//               ..insert(
//                   change.newIndex, decode(change.doc, collectionReference));
//           } else if (change.type == DocumentChangeType.removed) {
//             // 範囲内での削除をするため
//             // 新規追加や範囲外での更新をすると範囲内で保持しているものも削除対象になるため
//             // addedのドキュメントのnewIndexが0以外の場合は削除操作のため削除実施する
//             final addedDoc = querySnapshot.docChanges.firstWhere(
//                 (element) => element.type == DocumentChangeType.added,
//                 orElse: () => null);
//             if (addedDoc != null && addedDoc.newIndex != 0) {
//               docs.removeAt(change.oldIndex);
//             } else if (change.oldIndex == addedDoc.newIndex) {
//               docs.removeAt(change.oldIndex);
//             }
//           }
//         }
//         if (!_initLoaded) {
//           _initLoaded = true;
//         }
//       } else if (event.type == OperationType.refresh) {
//         docs
//           ..clear()
//           ..addAll(
//               querySnapshot.docs.map((e) => decode(e, collectionReference)));
//       } else if (event.type == OperationType.paging) {
//         if (querySnapshot.docs.isNotEmpty) {
//           docs.addAll(
//               querySnapshot.docs.map((e) => decode(e, collectionReference)));
//         }
//       } else if (event.type == OperationType.deleteWithOutOfScope) {
//         docs.removeWhere((element) => element.id == event.documentSnapshot.id);
//       } else if (event.type == OperationType.clear) {
//         docs.clear();
//       }
//       return Stream.value(docs);
//     }).pipe(_dataController);
//   }
// }
