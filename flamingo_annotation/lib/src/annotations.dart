/// Document Field
/// [isWriteNotNull]
///   true: It's not saved if data is null.
///   false: It's also saved if data is null.
class Field {
  const Field({this.isWriteNotNull = true});
  final bool isWriteNotNull;
}

/// Document Field for Storage Model
/// [isWriteNotNull]
///   true: It's not saved if data is null.
///   false: It's also saved if data is null.
/// [folderName]
///   This is field name for Firestore and Cloud Storage.
/// [isSetNull]
///   true: It's will be set to null if data is null.
///   false: It's not will be set to nul if data is null.
class StorageField {
  const StorageField({
    this.isWriteNotNull = true,
    this.folderName,
    this.isSetNull = false,
  });
  final bool isWriteNotNull;
  final String folderName;
  final bool isSetNull;
}

/// Document Field for Model
/// [isWriteNotNull]
///   true: It's not saved if data is null.
///   false: It's also saved if data is null.
class ModelField {
  const ModelField({
    this.isWriteNotNull = true,
  });
  final bool isWriteNotNull;
}

/// Sub Collection Field
class SubCollection {
  const SubCollection();
}
