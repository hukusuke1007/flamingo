import 'dart:async';

import '../flamingo.dart';

abstract class DocumentAccessorRepository {
  Future<void> save<T extends Document<T>>(Document<T> document);
  Future<Increment<T>> increment<T extends num>(
    Increment<T> entity,
    DocumentReference reference, {
    num value,
    required String fieldName,
  });
  Future<void> update<T extends Document<T>>(Document<T> document);
  Future<void> delete<T extends Document<T>>(Document<T> document);
  Future<T?> load<T extends Document<T>>(
    Document<T> document, {
    Source source = Source.serverAndCache,
    void Function(T?)? fromCache,
  });
  Future<T?> loadCache<T extends Document<T>>(Document<T> document);
  Future<T?> loadCacheOnly<T extends Document<T>>(Document<T> document);
  Future<void> saveRaw(
    Map<String, dynamic> values,
    DocumentReference reference, {
    bool isTimestamp = false,
    String createdFieldValueKey = documentCreatedAtKey,
    String updatedFieldValueKey = documentUpdatedAtKey,
  });
  Future<void> updateRaw(
    Map<String, dynamic> values,
    DocumentReference reference, {
    bool isTimestamp = false,
    String updatedFieldValueKey = documentUpdatedAtKey,
  });
  Future<void> deleteWithReference(DocumentReference reference);
}

class DocumentAccessor implements DocumentAccessorRepository {
  @override
  Future<void> save<T extends Document<T>>(Document<T> document) async {
    final batch = Batch()..save(document);
    await batch.commit();
  }

  @override
  Future<Increment<T>> increment<T extends num>(
    Increment<T> entity,
    DocumentReference reference, {
    num value = 1,
    required String fieldName,
    bool? isClear,
  }) async {
    var updateValue = value;
    if (isClear != null && isClear) {
      updateValue = (T.toString() == 'double') ? 0.0 as T : 0 as T;
    }
    final batch = Batch()
      ..updateRaw(
        entity.toData(updateValue, fieldName: fieldName, isClear: isClear),
        reference,
        isTimestamp: true,
      );
    await batch.commit();
    return Increment(value: updateValue as T);
  }

  @override
  Future<void> update<T extends Document<T>>(Document<T> document) async {
    final batch = Batch()..update(document);
    await batch.commit();
  }

  @override
  Future<void> delete<T extends Document<T>>(Document<T> document) async {
    final batch = Batch()..delete(document);
    await batch.commit();
  }

  @override
  Future<T?> load<T extends Document<T>>(
    Document<T> document, {
    Source source = Source.serverAndCache,
    void Function(T?)? fromCache,
  }) async {
    if (fromCache != null) {
      try {
        final cache = await _load(document, Source.cache);
        fromCache(cache != null ? cache as T : null);
      } on Exception catch (_) {
        fromCache(null);
      }
    }
    final document0 = await _load(document, source);
    return document0 != null ? document0 as T : null;
  }

  @override
  Future<T?> loadCache<T extends Document<T>>(Document<T> document) async {
    try {
      final cache = await _load<T>(document, Source.cache);
      if (cache != null) {
        return cache as T;
      }
    } on Exception catch (_) {
      // nothing
    }
    final document0 = await _load<T>(document, Source.serverAndCache);
    return document0 != null ? document0 as T : null;
  }

  @override
  Future<T?> loadCacheOnly<T extends Document<T>>(Document<T> document) async {
    try {
      final cache = await _load<T>(document, Source.cache);
      if (cache != null) {
        return cache as T;
      }
    } on Exception catch (_) {
      // nothing
    }
    return null;
  }

  Future<Document<T>?> _load<T extends Document<T>>(
    Document<T> document,
    Source source,
  ) async {
    final documentSnapshot =
        await document.reference.get(GetOptions(source: source));
    if (documentSnapshot.exists) {
      document.setSnapshot(documentSnapshot);
      return document;
    }
    return null;
  }

  @override
  Future<void> saveRaw(
    Map<String, dynamic> values,
    DocumentReference reference, {
    bool isTimestamp = false,
    String createdFieldValueKey = documentCreatedAtKey,
    String updatedFieldValueKey = documentUpdatedAtKey,
  }) async {
    final data = values;
    final nowAt = Timestamp.now();
    if (isTimestamp) {
      data[createdFieldValueKey] = nowAt;
      data[updatedFieldValueKey] = nowAt;
    }
    final batch = Batch()..saveRaw(values, reference);
    await batch.commit();
  }

  @override
  Future<void> updateRaw(
    Map<String, dynamic> values,
    DocumentReference reference, {
    bool isTimestamp = false,
    String updatedFieldValueKey = documentUpdatedAtKey,
  }) async {
    final data = values;
    final nowAt = Timestamp.now();
    if (isTimestamp) {
      data[updatedFieldValueKey] = nowAt;
    }
    final batch = Batch()..updateRaw(values, reference);
    await batch.commit();
  }

  @override
  Future<void> deleteWithReference(DocumentReference reference) async {
    final batch = Batch()..deleteWithReference(reference);
    await batch.commit();
  }
}
