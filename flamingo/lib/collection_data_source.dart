import 'flamingo.dart';

abstract class CollectionRepository {
  Future<QuerySnapshot> loadDocuments(
    String path, {
    bool groupSearch = false,
    int limit = 20,
    String order,
    bool descending = true,
    List<Where> whereList,
    DocumentSnapshot startAfterDocument,
    DocumentSnapshot endBeforeDocument,
    Range start,
    Range end,
    Source source,
  });
}

class CollectionDataSource implements CollectionRepository {
  @override
  Future<QuerySnapshot> loadDocuments(
    String path, {
    bool groupSearch = false,
    int limit = 20,
    String order,
    bool descending = true,
    List<Where> whereList,
    Range start,
    Range end,
    DocumentSnapshot startAfterDocument,
    DocumentSnapshot endBeforeDocument,
    Source source = Source.serverAndCache,
  }) async {
    var dataSource = _collectionQuery(groupSearch, path, limit);
    if (order != null) {
      dataSource = dataSource.orderBy(order, descending: descending);
    }
    if (whereList != null) {
      for (var where in whereList) {
        dataSource = dataSource.where(
          where.field,
          isEqualTo: where.isEqualTo,
          isLessThan: where.isLessThan,
          isLessThanOrEqualTo: where.isLessThanOrEqualTo,
          isGreaterThan: where.isGreaterThan,
          isGreaterThanOrEqualTo: where.isGreaterThanOrEqualTo,
          arrayContainsAny: where.arrayContainsAny,
          arrayContains: where.arrayContains,
          whereIn: where.whereIn,
          isNull: where.isNull,
        );
      }
    }
    if (start != null) {
      if (start.isContains) {
        dataSource = dataSource.startAt(start.data);
      } else {
        dataSource = dataSource.startAfter(start.data);
      }
    }
    if (end != null) {
      if (end.isContains) {
        dataSource = dataSource.endAt(end.data);
      } else {
        dataSource = dataSource.endBefore(end.data);
      }
    }
    if (startAfterDocument != null && endBeforeDocument == null) {
      dataSource = dataSource.startAfterDocument(startAfterDocument);
    }
    if (startAfterDocument == null && endBeforeDocument != null) {
      dataSource = dataSource.endBeforeDocument(endBeforeDocument);
    }
    return dataSource.getDocuments(source: source);
  }

  Query _collectionQuery(bool groupSearch, String path, int limit) {
    if (groupSearch) {
      return firestoreInstance.collectionGroup(path).limit(limit);
    } else {
      return firestoreInstance.collection(path).limit(limit);
    }
  }
}

class Where {
  Where(
    this.field, {
    this.isEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.isNull,
  });
  dynamic field;
  dynamic isEqualTo;
  dynamic isLessThan;
  dynamic isLessThanOrEqualTo;
  dynamic isGreaterThan;
  dynamic isGreaterThanOrEqualTo;
  dynamic arrayContains;
  List<dynamic> arrayContainsAny;
  List<dynamic> whereIn;
  bool isNull;
}

class Range {
  Range({
    this.data,
    this.isContains = true,
  });
  List<dynamic> data;
  bool isContains;
}
