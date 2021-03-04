import 'package:flamingo/flamingo.dart';
import 'package:flamingo_example/model/app_user.dart';
import 'package:flamingo_example/model/count.dart';
import 'package:flamingo_example/model/list_sample.dart';
import 'package:flamingo_example/model/map_sample.dart';
import 'package:flamingo_example/model/model_sample.dart';
import 'package:flamingo_example/model/post.dart';
import 'package:flamingo_example/model/score.dart';
import 'package:flamingo_example/model/setting.dart';
import 'package:flamingo_example/model/shop/cart.dart';
import 'package:flamingo_example/model/shop/shop.dart';

import 'image_helper.dart';
import 'model/address.dart';
import 'model/credit_card.dart';
import 'model/item.dart';
import 'model/medal.dart';
import 'model/owner.dart';
import 'model/point.dart';
import 'model/public/index.dart' as public;
import 'model/ranking.dart';
import 'model/user.dart';

extension _Extension on FlamingoTest {
  void assertCreateDocument(Document d1, Document d2) {
    assert(d1.id == d2.id);
    assert(d1.documentPath == d2.documentPath);
    assert(d1.reference.path == d2.reference.path);
    assert(d1.collectionRef.path == d2.collectionRef.path);
  }

  void assertDeleteDocument(Document? d1) {
    assert(d1 == null);
  }

  void assertCollection(Document item, String collectionPath) {
    assert(item.id.isNotEmpty);
    assert(item.documentPath == '$collectionPath/${item.id}');
    assert(item.reference.path == '$collectionPath/${item.id}');
    assert(item.collectionRef.path == collectionPath);
  }

  void assertStorageFile(StorageFile d1, StorageFile d2) {
    assert(d1.name == d2.name);
    assert(d1.path == d2.path);
    assert(d1.url == d2.url);
    assert(d1.mimeType == d2.mimeType);
  }
}

class FlamingoTest {
  FlamingoTest() {
    _collectionPaging = CollectionPaging<User>(
      query: firestoreInstance
          .collection(User().collectionPath)
          .orderBy('createdAt', descending: true),
      limit: 20,
      decode: (snap) => User(snapshot: snap),
    );
  }
  final DocumentAccessor documentAccessor = DocumentAccessor();

  late CollectionPaging<User> _collectionPaging;

  Future all() async {
    print('------- start -------');

    await save();
    await update();
    await delete();
    await saveRaw();
    await updateRaw();
    await deleteRaw();
    await batchSave();
    await batchUpdateDelete();
    await batchSaveRaw();
    await batchCollectionCRUD();
    await batchUpdateDeleteRaw();
    await getAndUpdate();
    await getCollection();
    await subCollection();
    await saveStorage();
    await deleteStorage();
    await saveStorageAndDoc();
    await deleteStorageAndDoc();
    await distributedCounter();
    await transactionSave();
    await transactionUpdate();
    await transactionDelete();
    await saveMap();
    await saveList();
    await checkModelSample();
    await listenerSample();
    await model();
    await incrementTest1();
    await incrementTest2();
    await incrementTest3();
    await valueZeroTest();
    await extendCRUD();
    await testReferencePath();
    await testCustomFieldValueKey();
    print('------- finish -------');
  }

  Future save() async {
    print('--- save ---');

    final user = User()..name = 'hoge';
    await documentAccessor.save(user);
    user.log();

    final _user = await documentAccessor.load<User>(User(id: user.id));
    _user!.log();

    assertCreateDocument(user, _user);
    assert(user.name == _user.name);
  }

  Future update() async {
    print('--- update ---');
    final user = User()..name = 'hoge';
    await documentAccessor.save(user);
    user.log();

    final updateUser = User(id: user.id)..name = 'fuga';
    await documentAccessor.update(updateUser);

    final _user = await documentAccessor.load<User>(User(id: user.id));

    assertCreateDocument(user, _user!);
    assert(user.name != _user.name);

    print('--- timestamp test ---');
    final data = <String, dynamic>{
      'name': 'shohei',
      UserKey.editAt.value: {'_seconds': 1575163645, '_nanoseconds': 648000000},
      UserKey.clearAt.value: Timestamp.now(),
      _user.updatedFieldValueKey: {
        '_seconds': 1575163645,
        '_nanoseconds': 648000000
      },
      _user.createdFieldValueKey: {
        '_seconds': 1575163645,
        '_nanoseconds': 648000000
      },
      _user.updatedFieldValueKey: {
        '_seconds': 1575163645,
        '_nanoseconds': 648000000
      },
    };
    {
      final _user = User(values: data);
      assert(_user.createdAt != null);
      assert(_user.updatedAt != null);
      assert(_user.editAt != null);
      assert(_user.clearAt != null);
      print(_user.editAt?.toDate());
      print(_user.clearAt?.toDate());
    }
  }

  Future delete() async {
    print('--- delete ---');
    final user = User()..name = 'hoge';
    await documentAccessor.save(user);

    await documentAccessor.delete(User(id: user.id));
    final _user = await documentAccessor.load<User>(User(id: user.id));

    assertDeleteDocument(_user);
  }

  Future saveRaw() async {
    print('--- saveRaw ---');
    final user = User()..name = 'hoge';

    await documentAccessor.saveRaw(user.toData(), user.reference);

    final _user = await documentAccessor.load<User>(User(id: user.id));
    _user!.log();
    assertCreateDocument(user, _user);
    assert(user.name == _user.name);
  }

