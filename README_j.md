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
  flamingo_annotation: ^0.3.0

dev_dependencies:
  build_runner: ^1.7.1
  flamingo_generator: ^0.3.2
```


## 使い方

### 初期設定

ルートとなるコレクションとFirestoreとCloudStorageのインスタンスを設定します。

```dart
import 'package:flamingo/flamingo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flamingo.configure();
  ...
}
```


### モデルクラスの作成

Userのモデルクラスを作成します。

Firestoreへ書き込みするデータを設定するオーバーライドメソッド（toData）と、Firestoreからデータを取得してモデルクラスのフィールドへマッピングするオーバーライドメソッド（fromData）を実装します。

手動で実装もできますが、ここはflamingo_generatorを使ってマッピングコードの自動生成します。

まずは次のようにモデルクラスを作ります。

```dart
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'user.flamingo.dart';

class User extends Document<User> {
  User({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  String name;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
```

自動生成したいフィールドに対してはアノテーションを付与します。

- @Field()
- @StorageField()
- @ModelField()
- @SubCollection()

モデルクラスを実装後、ターミナルから次のコマンドを実行してコードを自動生成します。

```
flutter pub run build_runner build
```

自動生成されたコードは *.flamingo.dart のファイル名で作成されます。

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum UserKey {
  name,
}

extension UserKeyExtension on UserKey {
  String get value {
    switch (this) {
      case UserKey.name:
        return 'name';
      default:
        return toString();
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(User doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'name', doc.name);

  return data;
}

/// For load data
void _$fromData(User doc, Map<String, dynamic> data) {
  doc.name = Helper.valueFromKey<String>(data, 'name');
}

```


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


また、特定のフィールドKeyに対して保存することもできます。

```dart
DocumentAccessor documentAccessor = DocumentAccessor();
await documentAccessor.saveRaw(
  <String, dynamic>{ UserKey.name.value: 'hogehoge' },
  user.reference,
);
```

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
final snapshot = await firestoreInstance.collection(path).getDocuments();

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
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

import 'address.dart';
import 'medal.dart';

part 'owner.flamingo.dart';

class Owner extends Document<Owner> {
  Owner({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  String name;

  @ModelField()
  Address address;

  @ModelField()
  List<Medal> medals;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
```

Mapオブジェクトを管理するモデルクラスを作成します。

```dart
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'address.flamingo.dart';

class Address extends Model {
  Address({
    this.postCode,
    this.country,
    Map<String, dynamic> values,
  }) : super(values: values);

  @Field()
  String postCode;

  @Field()
  String country;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
```


```dart
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'medal.flamingo.dart';

class Medal extends Model {
  Medal({
    this.name,
    Map<String, dynamic> values,
  }) : super(values: values);

  @Field()
  String name;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
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
final query = firestoreInstance.collection(path).limit(20);
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
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

import 'count.dart';

part 'ranking.flamingo.dart';

class Ranking extends Document<Ranking> {
  Ranking(
      {String id,
      DocumentSnapshot snapshot,
      Map<String, dynamic> values,
      CollectionReference collectionRef})
      : super(
            id: id,
            snapshot: snapshot,
            values: values,
            collectionRef: collectionRef) {
    count = Collection(this, RankingKey.count.value);
  }

  @Field()
  String title;

  @SubCollection()
  Collection<Count> count;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
```

Countのモデルクラスは次の通りです。
Sub Collectionされる場合はコンストラクタにCollectionReferenceのパラメータを設定できるようにします（※1）。

```dart
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'count.flamingo.dart';

class Count extends Document<Count> {
  Count({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
    CollectionReference collectionRef,
  }) : super(
            id: id,
            snapshot: snapshot,
            values: values,
            collectionRef: collectionRef);

  @Field()
  String userId;

  @Field()
  int count = 0;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
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
final snapshot = await firestoreInstance.collection(path).getDocuments();
final list = snapshot.documents.map((item) => Count(snapshot: item, collectionRef: ranking.count.ref)).toList()
  ..forEach((count) {
    print('${count.userId}, ${count.count}');
  });
```


### Cloud Storageへの保存

Flamingoを使えばCloud Storageへの保存と、保存されたURLなどの情報をFirestoreへ簡単に保存することができます。

対象となるフィールドを StorageFile 型で定義します。

```dart
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'post.flamingo.dart';

class Post extends Document<Post> {
  Post({String id}) : super(id: id);

  @StorageField()
  StorageFile file;

  @StorageField()
  List<StorageFile> files;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
```

Cloud Storageへの操作はFlamingoが提供する Storage を利用します。

```dart
final post = Post();
final storage = Storage();
final file = ... // load image.

// Fetch uploader stream
storage.fetch();

// Checking status
storage.uploader.listen((data){
  print('total: ${data.snapshot.totalByteCount} transferred: ${data.snapshot.bytesTransferred}');
});

// Upload file into firebase storage and save file metadata into firestore
final path = '${post.documentPath}/${PostKey.file.value}';
post.file = await storage.save(path, file, mimeType: mimeTypePng, metadata: {'newPost': 'true'}); // 'mimeType' is defined in master/master.dart
await documentAccessor.save(post);

// Dispose uploader stream
storage.dispose();
```

削除は次の通りです。保存されたCloud Storage内のファイルとFirestoreへ保存されているStorageFileのフィールドを削除します。

```dart
// delete file in firebase storage and delete file metadata in firestore
final path = '${post.documentPath}/${PostKey.file.value}';
await storage.delete(path, post.file);
await documentAccessor.update(post);
```

また、FlamingoではCloud StorageとFirestoreへまとめて操作できるインターフェースを提供しています。

```dart
// Save storage and document of storage data.
final storageFile = await storage.saveWithDoc(
    post.reference,
    PostKey.file.value,
    file,
    mimeType: mimeTypePng,
    metadata: {
      'newPost': 'true'
    },
    additionalData: <String, dynamic>{
      'key0': 'key',
      'key1': 10,
      'key2': 0.123,
      'key3': true,
    },
);

// Delete storage and document of storage data.
await storage.deleteWithDoc(post.reference, PostKey.file.value, post.file, isNotNull: true);
```

### Increment

FieldValue.increment を使用する場合は、Flamingoが提供する Increment を使用します。

例として、CreditCardのドキュメントが point と score のIncrementを持ったモデルを考えます。

```dart
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'credit_card.flamingo.dart';

class CreditCard extends Document<CreditCard> {
  CreditCard({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values) {
    point = Increment(CreditCardKey.point.value);
    score = Increment(CreditCardKey.score.value);
  }

  @Field()
  Increment<int> point;

  @Field()
  Increment<double> score;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  /// Call after create, update, delete.
  @override
  void onCompleted(ExecuteType executeType) {
    point = point.onRefresh();
    score = score.onRefresh();
  }
}
```

point と score のインクリメント、デクリメント、クリアする実装は次の通りです。

```dart
// Increment
final card = CreditCard()
  ..point.incrementValue = 1
  ..score.incrementValue = 1.25;
await documentAccessor.save(card);
print('point ${card.point.value}, score: ${card.score.value}'); // point 1, score 1.25

final _card = await documentAccessor.load<CreditCard>(card);
print('point ${_card.point.value}, score: ${_card.score.value}'); // point 1, score 1.25


// Decrement
card
  ..point.incrementValue = -1
  ..score.incrementValue = -1.00;
await documentAccessor.update(card);
print('point ${card.point.value}, score: ${card.score.value}'); // point 0, score 0.25

final _card = await documentAccessor.load<CreditCard>(card);
print('point ${_card.point.value}, score: ${_card.score.value}'); // point 0, score 0.25


// Clear
card
  ..point.isClearValue = true
  ..score.isClearValue = true;
await documentAccessor.update(card);
print('point ${card.point.value}, score: ${card.score.value}'); // point 0, score 0.0

final _card = await documentAccessor.load<CreditCard>(card);
print('point ${_card.point.value}, score: ${_card.score.value}'); // point 0, score 0.0
```

また、DocumentAccessor のincrement関数を使えば、incrementデータのみの操作ができます。

```dart
final card = CreditCard();
final batch = Batch()
  ..save(card);
await batch.commit();

// Increment
card
  ..point = await documentAccessor.increment<int>(card.point, card.reference, value: 10)
  ..score = await documentAccessor.increment<double>(card.score, card.reference, value: 3.5);

// Decrement
card
  ..point = await documentAccessor.increment<int>(card.point, card.reference, value: -5)
  ..score = await documentAccessor.increment<double>(card.score, card.reference, value: -2.5);

// Clear
card
  ..point = await documentAccessor.increment<int>(card.point, card.reference, isClear: true)
  ..score = await documentAccessor.increment<double>(card.score, card.reference, isClear: true);
```

なお、Clear処理はドキュメントに0をセットして更新しているだけです。

トランザクション処理はしていないので、初めてそのドキュメントが作成される初期化処理以外での使用はしないでください。

### 分散カウンタ

Flamingoが提供する DistributedCounter を使えば簡単に分散カウンタを作れます。

対象となるフィールドを Counter 型で定義します。

```dart
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'score.flamingo.dart';

class Score extends Document<Score> {
  Score({
    String id,
  }) : super(id: id) {
    counter = Counter(this, ScoreKey.counter.value, numShards);
  }

  @Field()
  String userId;

  /// DistributedCounter
  @SubCollection()
  Counter counter;

  int numShards = 10;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
```

DistributedCounter を使った実装は次の通りです。

例では 10カウントアップさせています。

```dart
/// Create
final score = Score()
  ..userId = '0001';
await documentAccessor.save(score);

final distributedCounter = DistributedCounter();
await distributedCounter.create(score.counter);

/// Increment
for (var i = 0; i < 10; i++) {
  await distributedCounter.increment(score.counter, count: 1);
}

/// Load
final count = await distributedCounter.load(score.counter);
print('count $count ${score.counter.count}');
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
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'map_sample.flamingo.dart';

class MapSample extends Document<MapSample> {
  MapSample({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  Map<String, String> strMap;

  @Field()
  Map<String, int> intMap;

  @Field()
  Map<String, double> doubleMap;

  @Field()
  Map<String, bool> boolMap;

  @Field()
  List<Map<String, String>> listStrMap;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
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
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'list_sample.flamingo.dart';

class ListSample extends Document<ListSample> {
  ListSample({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  List<String> strList;

  @Field()
  List<int> intList;

  @Field()
  List<double> doubleList;

  @Field()
  List<bool> boolList;

  @StorageField(isWriteNotNull: false)
  List<StorageFile> filesA;

  @StorageField()
  List<StorageFile> filesB;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
```

保存と取得。

```dart
/// Save
final sample1 = ListSample()
  ..strList = ['userId1', 'userId2', 'userId3',]
  ..intList = [0, 1, 2,]
  ..doubleList = [0.0, 0.1, 0.2,]
  ..boolList = [true, false, true,]
  ..filesA = [
    StorageFile(
        name: 'name1', url: 'https://sample1.jpg', mimeType: mimeTypePng),
    StorageFile(
        name: 'name2', url: 'https://sample2.jpg', mimeType: mimeTypePng),
    StorageFile(
        name: 'name3', url: 'https://sample3.jpg', mimeType: mimeTypePng),
  ]
  ..filesB = [
    StorageFile(
        name: 'name1', url: 'https://sample1.jpg', mimeType: mimeTypePng),
    StorageFile(
        name: 'name2', url: 'https://sample2.jpg', mimeType: mimeTypePng),
    StorageFile(
        name: 'name3', url: 'https://sample3.jpg', mimeType: mimeTypePng),
  ];
await documentAccessor.save(sample1);

/// Load
final _sample1 = await documentAccessor.load<ListSample>(ListSample(id: sample1.id));
```

## Reference
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Ballcap for iOS](https://github.com/1amageek/Ballcap-iOS)
- [Ballcap for TypeScript](https://github.com/1amageek/ballcap.ts)

