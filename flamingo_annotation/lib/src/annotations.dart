class Field {
  const Field({this.isWriteNotNull = true});
  final bool isWriteNotNull;
}

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

class ModelField {
  const ModelField({
    this.isWriteNotNull = true,
  });
  final bool isWriteNotNull;
}