  Future updateRaw() async {
    print('--- updateRaw ---');
    final user = User()..name = 'hoge';
    await documentAccessor.saveRaw(user.toData(), user.reference);

    final updateUser = User(id: user.id)..name = 'fuga';

    await documentAccessor.updateRaw(updateUser.toData(), updateUser.reference);

    final _user = await documentAccessor.load<User>(User(id: user.id));
    _user!.log();

    assertCreateDocument(user, _user);
    assert(user.name != _user.name);
  }

  Future deleteRaw() async {
    print('--- deleteRaw ---');
    final user = User()..name = 'hoge';
    await documentAccessor.saveRaw(user.toData(), user.reference);

    await documentAccessor.deleteWithReference(user.reference);
    final _user = await documentAccessor.load<User>(User(id: user.id));
    assertDeleteDocument(_user);
  }

  Future batchSave() async {
    print('--- batchSave ---');
    final userA = User()..name = 'hoge';
    final userB = User()..name = 'fuga';
    final batch = Batch()..save(userA)..save(userB);
    print(userA.id);
    print(userB.id);
    await batch.commit();

    final _userA = await documentAccessor.load<User>(User(id: userA.id));
    assertCreateDocument(userA, _userA!);

    final _userB = await documentAccessor.load<User>(User(id: userB.id));
    assertCreateDocument(userB, _userB!);
  }

  Future batchSaveRaw() async {
    print('--- batchSaveRaw ---');
    final userA = User()..name = 'hoge';
    final userB = User()..name = 'fuga';
    final batch = Batch()
      ..saveRaw(userA.toData(), userA.reference)
      ..saveRaw(userB.toData(), userB.reference, isTimestamp: true);
    await batch.commit();

    final _userA = await documentAccessor.load<User>(User(id: userA.id));
    assertCreateDocument(userA, _userA!);

    final _userB = await documentAccessor.load<User>(User(id: userB.id));
    assertCreateDocument(userB, _userB!);
  }

  Future batchUpdateDelete() async {
    print('--- batchUpdateDelete ---');
    final userA = User()..name = 'hoge';
    final userB = User()..name = 'fuga';
    final batch = Batch()..save(userA)..save(userB);
    await batch.commit();
    await _batchUpdateDelete(userA, userB);
  }

  Future _batchUpdateDelete(User userA, User userB) async {
    final hoge = await documentAccessor.load<User>(User(id: userA.id));
    hoge!.name = 'hogehoge';
    final batch = Batch()
      ..update(hoge)
      ..delete(userB);
    await batch.commit();

    final _hoge = await documentAccessor.load<User>(User(id: userA.id));
    assertCreateDocument(userA, _hoge!);
    assert(userA.name != hoge.name);

    final _user = await documentAccessor.load<User>(User(id: userB.id));
    assertDeleteDocument(_user);
  }

  Future batchUpdateDeleteRaw() async {
    print('--- batchUpdateDeleteRaw ---');
    final userA = User()..name = 'hoge';
    final userB = User()..name = 'fuga';
    final batch = Batch()..save(userA)..save(userB);
    await batch.commit();
    userA.log();
    userB.log();

    {
      final hoge = await documentAccessor.load<User>(User(id: userA.id));
      hoge!.name = 'hogehoge';
      final batch = Batch()
        ..updateRaw(hoge.toData(), hoge.reference, isTimestamp: true)
        ..deleteWithReference(userB.reference);
      await batch.commit();

      final _hoge = await documentAccessor.load<User>(User(id: userA.id));
      assertCreateDocument(userA, _hoge!);
      assert(userA.name != hoge.name);

      final _user = await documentAccessor.load<User>(User(id: userB.id));
      assertDeleteDocument(_user);
    }
  }

  Future batchCollectionCRUD() async {
    print('--- batchCollectionReference ---');
    final userA = User();
    final setting = Setting(collectionRef: userA.setting.ref)..isEnable = true;

    // create
    {
      final batch = Batch()
        ..save(setting, reference: userA.setting.ref.doc(setting.id));
      assert(batch.isAddedDocument == true);
      assert(batch.addedDocumentCount == 1);
      await batch.commit();

      final _setting = await documentAccessor.load<Setting>(
          Setting(id: setting.id, collectionRef: userA.setting.ref));
      assertCreateDocument(setting, _setting!);
      assert(setting.isEnable == _setting.isEnable);
    }

    // update
    {
      setting.isEnable = false;
      final batch = Batch()
        ..update(setting, reference: userA.setting.ref.doc(setting.id));
      await batch.commit();

      final _setting = await documentAccessor.load<Setting>(
          Setting(id: setting.id, collectionRef: userA.setting.ref));
      assertCreateDocument(setting, _setting!);
      assert(setting.isEnable == _setting.isEnable);
    }

    // delete
    {
      final batch = Batch()
        ..delete(setting, reference: userA.setting.ref.doc(setting.id));
      await batch.commit();

      final _setting = await documentAccessor.load<Setting>(
          Setting(id: setting.id, collectionRef: userA.setting.ref));
      assert(_setting == null);
    }
    print('batchCollectionReference done');
  }

  Future getAndUpdate() async {
    print('--- getAndUpdate ---');
    final user = User()..name = 'hoge';
    await documentAccessor.save(user);

    user.name = 'hogehoge';
    await documentAccessor.update(user);

    final _user = await documentAccessor.load<User>(User(id: user.id));
    assertCreateDocument(user, _user!);
    assert(user.name == _user.name);
  }

