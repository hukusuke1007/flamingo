import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'model/user.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flamingo/flamingo.dart';

void main() {

  group('#Firestore', () {
    int mockHandleId = 0;
    FirebaseApp app;
    Firestore firestore;
    final List<MethodCall> log = <MethodCall>[];
    CollectionReference collectionReference;
    Query collectionGroupQuery;
    Transaction transaction;
    const Map<String, dynamic> kMockDocumentSnapshotData = <String, dynamic>{
      '1': 2
    };
    const Map<String, dynamic> kMockSnapshotMetadata = <String, dynamic>{
      "hasPendingWrites": false,
      "isFromCache": false,
    };
    setUp(() async {
//      Flamingo.configure(firestore().collection('version').document("1"));
      print('setUp');
      FirebaseApp.channel.setMockMethodCallHandler(
            (MethodCall methodCall) async {},
      );
      app = await FirebaseApp.configure(
        name: 'testApp',
        options: const FirebaseOptions(
          googleAppID: '1:1234567890:ios:42424242424242',
          gcmSenderID: '1234567890',
        ),
      );
      firestore = Firestore(app: app);
      collectionReference = firestore.collection('foo');
      collectionGroupQuery = firestore.collectionGroup('bar');
      transaction = Transaction(0, firestore);
      Firestore.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'Query#addSnapshotListener':
            final int handle = mockHandleId++;
            // Wait before sending a message back.
            // Otherwise the first request didn't have the time to finish.
            Future<void>.delayed(Duration.zero).then<void>((_) {
              // TODO(hterkelsen): Remove this when defaultBinaryMessages is in stable.
              // https://github.com/flutter/flutter/issues/33446
              // ignore: deprecated_member_use
              BinaryMessages.handlePlatformMessage(
                Firestore.channel.name,
                Firestore.channel.codec.encodeMethodCall(
                  MethodCall('QuerySnapshot', <String, dynamic>{
                    'app': app.name,
                    'handle': handle,
                    'paths': <String>["${methodCall.arguments['path']}/0"],
                    'documents': <dynamic>[kMockDocumentSnapshotData],
                    'metadatas': <Map<String, dynamic>>[kMockSnapshotMetadata],
                    'metadata': kMockSnapshotMetadata,
                    'documentChanges': <dynamic>[
                      <String, dynamic>{
                        'oldIndex': -1,
                        'newIndex': 0,
                        'type': 'DocumentChangeType.added',
                        'document': kMockDocumentSnapshotData,
                        'metadata': kMockSnapshotMetadata,
                      },
                    ],
                  }),
                ),
                    (_) {},
              );
            });
            return handle;
          case 'DocumentReference#addSnapshotListener':
            final int handle = mockHandleId++;
            // Wait before sending a message back.
            // Otherwise the first request didn't have the time to finish.
            Future<void>.delayed(Duration.zero).then<void>((_) {
              // TODO(hterkelsen): Remove this when defaultBinaryMessages is in stable.
              // https://github.com/flutter/flutter/issues/33446
              // ignore: deprecated_member_use
              BinaryMessages.handlePlatformMessage(
                Firestore.channel.name,
                Firestore.channel.codec.encodeMethodCall(
                  MethodCall('DocumentSnapshot', <String, dynamic>{
                    'handle': handle,
                    'path': methodCall.arguments['path'],
                    'data': kMockDocumentSnapshotData,
                    'metadata': kMockSnapshotMetadata,
                  }),
                ),
                    (_) {},
              );
            });
            return handle;
          case 'Query#getDocuments':
            return <String, dynamic>{
              'paths': <String>["${methodCall.arguments['path']}/0"],
              'documents': <dynamic>[kMockDocumentSnapshotData],
              'metadatas': <Map<String, dynamic>>[kMockSnapshotMetadata],
              'metadata': kMockSnapshotMetadata,
              'documentChanges': <dynamic>[
                <String, dynamic>{
                  'oldIndex': -1,
                  'newIndex': 0,
                  'type': 'DocumentChangeType.added',
                  'document': kMockDocumentSnapshotData,
                  'metadata': kMockSnapshotMetadata,
                },
              ],
            };
          case 'DocumentReference#setData':
            return true;
          case 'DocumentReference#get':
            if (methodCall.arguments['path'] == 'foo/bar') {
              return <String, dynamic>{
                'path': 'foo/bar',
                'data': <String, dynamic>{'key1': 'val1'},
                'metadata': kMockSnapshotMetadata,
              };
            } else if (methodCall.arguments['path'] == 'foo/notExists') {
              return <String, dynamic>{
                'path': 'foo/notExists',
                'data': null,
                'metadata': kMockSnapshotMetadata,
              };
            }
            throw PlatformException(code: 'UNKNOWN_PATH');
          case 'Firestore#runTransaction':
            return <String, dynamic>{'1': 3};
          case 'Transaction#get':
            if (methodCall.arguments['path'] == 'foo/bar') {
              return <String, dynamic>{
                'path': 'foo/bar',
                'data': <String, dynamic>{'key1': 'val1'},
                'metadata': kMockSnapshotMetadata,
              };
            } else if (methodCall.arguments['path'] == 'foo/notExists') {
              return <String, dynamic>{
                'path': 'foo/notExists',
                'data': null,
                'metadata': kMockSnapshotMetadata,
              };
            }
            throw PlatformException(code: 'UNKNOWN_PATH');
          case 'Transaction#set':
            return null;
          case 'Transaction#update':
            return null;
          case 'Transaction#delete':
            return null;
          case 'WriteBatch#create':
            return 1;
          default:
            return null;
        }
      });
      log.clear();
    });

    tearDown(() {
      print('tearDown');
    });

    test('set', () async {
      final DocumentReference documentReference =
      firestore.document('foo/bar');
      final DocumentSnapshot documentSnapshot = await documentReference.get();
      final Map<String, dynamic> data = documentSnapshot.data;
      data['key2'] = 'val2';
      await transaction.set(documentReference, data);
      print(documentSnapshot.data);
      print('----');
      print(log);
      expect(log, <Matcher>[
        isMethodCall('DocumentReference#get', arguments: <String, dynamic>{
          'app': app.name,
          'path': 'foo/bar',
          'source': 'default',
        }),
        isMethodCall('Transaction#set', arguments: <String, dynamic>{
          'app': app.name,
          'transactionId': 0,
          'path': documentReference.path,
          'data': <String, dynamic>{'key1': 'val1', 'key2': 'val2'}
        })
      ]);
    });

//  test('Document 1', () async {
//  //    final user = User();
//  //    user.uid = user.id;
//  //    user.name = 'shohei';
//  //    user.memos = ['a', 'i', 'u', 'e', 'o'];
//  //    final documentAccessor = DocumentAccessor();
//  //    await documentAccessor.save(user);
//  //    user.log();
//  //    expect(true, true);
//    });
  });
}
