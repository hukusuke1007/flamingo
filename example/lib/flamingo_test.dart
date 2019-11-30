import 'package:flamingo/flamingo.dart';
import 'package:flamingo/transaction.dart' as flamingo;
import 'package:flamingo_example/model/count.dart';
import 'package:flamingo_example/model/post.dart';
import 'package:flamingo_example/model/score.dart';
import 'package:flamingo_example/model/map_sample.dart';
import 'package:flamingo_example/model/list_sample.dart';
import 'package:flamingo_example/model/model_sample.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/address.dart';
import 'model/medal.dart';
import 'model/owner.dart';
import 'model/ranking.dart';
import 'model/user.dart';

class FlamingoTest {
  DocumentAccessor documentAccessor = DocumentAccessor();

  Future all() async {
    await save();
    await update();
    await delete();
    await batchSave();
    await batchUpdateDelete();
    await getAndUpdate();
    await getCollection();
    await subCollection();
    await saveStorage();
    await deleteStorage();
    await distributedCounter();
    await transactionSave();
    await transactionUpdate();
    await transactionDelete();
    await saveMap();
    await saveList();
    await checkModelSample();
    await listenerSample();
    await model();
  }

  Future save() async {
    print('--- save ---');
    final user = User()
        ..name = 'hoge';
    await documentAccessor.save(user);
    user.log();

    final _user = await documentAccessor.load<User>(User(id: user.id));
    _user.log();
  }

  Future update() async {
    print('--- update ---');
    final user = User()
      ..name = 'hoge';
    await documentAccessor.save(user);
    user.log();

    final updateUser = User(id: user.id)
      ..name = 'fuga';
    await documentAccessor.update(updateUser);

    final _user = await documentAccessor.load<User>(User(id: user.id));
    _user.log();
  }

  Future delete() async {
    print('--- delete ---');
    final user = User()
      ..name = 'hoge';
    await documentAccessor.save(user);
    user.log();

    await documentAccessor.delete(User(id: user.id));
    final _user = await documentAccessor.load<User>(User(id: user.id));
    print(_user);
  }

  Future batchSave() async {
    print('--- batchSave ---');
    final userA = User()
      ..name = 'hoge';
    final userB = User()
      ..name = 'fuga';
    final batch = Batch()
      ..save(userA)
      ..save(userB);
    await batch.commit();
    userA.log();
    userB.log();
  }

  Future batchUpdateDelete() async {
    print('--- batchUpdateDelete ---');
    final userA = User()
      ..name = 'hoge';
    final userB = User()
      ..name = 'fuga';
    final batch = Batch()
      ..save(userA)
      ..save(userB);
    await batch.commit();
    userA.log();
    userB.log();
    await _batchUpdateDelete(userA, userB);
  }

  Future _batchUpdateDelete(User userA, User userB) async {
    final hoge = await documentAccessor.load<User>(User(id: userA.id));
    hoge.name = 'hogehoge';
    final batch = Batch()
      ..update(hoge)
      ..delete(userB);
    await batch.commit();

    final _user = await documentAccessor.load<User>(User(id: userB.id));
    hoge.log();
    print(_user);
  }

  Future getAndUpdate() async {
    print('--- getAndUpdate ---');
    final user = User()
      ..name = 'hoge';
    await documentAccessor.save(user);
    user.log();

    final hoge = await documentAccessor.load<User>(User(id: user.id));
    hoge.name = 'hogehoge';
    await documentAccessor.update(hoge);
    hoge.log();
  }

  Future getCollection() async {
    print('--- getCollection ---');
    print('path ${Document.path<User>()}');
    final snapshot = await firestoreInstance().collection(Document.path<User>()).limit(5).getDocuments();
    print('from Snapshot');
    final listA = snapshot.documents.map((item) => User(snapshot: item)).toList()
      ..forEach((item) => item.log());

    print('from values');
    final listB = snapshot.documents.map((item) => User(id: item.documentID, values: item.data)).toList()
      ..forEach((item) => item.log());
  }