  Future getCollection() async {
    print('--- getCollection ---');
    final path = Document.path<User>();
    print('path ${path}');
    final snapshot = await firestoreInstance.collection(path).limit(5).get();
    print('from Snapshot');
    final listA = snapshot.docs.map((item) => User(snapshot: item)).toList();

    assert(listA.isNotEmpty);
    // ignore: avoid_function_literals_in_foreach_calls
    listA.forEach((item) {
      assertCollection(item, path);
    });

    print('from values');
    final listB = snapshot.docs
        .map((item) => User(id: item.id, values: item.data()))
        .toList();
    assert(listB.isNotEmpty);
    // ignore: avoid_function_literals_in_foreach_calls
    listB.forEach((item) {
      assertCollection(item, path);
    });
  }

  Future subCollection() async {
    print('--- subCollection ---');
    final ranking = Ranking(id: '20201225')..title = 'userRanking';
    final countA = Count(id: '0', collectionRef: ranking.count!.ref)
      ..userId = '0'
      ..count = 10;
    final countB = Count(id: '1', collectionRef: ranking.count!.ref)
      ..userId = '1'
      ..count = 100;
    final batch = Batch()..save(ranking)..save(countA)..save(countB);
    await batch.commit();

    final snapshot = await firestoreInstance
        .collection(ranking.count!.ref.path)
        .limit(2)
        .get();
    print('from Snapshot');
    final listA = snapshot.docs.map((item) => Count(snapshot: item)).toList();
    assert(listA.isNotEmpty);
    listA.forEach((item) {
      assertCollection(item, ranking.count!.ref.path);
    });

    print('from values');
    final listB = snapshot.docs
        .map((item) => Count(
            id: item.id,
            values: item.data(),
            collectionRef: ranking.count!.ref))
        .toList();
    assert(listB.isNotEmpty);
    listB.forEach((item) {
      assertCollection(item, ranking.count!.ref.path);
    });

    /// documentAccessor
    final _ranking =
        await documentAccessor.load<Ranking>(Ranking(id: '20201225'));
    assertCreateDocument(ranking, _ranking!);

    final _countA = await documentAccessor
        .load<Count>(Count(id: '0', collectionRef: ranking.count!.ref));
    final _countB = await documentAccessor
        .load<Count>(Count(id: '1', collectionRef: ranking.count!.ref));
    assertCreateDocument(countA, _countA!);
    assertCreateDocument(countB, _countB!);
  }

  Future saveStorage() async {
    print('--- saveStorage ---');
    final post = Post();
    final storage = Storage();
    final file =
        await ImageHelper.getImageFileFromAssets('assets', 'sample.jpg');

    // fetch for uploading status
    storage.fetch();
    storage.uploader.listen((data) {
      // confirm status
      print('total: ${data.totalBytes} transferred: ${data.bytesTransferred}');
    });

    // save file metadata into firestore
    final path = '${post.documentPath}/${PostKey.file.value}';
    post.file =
        await storage.save(path, file, mimeType: mimeTypePng, metadata: {
      'newPost': 'true'
    }, additionalData: <String, dynamic>{
      'key0': 'key',
      'key1': 10,
      'key2': 0.123,
      'key3': true,
    });
    await documentAccessor.save(post);
    post.log();

    print('  ----get');
    final _post = await documentAccessor.load<Post>(Post(id: post.id));
    assertCreateDocument(post, _post!);
    assertStorageFile(post.file!, _post.file!);
    _post.log();

    print('  ----getDownloadUrl');
    {
      final downloadUrl = await storage.getDownloadUrl(post.file!);
      print('getDownloadUrl $downloadUrl');
      assert(downloadUrl == post.file!.url);
    }
    {
      final downloadUrl = await storage.getDownloadUrlWithPath(post.file!.path);
      print('getDownloadUrlWithPath ${post.file!.path}, $downloadUrl');
      assert(downloadUrl == post.file!.url);
    }
    assert(storage.ref(post.file!).fullPath == post.file!.path);

    print('  ----getData');
    {
      final data = await storage.getData(post.file!);
      print('getData $data');
      assert(data != null);
    }
    {
      final data = await storage.getDataWithPath(post.file!.path);
      print('getDataWithPath $data');
      assert(data != null);
    }
    // dispose for uploading status
    storage.dispose();
  }

  Future deleteStorage() async {
    print('--- deleteStorage ---');
    final post = Post();
    final storage = Storage();
    final file =
        await ImageHelper.getImageFileFromAssets('assets', 'sample.jpg');
    final path = '${post.documentPath}/${PostKey.file.value}';
    post.file = await storage.save(path, file, mimeType: mimeTypePng);
    await documentAccessor.save(post);

    final _post = await documentAccessor.load<Post>(post);
    assertCreateDocument(post, _post!);
    assertStorageFile(post.file!, _post.file!);

    await storage.delete(post.file!);
    await documentAccessor.update(post);

    print('  ----get');
    final hoge = await documentAccessor.load<Post>(Post(id: post.id));
    assert(post.id == hoge!.id);
    print(hoge!.file);
    assert(hoge.file == null);
  }

