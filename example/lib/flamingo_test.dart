import 'package:flamingo/flamingo.dart';
import 'package:flamingo/transaction.dart';
import 'package:flamingo_example/model/count.dart';
import 'package:flamingo_example/model/post.dart';
import 'package:flamingo_example/model/score.dart';
import 'model/ranking.dart';
import 'model/user.dart';

class FlamingoTest {
  DocumentAccessor documentAccessor = DocumentAccessor();
  
  Future save() async {
    print('--- save ---');
    final user = User()
        ..name = 'hoge';
    await documentAccessor.save(user);
    user.log();

    final hoge = await documentAccessor.load<User>(User(id: user.id));
    hoge.log();
  }

  Future update() async {
    print('--- update ---');
    final user = User()
      ..name = 'hoge';
    await documentAccessor.save(user);

    user.name = 'fuge';
    await documentAccessor.update(user);

    final hoge = await documentAccessor.load<User>(User(id: user.id));
    hoge.log();
  }

  Future delete() async {
    print('--- delete ---');
    final user = User()
      ..name = 'hoge';
    await documentAccessor.save(user);
    user.log();

    await documentAccessor.delete(user);
    final hoge = await documentAccessor.load<User>(User(id: user.id));
    hoge.log();
  }

  Future batchSave() async {
    print('--- batchSave ---');
    final userA = User()
      ..name = 'hoge';
    final userB = User()
      ..name = 'fuge';
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
      ..name = 'fuge';
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

    final fuge = await documentAccessor.load<User>(User(id: userB.id));
    hoge.log();
    fuge.log();
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
    await documentAccessor.save(ranking);
    ranking.log();

    final countA = Count(collectionRef: ranking.count.ref)
      ..userId = '0'
      ..count = 10;
    final countB = Count(collectionRef: ranking.count.ref)
      ..userId = '1'
      ..count = 100;
    final batch = Batch()
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
    final file = await Helper.getImageFileFromAssets('sample.jpg');

    // fetch for uploading status
    storage.fetch();
    storage.uploader.stream.listen((data){
      // confirm status
      print('total: ${data.snapshot.totalByteCount} transferred: ${data.snapshot.bytesTransferred}');
    });

    // save file metadata into firestore
    final path = '${post.documentPath}/${post.folderName}';
    post.file = await storage.save(path, file, mimeType: mimeTypePng);
    await documentAccessor.save(post);
    post.log();

    final hoge = await documentAccessor.load<Post>(Post(id: post.id));
    hoge.log();

    // dispose for uploading status
    storage.dispose();
  }

  Future deleteStorage() async {
    print('--- deleteStorage ---');
    final post = Post();
    final storage = Storage();
    final file = await Helper.getImageFileFromAssets('sample.jpg');
    final path = '${post.documentPath}/${post.folderName}';
    post.file = await storage.save(path, file, mimeType: mimeTypePng);
    await documentAccessor.save(post);
    post.log();

    await storage.delete(path, post.file);
    await documentAccessor.update(post);

    final hoge = await documentAccessor.load<Post>(Post(id: post.id));
    hoge.log();
  }

  Future distributedCounter() async {
    print('--- distributedCounter ---');

    /// Create
    final score = Score()
      ..userId = '0001';
    await documentAccessor.save(score);
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
    Transaction.run((transaction) async {
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

    Transaction.run((transaction) async {
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

    Transaction.run((transaction) async {
      await transaction.delete(User(id: hoge.id).reference);
    });
  }

}

