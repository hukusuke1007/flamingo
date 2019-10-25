import 'package:flamingo/flamingo.dart';
import 'package:flamingo/transaction.dart';
import 'model/user.dart';
import 'model/history.dart';
import 'model/setting.dart';

class FlamingoTest {
  final documentAccessor = DocumentAccessor();
  
  Future save() async {
    final user = User();
    user.uid = user.id;
    user.name = 'shohei';
    user.memos = ['a', 'i', 'u', 'e', 'o'];
    await documentAccessor.save(user);
    user.log();
  }

  Future update(String id) async {
    final user = User(id: id);
    user.uid = user.id;
    user.name = 'hobbydevelop';
    user.age = 20;
    await documentAccessor.update(user);
    user.log();
  }

  Future delete(String id) async {
    final user = User(id: id);
    await documentAccessor.delete(user);
    user.log();
  }

  Future batchSave() async {
    final userA = User();
    userA.name = 'hanako';
    final userB = User();
    userB.name = 'tanaka';
//    final history = History();
//    history.name = 'history';

    final batch = Batch();
    batch.save(userA);
    batch.save(userB);
//    batch.save(history);
    await batch.commit();

    userA.log();
    userB.log();
//    history.log();
  }

  Future batchDelete() async {
    final userA = User(id: 'xPSq88jiCmCQdVmgX1eT');
//    final history = History(id: 'sZCCQTJXtvZO31mSZCUN');
    final batch = Batch();
    batch.delete(userA);
//    batch.delete(history);
    await batch.commit();
    userA.log();
//    history.log();
  }

  Future get() async {
    final id = 'GqnTA8p6lo2ZrjqygnoS';
    final user = await documentAccessor.load<User>(User(id: id));
    user.log();
  }

  Future getAndUpdate() async {
    // 取得
    final id = 'C6Ut9dAff2n7cQXtXtLG';
    final user = await documentAccessor.load<User>(User(id: id));
    // 更新
    user.name = 'あかさたな';
    await documentAccessor.update(user);
    user.log();
  }

  Future getCollection() async {
    print('path ${Document.path<User>()}');
    // 取得
    print('--- listA ---');
    final snapshot = await firestore().collection(Document.path<User>()).limit(5).getDocuments();
    final listA = snapshot.documents.map((item) => User(snapshot: item)).toList();
    print(listA.length);
    listA.forEach((item) => item.log());

    // 更新
    final item = listA[listA.length - 1];
    item.name = "update";
    await documentAccessor.update(item);

    print('--- listB NewID ---');
    final listB = snapshot.documents.map((item) => User(values: item.data)).toList();
    listB.forEach((item) => item.log());


    print('--- listC AlreadyExistID ---');
    final listC = snapshot.documents.map((item) => User(id: item.documentID, values: item.data)).toList();
    listC.forEach((item) => item.log());
  }

  Future saveCollection() async {
    print('path ${Document.path<User>()}');
    // 取得
    final id = 'vEzo07d5BK3nAJyGdx95';
    final userA = await documentAccessor.load<User>(User(id: id));
    userA.log();

    final settingA = Setting(parent: userA.settingsA.ref);
    settingA.isEnable = false;
    await documentAccessor.save(settingA);
    settingA.log();

    final settingB = Setting(parent: userA.settingsB.ref);
    settingB.isEnable = false;
    await documentAccessor.save(settingB);
  }

  Future getSubCollection() async {
    print('path ${Document.path<User>()}');
    // 取得
    final id = 'vEzo07d5BK3nAJyGdx95';
    final userA = await documentAccessor.load<User>(User(id: id));
    userA.log();

    final dataSourceA = firestore().collection(userA.settingsA.ref.path).limit(5);
    final snapshotA = await dataSourceA.getDocuments();
    final listA = snapshotA.documents.map((item) => Setting(
      documentSnapshot: item,
      parent: dataSourceA.reference()
    )).toList();
    print(listA[0].reference.path);
    listA[0].log();

    final dataSourceB = firestore().collection(userA.settingsB.ref.path).limit(5);
    final snapshotB = await dataSourceB.getDocuments();
    final listB = snapshotB.documents.map((item) => Setting(
      documentSnapshot: item,
      parent: dataSourceB.reference()
    )).toList();
    print(listB[0].reference.path);
    listB[0].log();
  }

  Future saveStorage() async {
    final id = '2SfKHjBHfpufRG3qmPul';
    final userA = await documentAccessor.load<User>(User(id: id));
    userA.log();
    final storage = Storage();
    final file = await Helper.getImageFileFromAssets('sample.jpg');
    userA.file = await storage.save('${userA.documentPath}/${userA.folderName}', file, mimeType: mimeTypePng);
    userA.log();
    await documentAccessor.update(userA);
  }

  Future deleteStorage() async {
    final id = '2SfKHjBHfpufRG3qmPul';
    final userA = await documentAccessor.load<User>(User(id: id));
    userA.log();
    final storage = Storage();
    await storage.delete('${userA.documentPath}/${userA.folderName}', userA.file);
    await documentAccessor.update(userA);
  }

  Future distributedCreate() async {
    final user = User();
    user.uid = user.id;
    user.name = 'shohei';
    await documentAccessor.save(user);
    final distributedCounter = DistributedCounter();
    await distributedCounter.create(user.likeCounter);
    user.log();
  }

  Future distributedIncrement() async {
    final user = User(id: 'Ggy0Z9S8QAa3jAEVgdOk');
    final distributedCounter = DistributedCounter();
    await distributedCounter.increment(user.likeCounter, count: 1);
  }

  Future distributedGet() async {
    final user = User(id: 'Ggy0Z9S8QAa3jAEVgdOk');
    final distributedCounter = DistributedCounter();
    final count = await distributedCounter.get(user.likeCounter);
    print('count $count ${user.likeCounter.count}');
  }

  Future transactionSave() async {
    Transaction.run((transaction) async {
      final user = User();
      user.name = 'transaction';
      await transaction.set(user.reference, user.toData());
      user.log();
    });
  }

  Future transactionUpdate() async {
    Transaction.run((transaction) async {
      final user = User(id: 'e0D1qBFbV1DhJJWzxxQM');
      user.name = 'transactionAA';
      await transaction.update(user.reference, user.toData());
      user.log();
    });
  }

  Future transactionDelete() async {
    Transaction.run((transaction) async {
      final user = User(id: 'e0D1qBFbV1DhJJWzxxQM');
      await transaction.delete(user.reference);
    });
  }

}

