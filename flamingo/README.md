# Flamingo

Flamingo is a firebase firestore model framework library.

[https://pub.dev/packages/flamingo](https://pub.dev/packages/flamingo)

[日本語ドキュメント](https://github.com/hukusuke1007/flamingo/blob/master/README_j.md)

## Example code
See the example directory for a complete sample app using flamingo.

[example](https://github.com/hukusuke1007/flamingo/tree/master/flamingo/example)

## Installation

Add this to your package's pubspec.yaml file:

```
dependencies:
  flamingo:
  flamingo_annotation:

dev_dependencies:
  build_runner: ^1.10.1
  # If occur analyzer error, please set build_resolvers.
  # build_resolvers: ^1.3.10

  flamingo_generator:
```


## Setup
Please check Setup of cloud_firestore.<br>
[https://pub.dev/packages/cloud_firestore](https://pub.dev/packages/cloud_firestore#setup)

## Usage

Adding a initializeApp code to main.dart.

### Initialize

```dart
import 'package:flamingo/flamingo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flamingo.initializeApp();
  ...
}
```

### Create Model
Create class that inherited **Document**. And add json mapping code into override functions.

Can be used flamingo_generator. Automatically create code for mapping JSON.

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

Annotation list.

- @Field()
- @StorageField()
- @ModelField()
- @SubCollection()

Execute build runner to generate data mapping JSON.

```
flutter pub run build_runner build
```

It will be generated the following code.

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

#### [Option] build.yaml

If you set build.yaml in the root of the project, the automatic generation will be faster.

https://github.com/hukusuke1007/flamingo/blob/master/flamingo/example/build.yaml


```yaml
targets:
  $default:
    builders:
      flamingo_generator|field_value_generator:
        generate_for:
          include:
            - lib/model/*.dart
            - lib/model/**/*.dart
```


### CRUD

Create instance the following code.

```dart
final user = User();
print(user.id); // id: Automatically create document id;

final user = User(id: '0000');
print(user.id); // id: '0000'
```

Using DocumentAccessor or Batch or Transaction in order to CRUD.

```dart
final user = User()
      ..name = 'hoge';

DocumentAccessor documentAccessor = DocumentAccessor();

// save
await documentAccessor.save(user);

// update
await documentAccessor.update(user);

// delete
await documentAccessor.delete(user);

// Batch
final batch = Batch()
  ..save(user)
  ..update(user);
  ..delete(user);
await batch.commit();
```

If save a document, please check firestore console.

<a href="https://imgur.com/tlmwnrr"><img src="https://i.imgur.com/tlmwnrr.png" width="90%" /></a>


And can be used field value key and save data by specific key.

```dart
DocumentAccessor documentAccessor = DocumentAccessor();
await documentAccessor.saveRaw(
  <String, dynamic>{ UserKey.name.value: 'hogehoge' },
  user.reference,
);
```

Get a document.

```dart
// get
final user = User(id: '0000');  // need to 'id'.
final hoge = await documentAccessor.load<User>(user);
```

### Get Documents
#### CollectionPaging
Can be used get and paging features of documents by CollectionPaging.

Query of Collection.

```dart
final ref = User().collectionRef;
final collectionPaging = CollectionPaging<User>(
  query: User().collectionRef.orderBy('createdAt', descending: true),
  limit: 20,
  collectionRef: ref,
  decode: (snap, collectionRef) =>
      User(snapshot: snap, collectionRef: collectionRef),
);

List<User> items = [];

// Load 
final _items = await collectionPaging.load<User>();
items = _items;

// LoadMore
final _items = await collectionPaging.loadMore<User>();
items.addAll(_items);
```

Query of CollectionGroup.

```dart
final collectionPaging = CollectionPaging<User>(
  query: firestoreInstance
    .collectionGroup('user')
    .orderBy('createdAt', descending: true),
  limit: 20,
  decode: (snap, _) =>
      User(snapshot: snap, collectionRef: snap.reference.parent),
);
```

[sample code](https://github.com/hukusuke1007/flamingo/blob/master/flamingo/example/lib/collection_paging_page.dart)

#### CollectionPagingListener
Can be used listener and paging features of documents by CollectionPagingListener.<br>

```dart
final collectionPagingListener = CollectionPagingListener<User>(
  query: User().collectionRef.orderBy('updatedAt', descending: true),
  initialLimit: 20,
  pagingLimit: 20,
  decode: (snap, _) =>
      User(snapshot: snap, collectionRef: snap.reference.parent),
);

// Fetch to set listener.
collectionPagingListener.fetch();

List<User> items = [];

// Get documents via listener. data is ValueStream.
collectionPagingListener.data.listen((event) {
    setState(() {
      items = event;
    });
  });

// Get document changes status and cache status.
collectionPagingListener.docChanges.listen((event) {
    for (var item in event) {
      final change = item.docChange;
      print('id: ${item.doc.id}, changeType: ${change.type}, oldIndex: ${change.oldIndex}, newIndex: ${change.newIndex} cache: ${change.doc.metadata.isFromCache}');
    }
  });

// LoadMore. To load next page data.
collectionPagingListener.loadMore();


// Dispose.
await collectionPagingListener.dispose();
```

[sample code](https://github.com/hukusuke1007/flamingo/blob/master/flamingo/example/lib/collection_paging_listener_page.dart)

#### firestoreInstance
Can be get documents in collection.

```dart
final path = Document.path<User>();
final snapshot = await firestoreInstance.collection(path).get();

// from snapshot
final listA = snapshot.docs.map((item) => User(snapshot: item)).toList()
  ..forEach((user) {
    print(user.id); // user model.
  });

// from values.
final listB = snapshot.docs.map((item) => User(id: item.documentID, values: item.data)).toList()
  ..forEach((user) {
    print(user.id); // user model.
  });
```

### Snapshot Listener 

Listen snapshot of document.

```dart
// Listen
final user = User(id: '0')
  ..name = 'hoge';

final dispose = user.reference.snapshots().listen((snap) {
  final user = User(snapshot: snap);
  print('${user.id}, ${user.name}');
});

// Save, update, delete
DocumentAccessor documentAccessor = DocumentAccessor();
await documentAccessor.save(user);

user.name = 'fuga';
await documentAccessor.update(user);

await documentAccessor.delete(user);

await dispose.cancel();
```

Listen snapshot of collection documents. And can be used also CollectionPagingListener.

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
  final _ = querySnapshot.docs.map((item) => User(snapshot: item)).toList()
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

### Model of map object

Example, Owner's document object is the following json.

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

Owner that inherited **Document** has model of map object.

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

Create class that inherited **Model**.

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

Example of usage.

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

### Sub Collection

For example, ranking document has count collection.

#### Ranking model

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

#### Count model

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

#### Save and Get Sub Collection.

```dart
final ranking = Ranking(id: '20201007')
  ..title = 'userRanking';

// Save sub collection of ranking document
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

// Get sub collection
final path = ranking.count.ref.path;
final snapshot = await firestoreInstance.collection(path).get();
final list = snapshot.docs.map((item) => Count(snapshot: item, collectionRef: ranking.count.ref)).toList()
  ..forEach((count) {
    print(count);
  });
```


### File
Can operation into Firebase Storage and upload and delete storage file. Using StorageFile and Storage class.

For examople, create post model that have StorageFile.

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

Upload file to Firebase Storage.

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

Delete storage file.

```dart
// delete file in firebase storage and delete file metadata in firestore
final path = '${post.documentPath}/${PostKey.file.value}';
await storage.delete(path, post.file);
await documentAccessor.update(post);
```

Alternatively, flamingo provide function to operate Cloud Storage and Firestore.

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

Example, CreditCard's document has point and score field. Their fields is Increment type.

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

Increment and decrement of data.

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

Or can be use with increment method of DocumentAccessor.

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

Attension: 

Clear process only set 0 to document and update. It not try transaction process. Do not use except to first set doument

### Distributed counter

Using DistributedCounter and Counter.

For examople, create score model that have Counter.

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

Create and increment and load.

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

### Transaction

This api is simply wrap transaction function of Firestore.

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


### Objects for model

#### Map objects

Create the following model class.

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

And save and load documents. 

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

Create the following model class.

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

And save and load documents. 

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

## [WIP] Unit Test

<b>※Under construction</b>


Install packages for unit test.

- [test](https://pub.dev/packages/test)
- [cloud_firestore_mocks](https://pub.dev/packages/cloud_firestore_mocks)
- [firebase_storage_mocks](https://pub.dev/packages/firebase_storage_mocks)

```
dev_dependencies:
  ...

  test: ^1.14.4
  cloud_firestore_mocks:
  firebase_storage_mocks:
```

Set Firestore and Cloud Storage mock instance.

```dart
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flamingo/flamingo.dart';
import 'package:test/test.dart';

void main() async {
  final firestore = MockFirestoreInstance();
  final storage = MockFirebaseStorage();
  await Flamingo.initializeApp(
      firestore: firestore,
      storage: storage,
      root: firestore.document('test/v1'));
  ...
}
```

[sample code](https://github.com/hukusuke1007/flamingo/blob/master/flamingo/example/test/example_test.dart)


## Reference
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Ballcap for iOS](https://github.com/1amageek/Ballcap-iOS)
- [Ballcap for TypeScript](https://github.com/1amageek/ballcap.ts)
