import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as prefix0;
import 'model/user.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flamingo/flamingo.dart';

void main() {

  group('#Firestore', () {

    DocumentAccessor documentAccessor;

    int mockHandleId = 0;
    Firestore firestore;
    FirebaseApp app;
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
      print('setUp');
      documentAccessor = DocumentAccessor();
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
      Flamingo.configure(Firestore.instance.collection('version').document("1"), app: app);
      firestore = firestoreInstance();
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
          case 'WriteBatch#setData':
            return null;
          case 'WriteBatch#update':
            return null;
          case 'WriteBatch#delete':
            return null;
          case 'WriteBatch#commit':
            return null;
          default:
            return null;
        }
      });
      log.clear();
    });

    tearDown(() {
      print('tearDown');
    });

    test('configure', () async {
      expect(Flamingo.instance.rootReference.path, 'version/1');
    });

    test('set', () async {
      final user = User();
      user.name = 'hoge';
      await documentAccessor.save(user);
      expect(log,  <Matcher>[
          isMethodCall('WriteBatch#create', arguments: <String, dynamic>{
            'app': app.name,
          }),
          isMethodCall(
            'WriteBatch#setData',
            arguments: <String, dynamic>{
              'app': app.name,
              'handle': 1,
              'path': user.documentPath,
              'data': <String, dynamic>{'name': user.name, 'createdAt': user.createdAt, 'updatedAt': user.updatedAt},
              'options': {'merge': true}
            },
          ),
          isMethodCall(
            'WriteBatch#commit',
            arguments: <String, dynamic>{
              'handle': 1,
            },
          ),
        ],
      );
    });

    test('update', () async {
      final user = User();
      user.name = 'hoge';
      await documentAccessor.save(user);
      final savedUserName = user.name;
      final savedCreatedAt = user.createdAt;
      final savedUpdatedAt = user.updatedAt;

      user.name = 'fuge';
      await documentAccessor.update(user);

      expect(log,  <Matcher>[
        isMethodCall('WriteBatch#create', arguments: <String, dynamic>{
          'app': app.name,
        }),
        isMethodCall(
          'WriteBatch#setData',
          arguments: <String, dynamic>{
            'app': app.name,
            'handle': 1,
            'path': user.documentPath,
            'data': <String, dynamic>{'name': savedUserName, 'createdAt': savedCreatedAt, 'updatedAt': savedUpdatedAt},
            'options': {'merge': true}
          },
        ),
        isMethodCall(
          'WriteBatch#commit',
          arguments: <String, dynamic>{
            'handle': 1,
          },
        ),
        isMethodCall('WriteBatch#create', arguments: <String, dynamic>{
          'app': app.name,
        }),
        isMethodCall(
          'WriteBatch#updateData',
          arguments: <String, dynamic>{
            'app': app.name,
            'handle': 1,
            'path': user.documentPath,
            'data': <String, dynamic>{'name': user.name, 'updatedAt': user.updatedAt},
          },
        ),
        isMethodCall(
          'WriteBatch#commit',
          arguments: <String, dynamic>{
            'handle': 1,
          },
        ),
      ],
      );
    });

    test('delete', () async {
      final user = User();
      user.name = 'hoge';
      await documentAccessor.save(user);
      await documentAccessor.delete(user);
      expect(log,  <Matcher>[
        isMethodCall('WriteBatch#create', arguments: <String, dynamic>{
          'app': app.name,
        }),
        isMethodCall(
          'WriteBatch#setData',
          arguments: <String, dynamic>{
            'app': app.name,
            'handle': 1,
            'path': user.documentPath,
            'data': <String, dynamic>{'name': user.name, 'createdAt': user.createdAt, 'updatedAt': user.updatedAt},
            'options': {'merge': true}
          },
        ),
        isMethodCall(
          'WriteBatch#commit',
          arguments: <String, dynamic>{
            'handle': 1,
          },
        ),
        isMethodCall('WriteBatch#create', arguments: <String, dynamic>{
          'app': app.name,
        }),
        isMethodCall(
          'WriteBatch#delete',
          arguments: <String, dynamic>{
            'app': app.name,
            'handle': 1,
            'path': user.documentPath,
          },
        ),
        isMethodCall(
          'WriteBatch#commit',
          arguments: <String, dynamic>{
            'handle': 1,
          },
        ),
      ],
      );
    });

