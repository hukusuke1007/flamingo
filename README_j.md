# Flamingo

Flamingoを利用したサンプルコードは[こちら](https://github.com/hukusuke1007/flamingo/tree/master/example)です。

## 事前準備
予め利用するプロジェクトへFirebaseの設定を行います。公式リファレンスのステップ１〜ステップ３までを実施してください。

[Flutter アプリに Firebase を追加する](https://firebase.google.com/docs/flutter/setup?hl=ja)

## インストール

pubspec.yamlへFlamingoをインストールします。

```
dependencies:
  flamingo:
```

## 使い方

### 初期設定

ルートとなるコレクションとFirestoreとCloudStorageのインスタンスを設定します。

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flamingo/flamingo.dart';

void main() {
  final firestore = Firestore.instance;
  final root = firestore.collection('version').document('1');
  Flamingo.configure(firestore: firestore, storage: FirebaseStorage.instance, root: root);
  ...
}
```

### モデルクラスの作成

Userのモデルクラスを作成します。

Firestoreへ書き込みするデータを設定するオーバーライドメソッド（toData）と、Firestoreからデータを取得してモデルクラスのフィールドへマッピングするオーバーライドメソッド（fromData）を実装します。

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class User extends Document<User> {
  User({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values);

  String name;

  // For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'name', name);
    return data;
  }

  // For load data
  @override
  void fromData(Map<String, dynamic> data) {
    name = valueFromKey<String>(data, 'name');
  }
}
```

toDataとfromDataを実装しなければFirestoreへの読み書きができないので実装は必須です。

### CRUD

Document への操作は、Flamingoが提供する DocumentAccessor を利用します。

#### 書き込み

```dart
final user = User()
      ..name = 'hoge';

DocumentAccessor documentAccessor = DocumentAccessor();

await documentAccessor.save(user);
```

Userの id を指定しなかった場合は自動で生成されます。例では'EYkOA3gBsWGbuWxOmbf0'が生成。

Firestoreへ次のように保存されます。

<a href="https://imgur.com/tlmwnrr"><img src="https://i.imgur.com/tlmwnrr.png" width="90%" /></a>


#### 読み込み

```dart
DocumentAccessor documentAccessor = DocumentAccessor();
final user = await documentAccessor.load<User>(User(id: 'EYkOA3gBsWGbuWxOmbf0'));
print(user.name) // hoge
```

#### 更新

```dart
final user = User(id: 'EYkOA3gBsWGbuWxOmbf0')
      ..name = 'fuga';

DocumentAccessor documentAccessor = DocumentAccessor();
await documentAccessor.update(user);
```

#### 削除

```dart
DocumentAccessor documentAccessor = DocumentAccessor();
await documentAccessor.delete(User(id: 'EYkOA3gBsWGbuWxOmbf0'));
```

### Batchを使って一括操作

Batchを使えば複数のドキュメント操作を一括でできます。

```dart
final userA = User(id: '0')
      ..name = 'hoge';
final userB = User(id: '1')
      ..name = 'fuga';
final userC = User(id: '2');

final batch = Batch()
  ..save(userA)
  ..update(userB)
  ..delete(userC);
await batch.commit();
```

### Collection

Flamingoではコレクション操作をラップしたインターフェースは作っていません。そのため、Flamingoに設定したFirestoreインスタンス経由でCollection操作を行います。

```dart
final path = Document.path<User>();
final snapshot = await firestoreInstance().collection(path).getDocuments();

// from snapshot
final listA = snapshot.documents.map((item) => User(snapshot: item)).toList()
  ..forEach((user) {
    print(user.id); // user model.
  });

// from values.
final listB = snapshot.documents.map((item) => User(id: item.documentID, values: item.data)).toList()
  ..forEach((user) {
    print(user.id); // user model.
  });
```

コレクションから取得した DocumentSnapshot をモデルクラスのパラメータに渡すことでマッピングされます。また、**Algolia**などの外部サービスを使うことを考慮してMap<String, dynamic>型のvaluesもマッピングできるようにしています。


### Mapのモデル

Mapオブジェクトのモデルクラスを作成できます。

例として Owner のドキュメントが次のデータ構造の場合を考えてみます。

```json
{
  "name": "owner",
  "address": {
    "postCode": "0000",
    "country": "japan"
  },
  "medals": [
    {"name": "gold"},
    {"name": "silver"},
    {"name": "bronze"}
  ]
}
```

実装例は次の通りです。

```dart
class Owner extends Document<Owner> {
  Owner({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values);

  String name;

  // Model of map object
  Address address;
  List<Medal> medals;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'name', name);
    writeModelNotNull(data, 'address', address);  // For model.
    writeModelListNotNull(data, 'medals', medals); // For model list.
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    name = valueFromKey<String>(data, 'name');
    address = Address(values: valueMapFromKey<String, String>(data, 'address')); // For model
    medals = valueMapListFromKey<String, String>(data, 'medals') // For model list.
        .where((d) => d != null)
        .map((d) => Medal(values: d))
        .toList();
  }
}
```

Mapオブジェクトを管理するモデルクラスを作成します。

```dart
class Address extends Model {
  Address({
    this.postCode,
    this.country,
    Map<String, dynamic> values,
  }): super(values: values);

  String postCode;
  String country;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'postCode', postCode);
    writeNotNull(data, 'country', country);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    postCode = valueFromKey<String>(data, 'postCode');
    country = valueFromKey<String>(data, 'country');
  }

}
```


```dart
class Medal extends Model {
  Medal({
    this.name,
    Map<String, dynamic> values,
  }): super(values: values);

  String name;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'name', name);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    name = valueFromKey<String>(data, 'name');
  }
}
```

documentAccessor を使って保存取得する例です。

```dart
// save
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

await documentAccessor.save(owner);

// load
final _owner = await documentAccessor.load<Owner>(Owner(id: owner.id));
print('id: ${_owner.id}, name: ${_owner.name}');
print('address: ${_owner.id} ${_owner.address.postCode} ${_owner.address.country}');
print('medals: ${_owner.medals.map((d) => d.name)}');
```

<a href="https://imgur.com/O9f1LOb"><img src="https://i.imgur.com/O9f1LOb.png" width="90%" /></a>

### Snapshot Listener

モデルクラスの reference を用いることでドキュメントの作成、更新、削除のイベントを監視できます。

```dart
// Listen
final user = User(id: '0')
  ..name = 'hoge';

final disposer = user.reference.snapshots().listen((snap) {
  final user = User(snapshot: snap);
  print('${user.id}, ${user.name}');
});

// Save, update, delete
DocumentAccessor documentAccessor = DocumentAccessor();
await documentAccessor.save(user);

user.name = 'fuga';
await documentAccessor.update(user);

await documentAccessor.delete(user);

await disposer.cancel();
```

コレクションのスナップショットも監視することができます。

DocumentChangeType を利用する場合は cloud_firestore をインポートしてください。

```
import 'package:cloud_firestore/cloud_firestore.dart';
```

```dart
// Listen
final path = Document.path<User>();
final query = firestoreInstance().collection(path).limit(20);
final dispose = query.snapshots().listen((querySnapshot) {
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

// Save, update, delete
final user = User(id: '0')
  ..name = 'hoge';

DocumentAccessor documentAccessor = DocumentAccessor();
await documentAccessor.save(user);

user.name = 'fuga';
await documentAccessor.update(user);

await documentAccessor.delete(user);

await dispose.cancel();
```


### Sub Collection

モデルクラスにCollectionを持たせることもできます。

例として、Rankingモデル が Countモデル のCollectionを持った構造を考えてみます。

#### モデルクラスを作成

Sub Collectionにしたいフィールドを Collection の型で指定します（※1）。
また、Sub Collectionに親のリファレンスとコレクション名を指定する必要があるため、Rankingのコンストラクタ内でCollectionの初期化をします（※2）。

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';
import 'count.dart';

class Ranking extends Document<Ranking> {
  Ranking({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values) {
    // ※2 Must be create instance of Collection and set collection name.
    count = Collection(this, 'count');
  }

  String title;
  Collection<Count> count; // ※1

  // For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'name', title);
    return data;
  }

  // For load data
  @override
  void fromData(Map<String, dynamic> data) {
    title = valueFromKey<String>(data, 'title');
  }
}
```

Countのモデルクラスは次の通りです。
Sub Collectionされる場合はコンストラクタにCollectionReferenceのパラメータを設定できるようにします（※1）。

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class Count extends Document<Count> {
  Count({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
    CollectionReference collectionRef, // ※1 Need to set a CollectionReference parameter.
  }): super(id: id, snapshot: snapshot, values: values, collectionRef: collectionRef);

  String userId;
  int count = 0;

  // For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'userId', userId);
    writeNotNull(data, 'count', count);
    return data;
  }

  // For load data
  @override
  void fromData(Map<String, dynamic> data) {
    userId = valueFromKey<String>(data, 'userId');
    count = valueFromKey<int>(data, 'count');
  }
}
```

#### Sub Collectionの保存と取得

Sub Collectionとして保存したい場合は collectionRef のパラメータに親が保持するSub Collectionのリファレンスを指定します。例では、Rankingモデルが持つ ranking.count.ref をCountモデルへ指定しています（※1）。

Sub Collectionの取得する際のパスは ranking.count.ref.path を使います（※2）。

```dart
final ranking = Ranking(id: '20201007')
  ..title = 'userRanking';

// Save sub collection of ranking document
final countA = Count(collectionRef: ranking.count.ref) // ※1
  ..userId = '0'
  ..count = 10;
final countB = Count(collectionRef: ranking.count.ref) // ※1
  ..userId = '1'
  ..count = 100;
final batch = Batch()
  ..save(ranking)
  ..save(countA)
  ..save(countB);
await batch.commit();

// Get sub collection
final path = ranking.count.ref.path; // ※2
final snapshot = await firestoreInstance().collection(path).getDocuments();
final list = snapshot.documents.map((item) => Count(snapshot: item)).toList()
  ..forEach((count) {
    print('${count.userId}, ${count.count}');
  });
```


### Cloud Storageへの保存

Flamingoを使えばCloud Storageへの保存と、保存されたURLなどの情報をFirestoreへ簡単に保存することができます。

対象となるフィールドを StorageFile 型で定義します。

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class Post extends Document<Post> {
  Post({
    String id
  }): super(id: id);

  // Storage
  StorageFile file;
  String folderName = 'file';

  // For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeStorage(data, folderName, file);
    return data;
  }

  // For load data
  @override
  void fromData(Map<String, dynamic> data) {
    file = storageFile(data, folderName);
  }
}
```

Cloud Storageへの操作はFlamingoが提供する Storage を利用します。

```dart
final post = Post();
final storage = Storage();
final file = await Helper.getImageFileFromAssets('assets', 'sample.jpg'); // flutterプロジェクト内に保存されている画像を取得

// Fetch uploader stream
storage.fetch();

// Checking status
storage.uploader.stream.listen((data){
  print('total: ${data.snapshot.totalByteCount} transferred: ${data.snapshot.bytesTransferred}');
});

// Upload file into firebase storage and save file metadata into firestore
final path = '${post.documentPath}/${post.folderName}';
post.file = await storage.save(
  path,
  file,
  mimeType: mimeTypePng, // 'mimeType' is defined in master/master.dart
  metadata: {
    'newPost': 'true'
  }
);
await documentAccessor.save(post);

// Dispose uploader stream
storage.dispose();
```

削除は次の通りです。保存されたCloud Storage内のファイルとFirestoreへ保存されているStorageFileのフィールドを削除します。

```dart
final path = '${post.documentPath}/${post.folderName}';
await storage.delete(path, post.file);
await documentAccessor.update(post);
```

### Increment

FieldValue.increment を使用する場合は、Flamingoが提供する Increment を使用します。

例として、CreditCardのドキュメントが point と score のIncrementを持ったモデルを考えます。

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class CreditCard extends Document<CreditCard> {
  CreditCard({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values) {
    point = Increment('point'); // Set field name of point
    score = Increment('score'); // Set field name of score
  }

  Increment<int> point;
  Increment<double> score;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeIncrement(data, point);
    writeIncrement(data, score);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    point = valueFromIncrement<int>(data, point.fieldName);
    score = valueFromIncrement<double>(data, score.fieldName);
  }

  /// For completed create, update, delete.
  @override
  void onCompleted() {
    point.onCompleted(); // need!!
    score.onCompleted(); // need!!
  }
}
```

point と score の数値のインクリメント、デクリメント、クリアする実装は次の通りです。

```dart

// Increment
final card = CreditCard()
  ..point.incrementValue = 1
  ..score.incrementValue = 1.25;
await documentAccessor.save(card);

final _card = await documentAccessor.load<CreditCard>(card);
print('point ${_card.point.value}, score: ${_card.score.value}'); // point 1, score 1.25


// Decrement
card
  ..point.incrementValue = -1
  ..score.incrementValue = -1.00;
await documentAccessor.update(card);

final _card = await documentAccessor.load<CreditCard>(card);
print('point ${_card.point.value}, score: ${_card.score.value}'); // point 0, score 0.25


// Clear values
card
  ..point.isClearValue = true
  ..score.isClearValue = true;
await documentAccessor.update(card);

final _card = await documentAccessor.load<CreditCard>(card);
print('point ${_card.point.value}, score: ${_card.score.value}'); // point 0, score 0.0
```

また、DocumentAccessor のincrement関数を使えば incrementデータ のみの操作ができます。

```dart
final card = CreditCard();
final batch = Batch()
  ..save(card);
await batch.commit();

// Increment
card
  ..point = await documentAccessor.increment<int>(card.point, card.reference, value: 10)
  ..score = await documentAccessor.increment<double>(card.score, card.reference, value: 3.5);

final _card = await documentAccessor.load<CreditCard>(card);
print('point ${_card.point.value}, score: ${_card.score.value}'); // point 10, score 3.5

// Decrement
card
  ..point = await documentAccessor.increment<int>(card.point, card.reference, value: -5)
  ..score = await documentAccessor.increment<double>(card.score, card.reference, value: -2.5);

final _card = await documentAccessor.load<CreditCard>(card);
print('point ${_card.point.value}, score: ${_card.score.value}'); // point 5, score 1.0

// Clear values
card1
  ..point = await documentAccessor.increment<int>(card.point, card.reference, isClear: true)
  ..score = await documentAccessor.increment<double>(card.score, card.reference, isClear: true);

final _card = await documentAccessor.load<CreditCard>(card);
print('point ${_card.point.value}, score: ${_card.score.value}'); // point 0, score 0.0
```

なお、Clear処理はドキュメントに0をセットして更新しているだけです。

トランザクション処理はしていないので、初めてそのドキュメントが作成される初期化処理以外での使用はしないでください。

### 分散カウンタ

Flamingoが提供する DistributedCounter を使えば簡単に分散カウンタを作れます。

対象となるフィールドを Counter 型で定義します。

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class Score extends Document<Score> {
  Score({
    String id,
  }): super(id: id) {
    value = Counter(this, 'shards', numShards);
  }

  // Document
  String userId;

  // DistributedCounter
  int numShards = 10;
  Counter value;

  // For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'userId', userId);
    return data;
  }

  // For load data
  @override
  void fromData(Map<String, dynamic> data) {
    userId = valueFromKey<String>(data, 'userId');
  }
}
```

DistributedCounter を使った実装は次の通りです。

例では 10カウントアップさせています。

```dart
// Create document before set distributed counter.
final score = Score()
  ..userId = '0001';