  Future saveStorageAndDoc() async {
    print('--- saveStorageAndDoc ---');
    final post = Post();

    final storage = Storage();
    final file =
        await ImageHelper.getImageFileFromAssets('assets', 'sample.jpg');

    // fetch for uploading status
    storage.fetch();
    storage.uploader.listen((data) {
      // confirm status
      print('total: ${data.totalBytes} transferred: ${data.bytesTransferred}');
    });

    // save file metadata into firestore
    post.file = await storage.saveWithDoc(
      post.reference,
      PostKey.file.value,
      file,
      mimeType: mimeTypePng,
      metadata: {'newPost': 'true'},
      additionalData: <String, dynamic>{
        'key0': 'key',
        'key1': 10,
        'key2': 0.123,
        'key3': true,
      },
    );
    print('  ----get');
    final _post = await documentAccessor.load<Post>(Post(id: post.id));
    _post!.log();

    assertCreateDocument(post, _post);
    assertStorageFile(post.file!, _post.file!);

    // dispose for uploading status
    storage.dispose();
  }

  Future deleteStorageAndDoc() async {
    print('--- deleteStorageAndDoc ---');
    final post = Post();
    final id = post.id;

    final storage = Storage();
    final file =
        await ImageHelper.getImageFileFromAssets('assets', 'sample.jpg');
    await storage.saveWithDoc(
      post.reference,
      PostKey.file.value,
      file,
      mimeType: mimeTypePng,
      metadata: {'newPost': 'true'},
      additionalData: <String, dynamic>{
        'key0': 'key',
        'key1': 10,
        'key2': 0.123,
        'key3': true,
      },
    );

    final _post = await documentAccessor.load<Post>(Post(id: id));
    await storage.deleteWithDoc(
        _post!.reference, PostKey.file.value, _post.file!,
        isNotNull: false);

    final hoge = await documentAccessor.load<Post>(Post(id: post.id));
    assert(post.id == hoge!.id);
    assert(hoge!.file == null);
  }

  Future saveAndDeleteStorageDocWithDocumentAccessor() async {
    print('--- saveAndDeleteStorageDocWithDocumentAccessor ---');
    final post = Post()..files = [];
    await documentAccessor.save(post);

    print('  ----get');
    final _post = await documentAccessor.load<Post>(Post(id: post.id));
    _post!.log();

    assertCreateDocument(post, _post);
    assert(_post.files!.isEmpty);
    assert(post.files!.length == _post.files!.length);
  }

  Future distributedCounter() async {
    print('--- distributedCounter ---');

    /// Create
    final score = Score()..userId = '0001';
    await documentAccessor.save(score);
    score.log();
    final distributedCounter = DistributedCounter();
    await distributedCounter.create(score.counter);

    /// Increment
    for (var i = 0; i < 10; i++) {
      await distributedCounter.increment(score.counter, count: 1);
    }

    /// Load
    final count = await distributedCounter.load(score.counter);
    print('count $count ${score.counter.count}');
    assert(count == 10);
    assert(score.counter.count == 10);
  }

  Future transactionSave() async {
    print('--- transactionSave ---');
    await RunTransaction.scope<void>((transaction) async {
      final user = User()..name = 'transaction';
      transaction.set(user.reference, user.toData());
      user.log();
    });
  }

  Future transactionUpdate() async {
    print('--- transactionUpdate ---');
    final hoge = User()..name = 'hoge';
    await documentAccessor.save(hoge);
    hoge.log();

    await RunTransaction.scope<void>((transaction) async {
      final user = User(id: hoge.id)..name = 'transactionAA';
      transaction.update(user.reference, user.toData());
    });
  }

  Future transactionDelete() async {
    print('--- transactionDelete ---');
    final hoge = User()..name = 'hoge';
    await documentAccessor.save(hoge);
    hoge.log();

    await RunTransaction.scope<void>((transaction) async {
      transaction.delete(User(id: hoge.id).reference);
    });
  }

  Future saveMap() async {
    print('--- saveMap ---');
    final sample1 = MapSample()
      ..strMap = {
        'userId1': 'tanaka',
        'userId2': 'hanako',
        'userId3': 'shohei',
      }
      ..intMap = {
        'userId1': 0,
        'userId2': 1,
        'userId3': 2,
      }
      ..doubleMap = {
        'userId1': 1.02,
        'userId2': 0.14,
        'userId3': 0.89,
      }
      ..boolMap = {
        'userId1': true,
        'userId2': true,
        'userId3': true,
      }
      ..listStrMap = [
        {
          'userId1': 'tanaka',
          'userId2': 'hanako',
        },
        {
          'adminId1': 'shohei',
          'adminId2': 'tanigawa',
        },
        {
          'managerId1': 'ueno',
          'managerId2': 'yoshikawa',
        },
      ];
    await documentAccessor.save(sample1);
    sample1.log();

    {
      print('  ----get');
      final _sample1 =
          await documentAccessor.load<MapSample>(MapSample(id: sample1.id));
      assertCreateDocument(sample1, _sample1!);
      assert(sample1.strMap!['userId'] == _sample1.strMap!['userId']);
      assert(sample1.intMap!['userId'] == _sample1.intMap!['userId']);
      assert(sample1.doubleMap!['userId'] == _sample1.doubleMap!['userId']);
      assert(sample1.boolMap!['userId'] == _sample1.boolMap!['userId']);
      assert(sample1.listStrMap!.isNotEmpty);
      assert(sample1.listStrMap!.first['userId'] ==
          _sample1.listStrMap!.first['userId']);
      _sample1.log();
    }

    sample1
      ..strMap = {}
      ..intMap = {}
      ..doubleMap = {}
      ..boolMap = {}
      ..listStrMap = [];
    await documentAccessor.save(sample1);

    {
      print('  ----get delete');
      final _sample1 =
          await documentAccessor.load<MapSample>(MapSample(id: sample1.id));
      assertCreateDocument(sample1, _sample1!);
      assert(!_sample1.strMap!.containsKey('userId'));
      assert(!_sample1.intMap!.containsKey('userId'));
      assert(!_sample1.doubleMap!.containsKey('userId'));
      assert(!_sample1.boolMap!.containsKey('userId'));
      assert(_sample1.listStrMap!.isEmpty);
      _sample1.log();
    }
  }