  Future subCollection() async {
    print('--- subCollection ---');
    final ranking = Ranking(id: '20201007')
      ..title = 'userRanking';
    final countA = Count(collectionRef: ranking.count.ref)
      ..userId = '0'
      ..count = 10;
    final countB = Count(collectionRef: ranking.count.ref)
      ..userId = '1'
      ..count = 100;
    final batch = Batch()
      ..save(ranking)
      ..save(countA)
      ..save(countB);
    await batch.commit();

    final snapshot = await firestoreInstance().collection(ranking.count.ref.path).limit(5).getDocuments();
    print('from Snapshot');
    final listA = snapshot.documents.map((item) => Count(snapshot: item)).toList()
      ..forEach((item) => item.log());

    print('from values');
    final listB = snapshot.documents.map((item) => Count(id: item.documentID, values: item.data)).toList()
      ..forEach((item) => item.log());
  }

  Future saveStorage() async {
    print('--- saveStorage ---');
    final post = Post();
    final storage = Storage();
    final file = await Helper.getImageFileFromAssets('assets', 'sample.jpg');

    // fetch for uploading status
    storage.fetch();
    storage.uploader.stream.listen((data){
      // confirm status
      print('total: ${data.snapshot.totalByteCount} transferred: ${data.snapshot.bytesTransferred}');
    });

    // save file metadata into firestore
    final path = '${post.documentPath}/${post.folderName}';
    post.file = await storage.save(
      path,
      file,
      mimeType: mimeTypePng,
      metadata: {
        'newPost': 'true'
      }
    );
    post.file.additionalData = <String, dynamic>{
      'key0': 'key',
      'key1': 10,
      'key2': 0.123,
      'key3': true,
    };
    await documentAccessor.save(post);
    post.log();

    print('  ----get');
    final hoge = await documentAccessor.load<Post>(Post(id: post.id));
    hoge.log();

    // dispose for uploading status
    storage.dispose();
  }

  Future deleteStorage() async {
    print('--- deleteStorage ---');
    final post = Post();
    final storage = Storage();
    final file = await Helper.getImageFileFromAssets('assets', 'sample.jpg');
    final path = '${post.documentPath}/${post.folderName}';
    post.file = await storage.save(path, file, mimeType: mimeTypePng);
    await documentAccessor.save(post);
    post.log();

    await storage.delete(path, post.file);
    await documentAccessor.update(post);

    print('  ----get');
    final hoge = await documentAccessor.load<Post>(Post(id: post.id));
    hoge.log();
  }

  Future distributedCounter() async {
    print('--- distributedCounter ---');

    /// Create
    final score = Score()
      ..userId = '0001';
    await documentAccessor.save(score);
    score.log();
    final distributedCounter = DistributedCounter();
    await distributedCounter.create(score.value);

    /// Increment
    for (var i = 0; i < 10; i++) {
      await distributedCounter.increment(score.value, count: 1);
    }

    /// Load
    final count = await distributedCounter.load(score.value);
    print('count $count ${score.value.count}');
  }

  Future transactionSave() async {
    print('--- transactionSave ---');
    flamingo.Transaction.run((transaction) async {
      final user = User()
        ..name = 'transaction';
      await transaction.set(user.reference, user.toData());
      user.log();
    });
  }

  Future transactionUpdate() async {
    print('--- transactionUpdate ---');
    final hoge = User()
      ..name = 'hoge';
    await documentAccessor.save(hoge);
    hoge.log();

    flamingo.Transaction.run((transaction) async {
      final user = User(id: hoge.id)
        ..name = 'transactionAA';
      await transaction.update(user.reference, user.toData());
      user.log();
    });
  }

  Future transactionDelete() async {
    print('--- transactionDelete ---');
    final hoge = User()
      ..name = 'hoge';
    await documentAccessor.save(hoge);
    hoge.log();

    flamingo.Transaction.run((transaction) async {
      await transaction.delete(User(id: hoge.id).reference);
    });
  }

  Future saveMap() async {
    print('--- saveMap ---');
    final sample1 = MapSample()
      ..strMap = {'userId1': 'tanaka', 'userId2': 'hanako', 'userId3': 'shohei',}
      ..intMap = {'userId1': 0, 'userId2': 1, 'userId3': 2,}
      ..doubleMap = {'userId1': 1.02, 'userId2': 0.14, 'userId3': 0.89,}
      ..boolMap = {'userId1': true, 'userId2': true, 'userId3': true,}
      ..listStrMap = [
        {'userId1': 'tanaka', 'userId2': 'hanako',},
        {'adminId1': 'shohei', 'adminId2': 'tanigawa',},
        {'managerId1': 'ueno', 'managerId2': 'yoshikawa',},
      ];
    await documentAccessor.save(sample1);
    sample1.log();

    {
      print('  ----get');
      final _sample1 = await documentAccessor.load<MapSample>(MapSample(id: sample1.id));
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
      final _sample1 = await documentAccessor.load<MapSample>(MapSample(id: sample1.id));
      _sample1.log();
    }
  }