await documentAccessor.save(score);

final distributedCounter = DistributedCounter();
await distributedCounter.create(score.value);

// Increment
for (var i = 0; i < 10; i++) {
  await distributedCounter.increment(score.value, count: 1);
}

// Load
final count = await distributedCounter.load(score.value);
print('count $count ${score.value.count}');
```

### トランザクション

Flamingoではトランザクション処理の軽量なラップ関数を提供しています。

```dart
RunTransaction.scope((transaction) async {
  final hoge = User()
    ..name = 'hoge';

  // save
  await transaction.set(hoge.reference, hoge.toData());

  // update
  final fuge = User(id: '0')
    ..name = 'fuge';
  await transaction.update(fuge.reference, fuge.toData());

  // delete
  await transaction.delete(User(id: '1').reference);
});
```


### 様々なデータ型に対する実装

#### Map


```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class MapSample extends Document<MapSample> {
  MapSample({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values);

  Map<String, String> strMap;
  Map<String, int> intMap;
  Map<String, double> doubleMap;
  Map<String, bool> boolMap;
  List<Map<String, String>> listStrMap;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'strMap', strMap);
    writeNotNull(data, 'intMap', intMap);
    writeNotNull(data, 'doubleMap', doubleMap);
    writeNotNull(data, 'boolMap', boolMap);
    writeNotNull(data, 'listStrMap', listStrMap);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    strMap = valueMapFromKey<String, String>(data, 'strMap');
    intMap = valueMapFromKey<String, int>(data, 'intMap');
    doubleMap = valueMapFromKey<String, double>(data, 'doubleMap');
    boolMap = valueMapFromKey<String, bool>(data, 'boolMap');
    listStrMap = valueMapListFromKey<String, String>(data, 'listStrMap');
  }
}
```


```dart
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

final _sample1 = await documentAccessor.load<MapSample>(MapSample(id: sample1.id));
```

#### List

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class ListSample extends Document<ListSample> {
  ListSample({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values);

  List<String> strList;
  List<int> intList;
  List<double> doubleList;
  List<bool> boolList;
  List<StorageFile> files;
  String folderName = 'files';

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'strList', strList);
    writeNotNull(data, 'intList', intList);
    writeNotNull(data, 'doubleList', doubleList);
    writeNotNull(data, 'boolList', boolList);
    writeStorageList(data, folderName, files);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    strList = valueListFromKey<String>(data, 'strList');
    intList = valueListFromKey<int>(data, 'intList');
    doubleList = valueListFromKey<double>(data, 'doubleList');
    boolList = valueListFromKey<bool>(data, 'boolList');
    files = storageFiles(data, folderName);
  }
}
```


```dart
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

final _sample1 = await documentAccessor.load<ListSample>(ListSample(id: sample1.id));
```

## Reference
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Ballcap for iOS](https://github.com/1amageek/Ballcap-iOS)
- [Ballcap for TypeScript](https://github.com/1amageek/ballcap.ts)

