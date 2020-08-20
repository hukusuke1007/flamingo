import 'dart:async';
import 'dart:io';

import '../flamingo.dart';

abstract class StorageRepository {
  FirebaseStorage get storage;
  Stream<StorageTaskEvent> get uploader;
  Future<StorageFile> save(
    String folderPath,
    File data, {
    String fileName,
    String mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  });
  Future<void> delete(String folderPath, StorageFile storageFile);
  Future<StorageFile> saveWithDoc(
    DocumentReference reference,
    String folderName,
    File data, {
    String fileName,
    String mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  });
  Future<void> deleteWithDoc(
    DocumentReference reference,
    String folderName,
    StorageFile storageFile, {
    bool isNotNull = true,
  });
  void fetch();
  void dispose();
}

class Storage implements StorageRepository {
  static String fileName({int length}) => Helper.randomString(length: length);

  final _storage = storageInstance;
  StreamController<StorageTaskEvent> _uploader;

  @override
  FirebaseStorage get storage => _storage;

  @override
  Stream<StorageTaskEvent> get uploader => _uploader.stream;

  @override
  Future<StorageFile> save(
    String folderPath,
    File data, {
    String fileName,
    String mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  }) async {
    final refFileName = fileName != null ? fileName : Storage.fileName();
    final refMimeType = mimeType != null ? mimeType : '';
    final path = '$folderPath/$refFileName';
    final ref = storage.ref().child(path);
    final uploadTask = ref.putFile(data,
        StorageMetadata(contentType: refMimeType, customMetadata: metadata));
    uploadTask.events.listen((event) {
      if (_uploader != null) {
        _uploader.add(event);
      }
    });
    final snapshot = await uploadTask.onComplete;
    final downloadUrl = await snapshot.ref.getDownloadURL() as String;
    return StorageFile(
      name: refFileName,
      url: downloadUrl,
      path: path,
      mimeType: refMimeType,
      metadata: metadata,
      additionalData: additionalData,
    );
  }

  @override
  Future<void> delete(String folderPath, StorageFile storageFile) async {
    if (storageFile != null) {
      final path = '$folderPath/${storageFile.name}';
      final ref = storage.ref().child(path);
      await ref.delete();
      storageFile.isDeleted = true;
    } else {
      print('StorageFile is null');
    }
    return;
  }

  @override
  Future<StorageFile> saveWithDoc(
    DocumentReference reference,
    String folderName,
    File data, {
    String fileName,
    String mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  }) async {
    final folderPath = '${reference.path}/$folderName';
    final storageFile = await save(folderPath, data,
        fileName: fileName, mimeType: mimeType, metadata: metadata);
    storageFile.additionalData = additionalData;
    final documentAccessor = DocumentAccessor();
    final values = <String, dynamic>{};
    values['$folderName'] = storageFile.toJson();
    await documentAccessor.saveRaw(values, reference);
    return storageFile;
  }

  @override
  Future<void> deleteWithDoc(
    DocumentReference reference,
    String folderName,
    StorageFile storageFile, {
    bool isNotNull = true,
  }) async {
    final folderPath = '${reference.path}/$folderName';
    await delete(folderPath, storageFile);
    if (storageFile.isDeleted) {
      final values = <String, dynamic>{};
      if (isNotNull) {
        values['$folderName'] = FieldValue.delete();
      } else {
        values['$folderName'] = null;
      }
      final documentAccessor = DocumentAccessor();
      await documentAccessor.updateRaw(values, reference);
    }
    return;
  }

  @override
  void fetch() {
    _uploader ??= StreamController<StorageTaskEvent>();
  }

  @override
  void dispose() {
    _uploader.close();
    _uploader = null;
  }
}
