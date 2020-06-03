import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flamingo/collection_data_source.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_example/model/user.dart';
import 'package:test/test.dart';

void main() {
  /// Configure
  final firestore = MockFirestoreInstance();
  final storage = MockFirebaseStorage();
  Flamingo.configure(
      firestore: firestore,
      storage: storage,
      root: firestore.document('test/v1'));

  /// Test
  test('Save and Load user', () async {
    final user = User(id: '0')..name = 'hello';
    final documentAccessor = DocumentAccessor();
    await documentAccessor.save(user);
    final _user = await documentAccessor.load<User>(User(id: '0'));
    expect(_user.id, user.id);
    expect(_user.name, user.name);
  });
  test('Save and Load users', () async {
    final userA = User(id: '0')..name = 'nana';
    final userB = User(id: '1')..name = 'ken';
    final batch = Batch()..save(userA)..save(userB);
    await batch.commit();
    final documentAccessor = DocumentAccessor();

    final _userA = await documentAccessor.load<User>(User(id: '0'));
    final _userB = await documentAccessor.load<User>(User(id: '1'));
    expect(_userA.id, userA.id);
    expect(_userA.name, userA.name);
    expect(_userB.id, _userB.id);
    expect(_userB.name, _userB.name);

    final collectionRef = User().collectionRef;
    final collectionDataSource = CollectionDataSource();
    final snapshot =
        await collectionDataSource.loadDocuments(collectionRef.path);
    final users = snapshot.documents
        .map((e) => User(snapshot: e, collectionRef: collectionRef))
        .toList();
    for (var user in users) {
      expect(user.name, isNotNull);
    }
  });
}