  Future saveList() async {
    print('--- saveList ---');
    final sample1 = ListSample()
      ..strList = [
        'userId1',
        'userId2',
        'userId3',
      ]
      ..intList = [
        0,
        1,
        2,
      ]
      ..doubleList = [
        0.0,
        0.1,
        0.2,
      ]
      ..boolList = [
        true,
        false,
        true,
      ];
    sample1.filesA = [
      StorageFile(
          name: 'name1',
          path: '${sample1.documentPath}/name1',
          url: 'https://sample1.jpg',
          mimeType: mimeTypePng),
      StorageFile(
          name: 'name2',
          path: '${sample1.documentPath}/name2',
          url: 'https://sample2.jpg',
          mimeType: mimeTypePng),
      StorageFile(
          name: 'name3',
          path: '${sample1.documentPath}/name3',
          url: 'https://sample3.jpg',
          mimeType: mimeTypePng),
    ];
    sample1.filesB = [
      StorageFile(
          name: 'name1',
          path: '${sample1.documentPath}/name4',
          url: 'https://sample1.jpg',
          mimeType: mimeTypePng),
      StorageFile(
          name: 'name2',
          path: '${sample1.documentPath}/name2',
          url: 'https://sample2.jpg',
          mimeType: mimeTypePng),
      StorageFile(
          name: 'name3',
          path: '${sample1.documentPath}/name3',
          url: 'https://sample3.jpg',
          mimeType: mimeTypePng),
    ];
    await documentAccessor.save(sample1);
    sample1.log();

    {
      print('  ----get');
      final _sample1 =
          await documentAccessor.load<ListSample>(ListSample(id: sample1.id));
      assertCreateDocument(sample1, _sample1!);
      assert(sample1.strList!.length == _sample1.strList!.length);
      assert(sample1.intList!.length == _sample1.intList!.length);
      assert(sample1.doubleList!.length == _sample1.doubleList!.length);
      assert(sample1.boolList!.length == _sample1.boolList!.length);
      assert(sample1.filesA!.length == _sample1.filesA!.length);
      assert(sample1.filesB!.length == _sample1.filesB!.length);

      assert(sample1.strList!.first == _sample1.strList!.first);
      assert(sample1.intList!.first == _sample1.intList!.first);
      assert(sample1.doubleList!.first == _sample1.doubleList!.first);
      assert(sample1.boolList!.first == _sample1.boolList!.first);
      for (var i = 0; i < sample1.filesA!.length; i++) {
        assertStorageFile(sample1.filesA![i], _sample1.filesA![i]);
      }
      for (var i = 0; i < sample1.filesB!.length; i++) {
        assertStorageFile(sample1.filesB![i], _sample1.filesB![i]);
      }
      _sample1.log();
    }

    sample1
      ..strList = []
      ..intList = []
      ..doubleList = []
      ..boolList = [];

    // ignore: avoid_function_literals_in_foreach_calls
    sample1.filesA!.forEach((d) => d.deleted());
    sample1.filesB = [];
    await documentAccessor.save(sample1);

    {
      print('  ----get delete');
      final _sample1 =
          await documentAccessor.load<ListSample>(ListSample(id: sample1.id));
      _sample1!.log();
      assert(sample1.strList!.length == _sample1.strList!.length);
      assert(sample1.intList!.length == _sample1.intList!.length);
      assert(sample1.doubleList!.length == _sample1.doubleList!.length);
      assert(sample1.boolList!.length == _sample1.boolList!.length);
      assert(sample1.filesA!.isNotEmpty);
      assert(sample1.filesB!.isEmpty);
    }

    {
      final sample1 = ListSample();
      sample1.filesA = [
        StorageFile(
            name: 'name1',
            path: '${sample1.documentPath}/name1',
            url: 'https://sample1.jpg',
            mimeType: mimeTypePng),
        StorageFile(
            name: 'name2',
            path: '${sample1.documentPath}/name2',
            url: 'https://sample2.jpg',
            mimeType: mimeTypePng),
        StorageFile(
            name: 'name3',
            path: '${sample1.documentPath}/name3',
            url: 'https://sample3.jpg',
            mimeType: mimeTypePng),
      ];
      sample1.filesB = [
        StorageFile(
            name: 'name1',
            path: '${sample1.documentPath}/name1',
            url: 'https://sample1.jpg',
            mimeType: mimeTypePng),
        StorageFile(
            name: 'name2',
            path: '${sample1.documentPath}/name2',
            url: 'https://sample2.jpg',
            mimeType: mimeTypePng),
        StorageFile(
            name: 'name3',
            path: '${sample1.documentPath}/name3',
            url: 'https://sample3.jpg',
            mimeType: mimeTypePng),
      ];
      await documentAccessor.save(sample1);
      {
        final _sample1 =
            await documentAccessor.load<ListSample>(ListSample(id: sample1.id));
        _sample1!.log();
        assert(sample1.filesA!.length == _sample1.filesA!.length);
        assert(sample1.filesB!.length == _sample1.filesB!.length);
      }
      {
        sample1
          ..filesA = null
          ..filesB = null;
        await documentAccessor.save(sample1);
        final _sample1 =
            await documentAccessor.load<ListSample>(ListSample(id: sample1.id));
        _sample1!.log();
        assert(sample1.filesA == _sample1.filesA);
        assert(_sample1.filesB!.isNotEmpty);
      }
    }
  }

