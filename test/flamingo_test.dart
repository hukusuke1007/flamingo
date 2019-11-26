import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'model/history.dart';
import 'model/setting.dart';
import 'model/user.dart';

void main() {
  group('#Firestore', () {
    DocumentAccessor documentAccessor;
    var mockHandleId = 0;
    FirebaseApp app;
    final log = <MethodCall>[];
    CollectionReference collectionReference;
    Query collectionGroupQuery;
    Transaction transaction;
    Timestamp timestamp;
    const kMockDocumentSnapshotData = <String, dynamic>{
      '1': 2
    };
    const kMockSnapshotMetadata = <String, dynamic>{
      'hasPendingWrites': false,
      'isFromCache': false,
    };
    const firebaseCoreChannel = MethodChannel('plugins.flutter.io/firebase_core');
    setUp(() async {
      print('setUp');
      documentAccessor = DocumentAccessor();
      firebaseCoreChannel.setMockMethodCallHandler(
            (MethodCall methodCall) async {},
      );
      app = await FirebaseApp.configure(
        name: 'testApp',
        options: const FirebaseOptions(
          googleAppID: '1:1234567890:ios:42424242424242',
          gcmSenderID: '1234567890',
        ),
      );

      /// initialize
      final firestore = Firestore(app: app);
      final storage = FirebaseStorage(app: app);
      final root = firestore.collection('version').document('1');
      Flamingo.configure(firestore: firestore, storage: storage, root: root);
      collectionReference = firestore.collection('foo');
      collectionGroupQuery = firestore.collectionGroup('bar');
      transaction = Transaction(0, firestore);
      timestamp = Timestamp.now();
      Firestore.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'Query#addSnapshotListener':
            final int handle = mockHandleId++;
            Future<void>.delayed(Duration.zero).then<void>((_) {
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
            final rootPath = Flamingo.instance.rootReference.path;
            if (methodCall.arguments['path'] == '$rootPath/user/0000') {
              return <String, dynamic>{
                'path': 'version/1/user/0000',
                'data': <String, dynamic>{'name': 'hoge', 'createdAt': timestamp, 'updatedAt': timestamp },
                'metadata': kMockSnapshotMetadata,
              };
            } else if (methodCall.arguments['path'] == '$rootPath/user/0001') {
              return <String, dynamic>{
                'path': 'version/1/user/0001',
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

    group('#Document', () {
      test('set', () async {
        final user = User()
          ..name = 'hoge';
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
              'data': <String, dynamic>{
                'uid': null,
                'name': user.name,
                'age': null,
                'memos': null,
                'createdAt': user.createdAt,
                'updatedAt': user.updatedAt,
              },
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
        final user = User()
          ..name = 'hoge';
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
              'data': <String, dynamic>{
                'uid': null,
                'name': savedUserName,
                'createdAt': savedCreatedAt,
                'age': null,
                'memos': null,
                'updatedAt': savedUpdatedAt
              },
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
              'data': <String, dynamic>{
                'uid': null,
                'name': user.name,
                'age': null,
                'memos': null,
                'updatedAt': user.updatedAt
              },
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
        final user = User()
          ..name = 'hoge';
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
              'data': <String, dynamic>{
                'uid': null,
                'name': user.name,
                'age': null,
                'memos': null,
                'createdAt': user.createdAt,
                'updatedAt': user.updatedAt
              },
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

      test('load', () async {
        final user = await documentAccessor.load<User>(User(id: '0000'));
        user.log();
        expect(user.name, 'hoge');
        expect(user.createdAt, timestamp);
        expect(user.updatedAt, timestamp);
        expect(log, <Matcher>[
          isMethodCall('DocumentReference#get', arguments: <String, dynamic>{
            'app': app.name,
            'path': user.documentPath,
            'source': 'default'
          })
        ]);
      });

      test('get notExists', () async {
        final user = await documentAccessor.load<User>(User(id: '0001'));
        expect(user.name, null);
        expect(user.createdAt, null);
        expect(user.updatedAt, null);
        expect(log, <Matcher>[
          isMethodCall('DocumentReference#get', arguments: <String, dynamic>{
            'app': app.name,
            'path': user.documentPath,
            'source': 'default'
          })
        ]);
      });
    });

    group('#SubCollection', () {
      test('set', () async {
        final user = User()
          ..name = 'hoge';
        await documentAccessor.save(user);
        final setting = Setting(collectionRef: user.settingsA.ref)
          ..isEnable = true;
        print(setting.documentPath);
        await documentAccessor.save(setting);
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
              'data': <String, dynamic>{
                'uid': null,
                'name': user.name,
                'age': null,
                'memos': null,
                'createdAt': user.createdAt,
                'updatedAt': user.updatedAt
              },
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
            'WriteBatch#setData',
            arguments: <String, dynamic>{
              'app': app.name,
              'handle': 1,
              'path': setting.documentPath,
              'data': <String, dynamic>{
                'isEnable': setting.isEnable,
                'createdAt': setting.createdAt,
                'updatedAt': setting.updatedAt
              },
              'options': {'merge': true}
            },
          ),
          isMethodCall(
            'WriteBatch#commit',
            arguments: <String, dynamic>{
              'handle': 1,
            },
          ),
        ],);
      });


      test('update', () async {
        final user = User()
          ..name = 'hoge';
        await documentAccessor.save(user);
        final setting = Setting(collectionRef: user.settingsA.ref)
          ..isEnable = true;
        await documentAccessor.save(setting);
        final savedCreatedAt = setting.createdAt;
        final savedUpdatedAt = setting.updatedAt;
        setting.isEnable = false;
        await documentAccessor.update(setting);
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
              'data': <String, dynamic>{
                'uid': null,
                'name': user.name,
                'age': null,
                'memos': null,
                'createdAt': user.createdAt,
                'updatedAt': user.updatedAt
              },
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
            'WriteBatch#setData',
            arguments: <String, dynamic>{
              'app': app.name,
              'handle': 1,
              'path': setting.documentPath,
              'data': <String, dynamic>{
                'isEnable': true,
                'createdAt': savedCreatedAt,
                'updatedAt': savedUpdatedAt
              },
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
              'path': setting.documentPath,
              'data': <String, dynamic>{
                'isEnable': setting.isEnable,
                'updatedAt': setting.updatedAt
              },
            },
          ),
          isMethodCall(
            'WriteBatch#commit',
            arguments: <String, dynamic>{
              'handle': 1,
            },
          ),
        ],);
      });

      test('delete', () async {
        final setting = Setting(collectionRef: User(id: '0000').settingsA.ref)
          ..isEnable = true;
        await documentAccessor.save(setting);
        await documentAccessor.delete(setting);
        expect(log,  <Matcher>[
          isMethodCall('WriteBatch#create', arguments: <String, dynamic>{
            'app': app.name,
          }),
          isMethodCall(
            'WriteBatch#setData',
            arguments: <String, dynamic>{
              'app': app.name,
              'handle': 1,
              'path': setting.documentPath,
              'data': <String, dynamic>{
                'isEnable': setting.isEnable,
                'createdAt': setting.createdAt,
                'updatedAt': setting.updatedAt
              },
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
              'path': setting.documentPath,
            },
          ),
          isMethodCall(
            'WriteBatch#commit',
            arguments: <String, dynamic>{
              'handle': 1,
            },
          ),
        ],);
      });

    });

    group('#Batch', () {
      test('set update delete', () async {
        final userA = User()
          ..name = 'hoge';
        final historyA = History()
          ..userId = userA.id;
        final userB = User(id: '0000')
          ..name = 'fuge';
        final historyB = History(id: '0');
        final batch = Batch()
          ..save(userA)
          ..save(historyA)
          ..update(userB)
          ..delete(historyB);
        await batch.commit();
        expect(log,  <Matcher>[
          isMethodCall('WriteBatch#create', arguments: <String, dynamic>{
            'app': app.name,
          }),
          isMethodCall(
            'WriteBatch#setData',
            arguments: <String, dynamic>{
              'app': app.name,
              'handle': 1,
              'path': userA.documentPath,
              'data': <String, dynamic>{
                'uid': null,
                'name': userA.name,
                'age': null,
                'memos': null,
                'createdAt': userA.createdAt,
                'updatedAt': userA.updatedAt
              },
              'options': {'merge': true}
            },
          ),
          isMethodCall(
            'WriteBatch#setData',
            arguments: <String, dynamic>{
              'app': app.name,
              'handle': 1,
              'path': historyA.documentPath,
              'data': <String, dynamic>{
                'userId': historyA.userId,
                'createdAt': historyA.createdAt,
                'updatedAt': historyA.updatedAt
              },
              'options': {'merge': true}
            },
          ),
          isMethodCall(
            'WriteBatch#updateData',
            arguments: <String, dynamic>{
              'app': app.name,
              'handle': 1,
              'path': userB.documentPath,
              'data': <String, dynamic>{
                'uid': null,
                'name': userB.name,
                'age': null,
                'memos': null,
                'updatedAt': userB.updatedAt
              },
            },
          ),
          isMethodCall(
            'WriteBatch#delete',
            arguments: <String, dynamic>{
              'app': app.name,
              'handle': 1,
              'path': historyB.documentPath,
            },
          ),
          isMethodCall(
            'WriteBatch#commit',
            arguments: <String, dynamic>{
              'handle': 1,
            },
          ),
        ],);
      });
    });

  });
}
