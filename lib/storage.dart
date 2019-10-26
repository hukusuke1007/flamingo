import 'package:firebase_storage/firebase_storage.dart';
import 'helper/helper.dart';
import 'model/storage_file.dart';
import 'flamingo.dart';
//import 'package:rxdart/rxdart.dart';
import 'dart:io';

class Storage {
  Storage() {
    storage = storageInstance();
  }

  static String fileName({int length}) => Helper.randomString(length: length);

  FirebaseStorage storage;
//  PublishSubject<StorageTaskEvent> uploader;

  Future<StorageFile> save(String folderPath, File data, {String fileName, String mimeType}) async {
    final refFileName = fileName != null ? fileName : Storage.fileName();
    final refMimeType = mimeType != null ? mimeType : '';
    final path = '$folderPath/$refFileName';
    final ref = storage.ref().child(path);
    final uploadTask = ref.putFile(data, StorageMetadata(contentType: refMimeType));
//    uploadTask.events.listen((event) {
//      if (uploader != null) {
//        uploader.add(event);
//      }
//    });
    final snapshot = await uploadTask.onComplete;
    final downloadUrl = await snapshot.ref.getDownloadURL() as String;
    return StorageFile(
      name: refFileName,
      url: downloadUrl,
      mimeType: refMimeType,
    );
  }

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

//  void fetch() {
//    uploader = PublishSubject<StorageTaskEvent>();
//  }
//
//  void dispose() {
//    uploader.close();
//  }
}