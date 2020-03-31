import 'package:cloud_firestore/cloud_firestore.dart';
import 'flamingo.dart';
import 'model/model.dart';

class Base {
  void write(Map<String, dynamic> data, String key, dynamic value) {
    data[key] = value;
  }

  void writeIncrement(Map<String, dynamic> data, Increment entity) {
    if (entity.isClearValue) {
      data[entity.fieldName] = entity.value.runtimeType == double ? 0.0 : 0;
    } else {
      if (entity.incrementValue != null) {
        data[entity.fieldName] = FieldValue.increment(entity.incrementValue);
      }
    }
  }

  void writeModel(Map<String, dynamic> data, String key, Model model) {
    data[key] = model.toData();
  }

  void writeModelList(
      Map<String, dynamic> data, String key, List<Model> models) {
    if (models != null) {
      _writeModelList(data, key, models);
    } else {
      data[key] = null;
    }
  }

  void writeNotNull(Map<String, dynamic> data, String key, dynamic value) {
    if (value != null) {
      data[key] = value;
    }
  }

  void writeModelNotNull(Map<String, dynamic> data, String key, Model model) {
    if (model != null) {
      data[key] = model.toData();
    }
  }

  void writeModelListNotNull(
      Map<String, dynamic> data, String key, List<Model> models) {
    if (models != null) {
      _writeModelList(data, key, models);
    }
  }

  void _writeModelList(
      Map<String, dynamic> data, String key, List<Model> models) {
    data[key] = models.map((d) => d.toData()).toList();
  }

  void writeStorage(Map<String, dynamic> data, String key, StorageFile storageFile, {
    bool isSetNull = true,
  }) => _writeStorage(data, key, storageFile,
        isNullIgnore: false,
        isSetNull: isSetNull,
      );

  void writeStorageNotNull(Map<String, dynamic> data, String key, StorageFile storageFile, {
    bool isSetNull = false,
  }) => _writeStorage(data, key, storageFile,
        isNullIgnore: true,
        isSetNull: isSetNull,
      );

  void writeStorageList(Map<String, dynamic> data, String key, List<StorageFile> storageFiles, {
    bool isSetNull = true,
  }) => _writeStorageList(data, key, storageFiles,
        isNullIgnore: false,
        isSetNull: isSetNull,
      );

  void writeStorageListNotNull(Map<String, dynamic> data, String key, List<StorageFile> storageFiles, {
    bool isSetNull = true,
  }) => _writeStorageList(data, key, storageFiles,
        isNullIgnore: true,
        isSetNull: isSetNull,
      );

  void _writeStorage(
      Map<String, dynamic> data, String key, StorageFile storageFile, {
        bool isNullIgnore,
        bool isSetNull,
      }) {
    if (storageFile != null) {
      if (!storageFile.isDeleted) {
        data[key] = storageFile.toJson();
      } else {
        data[key] = isSetNull ? null : FieldValue.delete();
      }
    } else {
      if (!isNullIgnore) {
        data[key] = isSetNull ? null : FieldValue.delete();
      }
    }
  }

  void _writeStorageList(
      Map<String, dynamic> data, String key, List<StorageFile> storageFiles, {
        bool isNullIgnore,
        bool isSetNull,
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
      if (!isNullIgnore) {
        data[key] = isSetNull ? null : FieldValue.delete();
      }
    }
  }

  StorageFile storageFile(Map<String, dynamic> data, String folderName) {
    final fileMap = valueMapFromKey<String, dynamic>(data, folderName);
    if (fileMap != null) {
      return StorageFile.fromJson(fileMap);
    } else {
      return null;
    }
  }

  List<StorageFile> storageFiles(Map<String, dynamic> data, String folderName) {
    final fileMapList = valueMapListFromKey<String, dynamic>(data, folderName);
    if (fileMapList != null) {
      return fileMapList.map((d) => StorageFile.fromJson(d)).toList();
    } else {
      return null;
    }
  }

  U valueFromKey<U>(Map<String, dynamic> data, String key) {
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
    return value as U;
  }

  Map<U, V> valueMapFromKey<U, V>(Map<String, dynamic> data, String key) =>
      isVal(data, key) && data[key] != null
          ? Map<U, V>.from(Helper.fromMap(data[key] as Map))
          : null;

  List<U> valueListFromKey<U>(Map<String, dynamic> data, String key) =>
      data[key] != null
          ? (data[key] as List)?.map((dynamic e) => e as U)?.toList()
          : null;

  List<Map<U, V>> valueMapListFromKey<U, V>(
          Map<String, dynamic> data, String key) =>
      isVal(data, key) && data[key] != null
          ? (data[key] as List)
              .map((dynamic d) => Map<U, V>.from(d as Map))
              .toList()
          : null;

  Increment<U> valueFromIncrement<U extends num>(Map<String, dynamic> data, String key) => Increment(key, value: data[key] as U);

  bool isVal(Map<String, dynamic> data, String key) => data.containsKey(key);

  Timestamp timestampFromMap(dynamic data, String key) {
    if (data != null && data[key] is Map) {
      final rawTimestamp = Map<String, dynamic>.from(Helper.fromMap(data[key] as Map));
      final second = rawTimestamp['_seconds'] as int;
      final nanoseconds = rawTimestamp['_nanoseconds'] as int;
      return Timestamp(second, nanoseconds);
    }
    return null;
  }

}