  Future saveList() async {
    print('--- saveList ---');
    final sample1 = ListSample()
      ..strList = ['userId1', 'userId2', 'userId3',]
      ..intList = [0, 1, 2,]
      ..doubleList = [0.0, 0.1, 0.2,]
      ..boolList = [true, false, true,]
      ..files = [
        StorageFile(name: 'name1', url: 'https://sample1.jpg', mimeType: mimeTypePng),
        StorageFile(name: 'name2', url: 'https://sample2.jpg', mimeType: mimeTypePng),
        StorageFile(name: 'name3', url: 'https://sample3.jpg', mimeType: mimeTypePng),
      ];
    await documentAccessor.save(sample1);
    sample1.log();

    {
      print('  ----get');
      final _sample1 = await documentAccessor.load<ListSample>(ListSample(id: sample1.id));
      _sample1.log();
    }

    sample1
      ..strList = []
      ..intList = []
      ..doubleList = []
      ..boolList = [];

    sample1.files.forEach((d) => d.isDeleted = true);
    await documentAccessor.save(sample1);

    {
      print('  ----get delete');
      final _sample1 = await documentAccessor.load<ListSample>(ListSample(id: sample1.id));
      _sample1.log();
    }
  }

  Future checkModelSample() async {
    print('--- ModelSample ---');
    final item = ModelSample();
    await documentAccessor.save(item);
    item.log();

    final storage = Storage();
    final file = await Helper.getImageFileFromAssets('assets', 'sample.jpg');

    // fetch for uploading status
    storage.fetch();
    storage.uploader.stream.listen((data){
      // confirm status
      print('total: ${data.snapshot.totalByteCount} transferred: ${data.snapshot.bytesTransferred}');
    });

    // save file metadata into firestore
    final path = '${item.documentPath}/${item.folderName}';
    item.file = await storage.save(
      path,
      file,
      mimeType: mimeTypePng,
      metadata: {
        'newPost': 'true'
      }
    );
    await documentAccessor.save(item);
    item.log();

    {
      print('  ----get');
      final _item = await documentAccessor.load<ModelSample>(ModelSample(id: item.id));
      _item.log();
    }

    {
      print('  ----get delete file');
      await storage.delete(path, item.file);
      await documentAccessor.update(item);
      final _item = await documentAccessor.load<ModelSample>(ModelSample(id: item.id));
      _item.log();
    }

    // dispose for uploading status
    storage.dispose();
  }

  Future listenerSample() async {
    print('--- listenerSample ---');

    /// Collection
    final path = Document.path<User>();
    final query = firestoreInstance().collection(path).limit(20);
    final collectionDispose = query.snapshots().listen((querySnapshot) {
      print('--- Listen of collection documents ---');
      for (var change in querySnapshot.documentChanges) {
        if (change.type == DocumentChangeType.added ) {
          print('added ${change.document.documentID}');
        }
        if (change.type == DocumentChangeType.modified) {
          print('modified ${change.document.documentID}');
        }
        if (change.type == DocumentChangeType.removed) {
          print('removed ${change.document.documentID}');
        }
      }
      final _ = querySnapshot.documents.map((item) => User(snapshot: item)).toList()
        ..forEach((item) => print('${item.id}, ${item.name}'));
    });


    /// Document
    final user = User(id: '0')
      ..name = 'hoge';

    final dispose = user.reference.snapshots().listen((snap) {
      print('--- Listen of document ---');
      print('snap: ${snap.documentID} ${snap.data}');
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
        Medal(name: 'gold',),
        Medal(name: 'silver',),
        Medal(name: 'bronze',),
      ];
    
    print('--- save ---');
    print('${owner.id}');
    await documentAccessor.save(owner);

    print('--- load ---');
    final _owner = await documentAccessor.load<Owner>(Owner(id: owner.id));
    print('id: ${_owner.id}, name: ${_owner.name}');
    print('address: ${_owner.id} ${_owner.address.postCode} ${_owner.address.country}');
    print('medals: ${_owner.medals.map((d) => d.name)}');
  }
}

