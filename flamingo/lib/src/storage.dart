import 'dart:async';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart';

import '../flamingo.dart';

abstract class StorageRepository {
  FirebaseStorage get storage;
  Stream<TaskSnapshot> get uploader;
  Reference ref(StorageFile storageFile);
  Future<StorageFile> save(
    String folderPath,
    File data, {
    String filename,
    String mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  });
  Future<StorageFile> saveBlob(
    String folderPath,
    dynamic data, {
    String? filename,
    String mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  });
  Future<StorageFile> saveWithDoc(
    DocumentReference reference,
    String folderName,
    File data, {
    String? filename,
    String mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  });
  Future<StorageFile> saveBlobWithDoc(
    DocumentReference reference,
    String folderName,
    dynamic data, {
    String? filename,
    String mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  });
  Future<String> getDownloadUrl(StorageFile storageFile);
  Future<String> getDownloadUrlWithPath(String filePath);
  Future<Uint8List?> getData(StorageFile storageFile, [int maxSize]);
  Future<Uint8List?> getDataWithPath(String filePath, [int maxSize]);
  Future<void> delete(StorageFile storageFile);
  Future<void> deleteWithPath(String filePath);
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
  Storage({
    FirebaseStorage? storage,
  }) {
    _storage = storage ?? storageInstance;
  }
  static String fileName({int? length}) => Helper.randomString(length: length);

  late FirebaseStorage _storage;
  PublishSubject<TaskSnapshot>? _uploader;

  @override
  FirebaseStorage get storage => _storage;

  @override
  Stream<TaskSnapshot> get uploader {
    assert(_uploader != null, 'uploader is null. Please call fetch().');
    return _uploader!.stream;
  }

  @override
  Reference ref(StorageFile storageFile) =>
      storage.ref().child(storageFile.path);

  @override
  Future<StorageFile> save(
    String folderPath,
    File data, {
    String? filename,
    String mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  }) async {
    final refFilename = filename ?? Storage.fileName();
    final path = '$folderPath/$refFilename';
    final ref = storage.ref().child(path);
    final settableMetadata =
        SettableMetadata(contentType: mimeType, customMetadata: metadata);
    final uploadTask = ref.putData(data.readAsBytesSync(), settableMetadata);
    if (_uploader != null) {
      uploadTask.snapshotEvents.listen(_uploader!.add);
    }
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return StorageFile(
      name: refFilename,
      url: downloadUrl,
      path: path,
      mimeType: mimeType,
      metadata: metadata,
      additionalData: additionalData,
    );
  }

  @override
  Future<StorageFile> saveBlob(
    String folderPath,
    dynamic data, {
    String? filename,
    String mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  }) async {
    final refFilename = filename ?? Storage.fileName();
    final path = '$folderPath/$refFilename';
    final ref = storage.ref().child(path);
    final settableMetadata =
        SettableMetadata(contentType: mimeType, customMetadata: metadata);
    final uploadTask = ref.putBlob(data, settableMetadata);
    if (_uploader != null) {
      uploadTask.snapshotEvents.listen(_uploader!.add);
    }
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return StorageFile(
      name: refFilename,
      url: downloadUrl,
      path: path,
      mimeType: mimeType,
      metadata: metadata,
      additionalData: additionalData,
    );
  }

  @override
  Future<StorageFile> saveWithDoc(
    DocumentReference reference,
    String folderName,
    File data, {
    String? filename,
    String mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  }) async {
    final folderPath = '${reference.path}/$folderName';
    final storageFile = await save(
      folderPath,
      data,
      filename: filename,
      mimeType: mimeType,
      metadata: metadata,
      additionalData: additionalData,
    );
    final documentAccessor = DocumentAccessor();
    await documentAccessor.saveRaw(
      <String, dynamic>{
        folderName: storageFile.toJson(),
      },
      reference,
    );
    return storageFile;
  }

  @override
  Future<StorageFile> saveBlobWithDoc(
    DocumentReference reference,
    String folderName,
    dynamic data, {
    String? filename,
    String mimeType = mimeTypeApplicationOctetStream,
    Map<String, String> metadata = const <String, String>{},
    Map<String, dynamic> additionalData = const <String, dynamic>{},
  }) async {
    final folderPath = '${reference.path}/$folderName';
    final storageFile = await saveBlob(
      folderPath,
      data,
      filename: filename,
      mimeType: mimeType,
      metadata: metadata,
      additionalData: additionalData,
    );
    final documentAccessor = DocumentAccessor();
    await documentAccessor.saveRaw(
      <String, dynamic>{
        folderName: storageFile.toJson(),
      },
      reference,
    );
    return storageFile;
  }

  @override
  Future<String> getDownloadUrl(StorageFile storageFile) async {
    final ref = storage.ref().child(storageFile.path);
    return ref.getDownloadURL();
  }

  @override
  Future<String> getDownloadUrlWithPath(String filePath) async {
    final ref = storage.ref().child(filePath);
    return ref.getDownloadURL();
  }

  @override
  Future<Uint8List?> getData(
    StorageFile storageFile, [
    int maxSize = 10485760,
  ]) async {
    final ref = storage.ref().child(storageFile.path);
    return ref.getData(maxSize);
  }

  @override
  Future<Uint8List?> getDataWithPath(
    String filePath, [
    int maxSize = 10485760,
  ]) async {
    final ref = storage.ref().child(filePath);
    return ref.getData(maxSize);
  }

  @override
  Future<void> delete(StorageFile storageFile) async {
    final ref = storage.ref().child(storageFile.path);
    await ref.delete();
    storageFile.deleted();
  }

  @override
  Future<void> deleteWithPath(String filePath) async {
    final ref = storage.ref().child(filePath);
    await ref.delete();
  }

  @override
  Future<void> deleteWithDoc(
    DocumentReference reference,
    String folderName,
    StorageFile storageFile, {
    bool isNotNull = true,
  }) async {
    await delete(storageFile);
    if (storageFile.isDeleted) {
      final values = <String, dynamic>{};
      if (isNotNull) {
        values[folderName] = FieldValue.delete();
      } else {
        values[folderName] = null;
      }
      final documentAccessor = DocumentAccessor();
      await documentAccessor.updateRaw(values, reference);
    }
    return;
  }

  @override
  void fetch() {
    _uploader ??= PublishSubject<TaskSnapshot>();
  }

  @override
  void dispose() {
    _uploader?.close();
    _uploader = null;
  }
}
