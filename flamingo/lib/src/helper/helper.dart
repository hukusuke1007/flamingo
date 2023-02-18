import 'dart:math';

import '../../flamingo.dart';

class Helper {
  const Helper._();
  static Map<String, dynamic> fromMap(Map<String, dynamic> map) =>
      Map<String, dynamic>.from(map);

  static String randomString({int? length}) {
    const randomChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const charsLength = randomChars.length;
    final rand = Random();
    final codeUnits = List.generate(
      length ?? 10,
      (index) {
        final n = rand.nextInt(charsLength);
        return randomChars.codeUnitAt(n);
      },
    );
    return String.fromCharCodes(codeUnits);
  }

  static void write(Map<String, dynamic> data, String key, dynamic value) {
    data[key] = value;
  }

  static void writeIncrement(
    Map<String, dynamic> data,
    Increment entity,
    String fieldName,
  ) {
    if (entity.isClearValue) {
      data[fieldName] = entity.value.runtimeType == double ? 0.0 : 0;
    } else {
      if (entity.incrementValue != null) {
        data[fieldName] = FieldValue.increment(entity.incrementValue!);
      }
    }
  }

  static void writeModel(Map<String, dynamic> data, String key, Model model) {
    data[key] = model.toData();
  }

  static void writeModelList(
    Map<String, dynamic> data,
    String key,
    List<Model> models,
  ) {
    _writeModelList(data, key, models);
  }

  static void writeNotNull(
    Map<String, dynamic> data,
    String key,
    dynamic value,
  ) {
    if (value != null) {
      data[key] = value;
    }
  }

  static void writeModelNotNull(
    Map<String, dynamic> data,
    String key,
    Model? model,
  ) {
    if (model != null) {
      data[key] = model.toData();
    }
  }

  static void writeModelListNotNull(
    Map<String, dynamic> data,
    String key,
    List<Model>? models,
  ) {
    if (models != null) {
      _writeModelList(data, key, models);
    }
  }

  static void _writeModelList(
    Map<String, dynamic> data,
    String key,
    List<Model> models,
  ) {
    data[key] = models.map((d) => d.toData()).toList();
  }

  static void writeStorage(
    Map<String, dynamic> data,
    String key,
    StorageFile? storageFile, {
    bool isSetNull = true,
  }) =>
      _writeStorage(
        data,
        key,
        storageFile,
        isNullIgnore: false,
        isSetNull: isSetNull,
      );

  static void writeStorageNotNull(
    Map<String, dynamic> data,
    String key,
    StorageFile? storageFile, {
    bool isSetNull = false,
  }) =>
      _writeStorage(
        data,
        key,
        storageFile,
        isNullIgnore: true,
        isSetNull: isSetNull,
      );

  static void writeStorageList(
    Map<String, dynamic> data,
    String key,
    List<StorageFile>? storageFiles, {
    bool isSetNull = true,
  }) =>
      _writeStorageList(
        data,
        key,
        storageFiles,
        isNullIgnore: false,
        isSetNull: isSetNull,
      );

  static void writeStorageListNotNull(
    Map<String, dynamic> data,
    String key,
    List<StorageFile>? storageFiles, {
    bool isSetNull = true,
  }) =>
      _writeStorageList(
        data,
        key,
        storageFiles,
        isNullIgnore: true,
        isSetNull: isSetNull,
      );

  static void _writeStorage(
    Map<String, dynamic> data,
    String key,
    StorageFile? storageFile, {
    bool? isNullIgnore,
    bool? isSetNull,
  }) {
    if (storageFile != null) {
      if (!storageFile.isDeleted) {
        data[key] = storageFile.toJson();
      } else {
        data[key] =
            (isSetNull != null && isSetNull) ? null : FieldValue.delete();
      }
    } else {
      if (isNullIgnore != null && !isNullIgnore) {
        data[key] =
            (isSetNull != null && isSetNull) ? null : FieldValue.delete();
      }
    }
  }

  static void _writeStorageList(
    Map<String, dynamic> data,
    String key,
    List<StorageFile>? storageFiles, {
    bool? isNullIgnore,
    bool? isSetNull,
  }) {
    if (storageFiles != null) {
      if (storageFiles.isNotEmpty) {
        data[key] = storageFiles
            .where((d) => d.isDeleted != true)
            .map((d) => d.toJson())
            .toList();
      } else {
        data[key] = storageFiles;
      }
    } else {
      if (isNullIgnore != null && !isNullIgnore) {
        data[key] =
            (isSetNull != null && isSetNull) ? null : FieldValue.delete();
      }
    }
  }

  static StorageFile? storageFile(
    Map<String, dynamic> data,
    String folderName,
  ) {
    final fileMap = valueMapFromKey<String, dynamic>(data, folderName);
    if (fileMap != null) {
      return StorageFile.fromJson(fileMap);
    } else {
      return null;
    }
  }

  static List<StorageFile>? storageFiles(
    Map<String, dynamic> data,
    String folderName,
  ) {
    final fileMapList = valueMapListFromKey<String, dynamic>(data, folderName);
    if (fileMapList != null) {
      return fileMapList.map(StorageFile.fromJson).toList();
    } else {
      return null;
    }
  }

  static U valueFromKey<U>(
    Map<String, dynamic> data,
    String key, {
    required U defaultValue,
  }) {
    final dynamic value = data[key];
    if (U.toString() == 'int') {
      if (value is double) {
        return value.toInt() as U;
      }
    } else if (U.toString() == 'double') {
      if (value is int) {
        return value.toDouble() as U;
      }
    }
    if (value == null) {
      return defaultValue;
    }
    return value as U;
  }

  static Map<U, V>? valueMapFromKey<U, V>(
    Map<String, dynamic> data,
    String key,
  ) =>
      isVal(data, key) && data[key] != null
          ? Map<U, V>.from(Helper.fromMap(data[key] as Map<String, dynamic>))
          : null;

  static List<U>? valueListFromKey<U>(Map<String, dynamic> data, String key) =>
      data[key] != null
          ? (data[key] as List).map((dynamic e) => e as U).toList()
          : null;

  static List<Map<U, V>>? valueMapListFromKey<U, V>(
    Map<String, dynamic> data,
    String key,
  ) =>
      isVal(data, key) && data[key] != null
          ? (data[key] as List)
              .map((dynamic d) => Map<U, V>.from(d as Map))
              .toList()
          : null;

  static Increment<U> valueFromIncrement<U extends num>(
    Map<String, dynamic> data,
    String key,
  ) =>
      Increment(value: data[key] as U?);

  static bool isVal(Map<String, dynamic> data, String key) =>
      data.containsKey(key);

  static Timestamp? timestampFromMap(dynamic data, String key) {
    // ignore: avoid_dynamic_calls
    if (data != null && data[key] is Map) {
      final rawTimestamp = Map<String, dynamic>.from(
        Helper.fromMap(
          // ignore: avoid_dynamic_calls
          data[key] as Map<String, dynamic>,
        ),
      );
      final second = rawTimestamp['_seconds'] as int;
      final nanoseconds = rawTimestamp['_nanoseconds'] as int;
      return Timestamp(second, nanoseconds);
    }
    return null;
  }
}
