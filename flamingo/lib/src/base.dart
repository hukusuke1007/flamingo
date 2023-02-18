import '../flamingo.dart';

class Base {
  void write(Map<String, dynamic> data, String key, dynamic value) =>
      Helper.write(data, key, value);

  void writeIncrement(
    Map<String, dynamic> data,
    Increment entity,
    String fieldName,
  ) =>
      Helper.writeIncrement(data, entity, fieldName);

  void writeModel(Map<String, dynamic> data, String key, Model model) =>
      Helper.writeModel(data, key, model);

  void writeModelList(
    Map<String, dynamic> data,
    String key,
    List<Model> models,
  ) =>
      Helper.writeModelList(data, key, models);

  void writeNotNull(Map<String, dynamic> data, String key, dynamic value) =>
      Helper.writeNotNull(data, key, value);

  void writeModelNotNull(Map<String, dynamic> data, String key, Model model) =>
      Helper.writeModelNotNull(data, key, model);

  void writeModelListNotNull(
    Map<String, dynamic> data,
    String key,
    List<Model> models,
  ) =>
      Helper.writeModelListNotNull(data, key, models);

  void writeStorage(
    Map<String, dynamic> data,
    String key,
    StorageFile storageFile, {
    bool isSetNull = true,
  }) =>
      Helper.writeStorage(data, key, storageFile, isSetNull: isSetNull);

  void writeStorageNotNull(
    Map<String, dynamic> data,
    String key,
    StorageFile storageFile, {
    bool isSetNull = false,
  }) =>
      Helper.writeStorageNotNull(data, key, storageFile, isSetNull: isSetNull);

  void writeStorageList(
    Map<String, dynamic> data,
    String key,
    List<StorageFile> storageFiles, {
    bool isSetNull = true,
  }) =>
      Helper.writeStorageList(data, key, storageFiles, isSetNull: isSetNull);

  void writeStorageListNotNull(
    Map<String, dynamic> data,
    String key,
    List<StorageFile> storageFiles, {
    bool isSetNull = true,
  }) =>
      Helper.writeStorageListNotNull(
        data,
        key,
        storageFiles,
        isSetNull: isSetNull,
      );

  StorageFile? storageFile(Map<String, dynamic> data, String folderName) =>
      Helper.storageFile(data, folderName);

  List<StorageFile>? storageFiles(
    Map<String, dynamic> data,
    String folderName,
  ) =>
      Helper.storageFiles(data, folderName);

  U valueFromKey<U>(
    Map<String, dynamic> data,
    String key, {
    required U defaultValue,
  }) =>
      Helper.valueFromKey<U>(data, key, defaultValue: defaultValue);

  Map<U, V>? valueMapFromKey<U, V>(Map<String, dynamic> data, String key) =>
      Helper.valueMapFromKey<U, V>(data, key);

  List<U>? valueListFromKey<U>(Map<String, dynamic> data, String key) =>
      Helper.valueListFromKey<U>(data, key);

  List<Map<U, V>>? valueMapListFromKey<U, V>(
    Map<String, dynamic> data,
    String key,
  ) =>
      Helper.valueMapListFromKey<U, V>(data, key);

  Increment<U> valueFromIncrement<U extends num>(
    Map<String, dynamic> data,
    String key,
  ) =>
      Helper.valueFromIncrement<U>(data, key);

  bool isVal(Map<String, dynamic> data, String key) => Helper.isVal(data, key);

  Timestamp? timestampFromMap(dynamic data, String key) =>
      Helper.timestampFromMap(data, key);
}