  Future checkModelSample() async {
    print('--- ModelSample ---');
    final item = ModelSample();
    await documentAccessor.save(item);
    item.log();

    final storage = Storage();
    final file =
        await ImageHelper.getImageFileFromAssets('assets', 'sample.jpg');

    // fetch for uploading status
    storage.fetch();
    storage.uploader.listen((data) {
      // confirm status
      print('total: ${data.totalBytes} transferred: ${data.bytesTransferred}');
    });

    // save file metadata into firestore
    final path = '${item.documentPath}/${ModelSampleKey.file.value}';
    item.file = await storage
        .save(path, file, mimeType: mimeTypePng, metadata: {'newPost': 'true'});
    await documentAccessor.save(item);
    item.log();

    {
      print('  ----get');
      final _item =
          await documentAccessor.load<ModelSample>(ModelSample(id: item.id));
      _item!.log();
    }

    {
      print('  ----get delete file');
      await storage.deleteWithPath(item.file!.path);
      await documentAccessor.update(item);
      final _item =
          await documentAccessor.load<ModelSample>(ModelSample(id: item.id));
      _item!.log();
    }

    // dispose for uploading status
    storage.dispose();
  }

  Future listenerSample() async {
    print('--- listenerSample ---');

    /// Collection
    final path = Document.path<User>();
    final query = firestoreInstance.collection(path).limit(20);
    final collectionDispose = query.snapshots().listen((querySnapshot) {
      print('--- Listen of collection documents ---');
      for (var change in querySnapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          print('added ${change.doc.id}');
        }
        if (change.type == DocumentChangeType.modified) {
          print('modified ${change.doc.id}');
        }
        if (change.type == DocumentChangeType.removed) {
          print('removed ${change.doc.id}');
        }
      }
      final _ = querySnapshot.docs.map((item) => User(snapshot: item)).toList()
        ..forEach((item) => print('${item.id}, ${item.name}'));
    });

    /// Document
    final user = User(id: '0')..name = 'hoge';

    final dispose = user.reference.snapshots().listen((snap) {
      print('--- Listen of document ---');
      print('snap: ${snap.id} ${snap.data}');
      final user = User(snapshot: snap);
      print('${user.id}, ${user.name}');
    });

    print('--- save ---');
    await documentAccessor.save(user);

    print('--- update ---');
    user.name = 'fuga';
    await documentAccessor.update(user);

    print('--- delete ---');
    await documentAccessor.delete(user);