//    test('get', () async {
//      final DocumentReference documentReference =
//      firestore.document('foo/bar');
//      final DocumentSnapshot snapshot =
//      await transaction.get(documentReference);
//      expect(snapshot.reference.firestore, firestore);
//      expect(log, <Matcher>[
//        isMethodCall('Transaction#get', arguments: <String, dynamic>{
//          'app': app.name,
//          'transactionId': 0,
//          'path': documentReference.path
//        })
//      ]);
//    });
//
//    test('get notExists', () async {
//      final DocumentReference documentReference =
//      firestore.document('foo/notExists');
//      await transaction.get(documentReference);
//      expect(log, <Matcher>[
//        isMethodCall('Transaction#get', arguments: <String, dynamic>{
//          'app': app.name,
//          'transactionId': 0,
//          'path': documentReference.path
//        })
//      ]);
//    });
//
//    test('delete', () async {
//      final DocumentReference documentReference =
//      firestore.document('foo/bar');
//      await transaction.delete(documentReference);
//      expect(log, <Matcher>[
//        isMethodCall('Transaction#delete', arguments: <String, dynamic>{
//          'app': app.name,
//          'transactionId': 0,
//          'path': documentReference.path
//        })
//      ]);
//    });
//
//    test('update', () async {
//      final DocumentReference documentReference =
//      firestore.document('foo/bar');
//      final DocumentSnapshot documentSnapshot = await documentReference.get();
//      final Map<String, dynamic> data = documentSnapshot.data;
//      data['key2'] = 'val2';
//      await transaction.set(documentReference, data);
//      expect(log, <Matcher>[
//        isMethodCall('DocumentReference#get', arguments: <String, dynamic>{
//          'app': app.name,
//          'path': 'foo/bar',
//          'source': 'default',
//        }),
//        isMethodCall('Transaction#set', arguments: <String, dynamic>{
//          'app': app.name,
//          'transactionId': 0,
//          'path': documentReference.path,
//          'data': <String, dynamic>{'key1': 'val1', 'key2': 'val2'}
//        })
//      ]);
//    });
//
//    test('get', () async {
//      final DocumentSnapshot snapshot =
//      await collectionReference.document('bar').get(source: Source.cache);
//      expect(snapshot.reference.firestore, firestore);
//      expect(
//        log,
//        equals(<Matcher>[
//          isMethodCall(
//            'DocumentReference#get',
//            arguments: <String, dynamic>{
//              'app': app.name,
//              'path': 'foo/bar',
//              'source': 'cache',
//            },
//          ),
//        ]),
//      );
//      log.clear();
//      expect(snapshot.reference.path, equals('foo/bar'));
//      expect(snapshot.data.containsKey('key1'), equals(true));
//      expect(snapshot.data['key1'], equals('val1'));
//      expect(snapshot.exists, isTrue);
//
//      final DocumentSnapshot snapshot2 = await collectionReference
//          .document('notExists')
//          .get(source: Source.serverAndCache);
//      expect(snapshot2.data, isNull);
//      expect(snapshot2.exists, isFalse);
//      expect(
//        log,
//        equals(<Matcher>[
//          isMethodCall(
//            'DocumentReference#get',
//            arguments: <String, dynamic>{
//              'app': app.name,
//              'path': 'foo/notExists',
//              'source': 'default',
//            },
//          ),
//        ]),
//      );
//
//      try {
//        await collectionReference.document('baz').get();
//      } on PlatformException catch (e) {
//        expect(e.code, equals('UNKNOWN_PATH'));
//      }
//    });
//    test('collection', () async {
//      final CollectionReference colRef =
//      collectionReference.document('bar').collection('baz');
//      expect(colRef.path, equals('foo/bar/baz'));
//    });
//    test('parent', () async {
//      final CollectionReference colRef =
//      collectionReference.document('bar').collection('baz');
//      expect(colRef.parent().documentID, equals('bar'));
//    });

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