    await dispose.cancel();
    await collectionDispose.cancel();
  }

  Future model() async {
    print('--- model ---');
    final owner = Owner()
      ..name = 'owner'
      ..address = Address(
        postCode: '0000',
        country: 'japan',
      )
      ..medals = [
        Medal(
          name: 'gold',
        ),
        Medal(
          name: 'silver',
        ),
        Medal(
          name: 'bronze',
        ),
      ];

    print('--- save ---');
    print('${owner.id}');
    await documentAccessor.save(owner);

    print('--- load ---');
    final _owner = await documentAccessor.load<Owner>(Owner(id: owner.id));
    print('id: ${_owner!.id}, name: ${_owner.name}');
    print(
        'address: ${_owner.id} ${_owner.address!.postCode} ${_owner.address!.country}');
    print('medals: ${_owner.medals!.map((d) => d.name)}');

    assertCreateDocument(owner, _owner);
    assert(owner.name == _owner.name);
    assert(owner.address!.postCode == _owner.address!.postCode);
    assert(owner.address!.country == _owner.address!.country);
    assert(owner.medals!.length == _owner.medals!.length);
    assert(owner.medals![0].name == _owner.medals![0].name);
    assert(owner.medals![1].name == _owner.medals![1].name);
    assert(owner.medals![2].name == _owner.medals![2].name);
  }

  Future incrementTest1() async {
    print('--- incrementTest 1 ---');
    {
      final card1 = CreditCard()
        ..point.incrementValue = 1
        ..score.incrementValue = 1.25;
      await documentAccessor.save(card1);
      card1.log();

      final _card = await documentAccessor.load<CreditCard>(card1);
      _card!.log();

      print('--- incrementTest minus ---');
      {
        card1
          ..point.incrementValue = -1
          ..score.incrementValue = -1.00;
        await documentAccessor.update(card1);
        card1.log();

        final _card = await documentAccessor.load<CreditCard>(card1);
        _card!.log();
      }

      print('--- incrementTest null check ---');
      {
        await documentAccessor.update(card1);
        card1.log();

        final _card = await documentAccessor.load<CreditCard>(card1);
        _card!.log();
      }

      print('--- incrementTest clear ---');
      {
        card1
          ..point.isClearValue = true
          ..score.isClearValue = true;
        await documentAccessor.update(card1);
        card1.log();

        final _card = await documentAccessor.load<CreditCard>(card1);
        _card!.log();
      }

      {
        card1
          ..point.incrementValue = 20
          ..score.incrementValue = 1.2345;
        await documentAccessor.update(card1);
        card1.log();

        final _card = await documentAccessor.load<CreditCard>(card1);
        _card!.log();
      }
    }
  }

  Future incrementTest2() async {
    print('--- incrementTest 2 ---');
    {
      final card1 = CreditCard();
      final batch = Batch()..save(card1);
      await batch.commit();
      final _card = await documentAccessor.load<CreditCard>(card1);
      _card!.log();

      print('--- increment int ---');
      {
        print('--- increment +10 ---');
        card1.point = await documentAccessor.increment<int>(
          card1.point,
          card1.reference,
          fieldName: CreditCardKey.point.value,
          value: 10,
        );
        print('point ${card1.point.value}');
        final _card = await documentAccessor.load<CreditCard>(card1);
        print('point load ${_card!.point.value}');
      }

      {
        print('--- increment +100 ---');
        card1.point = await documentAccessor.increment<int>(
          card1.point,
          card1.reference,
          fieldName: CreditCardKey.point.value,
          value: 100,
        );
        print('point ${card1.point.value}');
        final _card = await documentAccessor.load<CreditCard>(card1);
        print('point load ${_card!.point.value}');
      }

      {
        print('--- increment -100 ---');
        card1.point = await documentAccessor.increment<int>(
          card1.point,
          card1.reference,
          fieldName: CreditCardKey.point.value,
          value: -100,
        );
        print('point ${card1.point.value}');
        final _card = await documentAccessor.load<CreditCard>(card1);
        print('point load ${_card!.point.value}');
      }

      print('--- increment double ---');
      card1.log();
      {
        print('--- increment +0.5 ---');
        card1.score = await documentAccessor.increment<double>(
          card1.score,
          card1.reference,
          fieldName: CreditCardKey.score.value,
          value: 0.5,
        );
        print('score ${card1.score.value}');
        final _card = await documentAccessor.load<CreditCard>(card1);
        print('score load ${_card!.score.value}');
      }

      {
        print('--- increment +10.5 ---');
        card1.score = await documentAccessor.increment<double>(
          card1.score,
          card1.reference,
          fieldName: CreditCardKey.score.value,
          value: 10.5,
        );
        print('score ${card1.score.value}');
        final _card = await documentAccessor.load<CreditCard>(card1);
        print('score load ${_card!.score.value}');
      }

      {
        print('--- increment -2.5 ---');
        card1.score = await documentAccessor.increment<double>(
          card1.score,
          card1.reference,
          fieldName: CreditCardKey.score.value,
          value: -2.5,
        );
        print('score ${card1.score.value}');
        final _card = await documentAccessor.load<CreditCard>(card1);
        print('score load ${_card!.score.value}');
        _card.log();
      }

      {
        print('--- increment clear ---');
        card1
          ..point = await documentAccessor.increment<int>(
            card1.point,
            card1.reference,
            fieldName: CreditCardKey.score.value,
            isClear: true,
          )
          ..score = await documentAccessor.increment<double>(
            card1.score,
            card1.reference,
            fieldName: CreditCardKey.score.value,
            isClear: true,
          );
        print('point ${card1.point.value}, score: ${card1.score.value}');
        final _card = await documentAccessor.load<CreditCard>(card1);
        print('load point: ${_card!.point.value}, score: ${_card.score.value}');
        _card.log();
      }
    }
  }

  Future incrementTest3() async {
    print('--- incrementTest 3 ---');
    final data = AppUser()
      ..name = 'aaa'
      ..newMessagesCount.incrementValue = 1;
    await documentAccessor.save(data);

    final result = await documentAccessor.load<AppUser>(data);
    assert(result != null, 'result is null');

    final ref = AppUser().collectionRef;
    final collectionPaging = CollectionPaging<AppUser>(
      query: ref.where(AppUserKey.newMessagesCount.value, isEqualTo: 1),
      limit: 5,
      decode: (snap) => AppUser(snapshot: snap),
    );
    final list = await collectionPaging.load();
    assert(list.isNotEmpty, 'list is empty');
  }

  Future valueZeroTest() async {
    print('--- valueZeroTest ---');
    final point = Point()
      ..pointInt = 0
      ..pointDouble = 0.0;

    print('--- save ---');
    print('${point.id}');
    await documentAccessor.save(point);

    print('--- load ---');
    final _point = await documentAccessor.load<Point>(point);
    _point!.log();
    assertCreateDocument(point, _point);
    assert(point.pointInt == _point.pointInt);
    assert(point.pointDouble == _point.pointDouble);
  }

  Future extendCRUD() async {
    print('--- extendCRUD ---');

    /// Save
    final user = public.User()..name = 'hoge';
    await documentAccessor.save(user);

    /// Load
    final _user =
        await documentAccessor.load<public.User>(public.User(id: user.id));
    assertCreateDocument(user, _user!);
    print(user.toData());

    assert(user.domain == _user.domain);
    assert(user.name == _user.name);

    /// Update
    _user.name = 'aiueo';
    await documentAccessor.update(_user);

    final _user1 =
        await documentAccessor.load<public.User>(public.User(id: _user.id));
    assertCreateDocument(_user, _user1!);
    assert(_user.domain == _user1.domain);
    assert(_user.name == _user1.name);

    /// Delete
    await documentAccessor.delete(_user);
    final _user2 =
        await documentAccessor.load<public.User>(public.User(id: _user.id));
    assertDeleteDocument(_user2);
    print('--- extendCRUD finish ---');
  }

  Future testReferencePath() async {
    print('--- testReferencePath ---');
    final shop = Shop();
    shop
      ..cart = Cart(
        ref: shop.documentPath,
        collectionRef: shop.collectionPath,
      )
      ..carts = [
        Cart(
          ref: shop.documentPath,
        ),
        Cart(
          ref: shop.documentPath,
        ),
      ];

    print('--- save ---');
    print('${shop.id}');
    await documentAccessor.save(shop);

    print('--- load from document ---');
    {
      final _shop =
          await documentAccessor.load<Shop>(Shop(documentPath: shop.cart!.ref));
      print('cart: ${_shop!.cart!.ref}  ${_shop.cart!.collectionRef}');
      print('carts: ${_shop.carts!.map((d) => '${d.ref} ${d.collectionRef}')}');
      assertCreateDocument(shop, _shop);
      assert(shop.documentPath == _shop.cart?.ref);
      assert(shop.collectionPath == _shop.cart?.collectionRef);
      assert(shop.cart?.ref == _shop.cart?.ref);
      assert(shop.cart?.collectionRef == _shop.cart?.collectionRef);
      assert(shop.carts![0].ref == _shop.carts![0].ref);
      assert(shop.carts![1].ref == _shop.carts![1].ref);
    }

    print('--- load from collectionRef ---');
    {
      final _shop = await documentAccessor.load<Shop>(Shop(
        id: shop.id,
        collectionPath: shop.cart!.collectionRef,
      ));
      print('cart: ${_shop!.cart!.ref}  ${_shop.cart!.collectionRef}');
      print('carts: ${_shop.carts!.map((d) => '${d.ref} ${d.collectionRef}')}');
      assertCreateDocument(shop, _shop);
      assert(shop.documentPath == _shop.cart?.ref);
      assert(shop.collectionPath == _shop.cart?.collectionRef);
      assert(shop.cart?.ref == _shop.cart?.ref);
      assert(shop.cart?.collectionRef == _shop.cart?.collectionRef);
      assert(shop.carts![0].ref == _shop.carts![0].ref);
      assert(shop.carts![1].ref == _shop.carts![1].ref);
    }

    print('--- delete ---');
    await documentAccessor.delete(Shop(documentPath: shop.cart!.ref));
    {
      final _shop = await documentAccessor.load<Shop>(Shop(id: shop.id));
      assertDeleteDocument(_shop);
    }
  }

  Future testCustomFieldValueKey() async {
    final item = Item()..name = 'item';
    // document
    await documentAccessor.save(item);
    item.log();
    {
      final _item = await documentAccessor.load<Item>(item);
      _item!.log();
    }
    await documentAccessor.saveRaw(
        <String, dynamic>{ItemKey.name.value: 'hogehoge'}, item.reference,
        isTimestamp: true,
        createdFieldValueKey: item.createdFieldValueKey,
        updatedFieldValueKey: item.updatedFieldValueKey);
    {
      final _item = await documentAccessor.load<Item>(item);
      _item!.log();
    }

    // batch
    final itemA = Item()..name = 'hoge';
    final itemB = Item()..name = 'fuga';
    {
      final batch = Batch()
        ..save(itemA)
        ..saveRaw(<String, dynamic>{'name': 'itemitem'}, itemB.reference,
            isTimestamp: true,
            createdFieldValueKey: itemB.createdFieldValueKey,
            updatedFieldValueKey: itemB.updatedFieldValueKey);
      await batch.commit();
    }
    {
      final _itemA = await documentAccessor.load<Item>(itemA);
      _itemA!.log();
      final _itemB = await documentAccessor.load<Item>(itemB);
      _itemB!.log();
    }
    {
      itemA.name = 'hogehoge';
      final batch = Batch()
        ..update(itemA)
        ..updateRaw(<String, dynamic>{'name': 'fugafuga'}, itemB.reference,
            isTimestamp: true,
            updatedFieldValueKey: itemB.updatedFieldValueKey);
      await batch.commit();
    }
    {
      final _itemA = await documentAccessor.load<Item>(itemA);
      _itemA!.log();
      final _itemB = await documentAccessor.load<Item>(itemB);
      _itemB!.log();
    }
  }

  Future testErrorCheck() async {
    print('--- testCollectionPath ---');
//    try {
//      final item1 = Shop(id: 'dummy', documentPath: 'dummy');
//    } on Exception catch(e) {
//      print('e $e');
////      assert(e != null);
//    }
//    try {
//      final item2 = Shop(documentPath: 'dummy', collectionPath: 'dummy');
//    } on Exception catch(e) {
//      print('e $e');
////      assert(e != null);
//    }
//    try {
//      final item3 = Shop(collectionPath: 'dummy', collectionRef: Shop().collectionRef);
//    } on Exception catch(e) {
//      print('e $e');
////      assert(e != null);
//    }
  }

  Future<List<User>> loadUsers() async {
    final documents = await _collectionPaging.load();
    for (var doc in documents) {
      print('${doc.id} ${doc.toData()}');
    }
    return documents;
  }

  Future<List<User>> loadMoreUsers() async {
    final documents = await _collectionPaging.loadMore();
    for (var doc in documents) {
      print('${doc.id} ${doc.toData()}');
    }
    return documents;
  }
}
