# Flamingo

Flamingo is a firebase firestore model framework library.

[https://pub.dev/packages/flamingo](https://pub.dev/packages/flamingo)

## Installation

Add this to your package's pubspec.yaml file:

```
dependencies:
  flamingo: ^0.0.9
```

## Setup
Please check Setup of cloud_firestore.<br>
[https://pub.dev/packages/cloud_firestore](https://pub.dev/packages/cloud_firestore#setup)

## Usage

Adding a configure code to main.dart.

### Initialize

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

Also be able to set app to firebase instance.

```dart
final app = await FirebaseApp.configure(
  name: 'appName',
  options: const FirebaseOptions(
    googleAppID: '1:1234567890:ios:42424242424242',
    gcmSenderID: '1234567890',
  ),
);
final firestore = Firestore(app: app);
final storage = FirebaseStorage(app: app);
final root = firestore.collection('version').document('1');
Flamingo.configure(firestore: firestore, storage: storage, root: root);
```

Create model class that inherited Document. And add json mapping code into override functions.

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
### Initialization

```dart
final user = User();
print(user.id); // id: Create document id;

final user = User(id: '0000');
print(user.id); // id: '0000'
```

### CRUD
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


Get a document.

```dart
// get
final user = User(id: '0000');  // need to 'id'.
final hoge = await documentAccessor.load<User>(user);
```

Get documents in collection.

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

### Map objects

Create the following model class.

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

### List

Create the following model class.

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

And save and load documents. 

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
sample1.log();

final _sample1 = await documentAccessor.load<ListSample>(ListSample(id: sample1.id));
```

### Sub Collection

For example, ranking document has count collection.

#### Ranking model

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
    // Must be create instance of Collection and set collection name.
    count = Collection(this, 'count');
  }

  String title;
  Collection<Count> count;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'name', title);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    title = valueFromKey<String>(data, 'title');
  }
}
```

#### Count model

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class Count extends Document<Count> {
  Count({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
    CollectionReference collectionRef,
  }): super(id: id, snapshot: snapshot, values: values, collectionRef: collectionRef);

  String userId;
  int count = 0;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'userId', userId);
    writeNotNull(data, 'count', count);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    userId = valueFromKey<String>(data, 'userId');
    count = valueFromKey<int>(data, 'count');
  }
}
```

#### Save and Get sub collection.

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
final snapshot = await firestoreInstance().collection(path).getDocuments();
final list = snapshot.documents.map((item) => Count(snapshot: item)).toList()
  ..forEach((count) {
    print(count);
  });
```

### File
Can operation into Firebase Storage and upload and delete storage file. Using StorageFile and Storage class.

For examople, create post model that have StorageFile.

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

Upload file to Firebase Storage.

```dart
final post = Post();
final storage = Storage();
final file = await Helper.getImageFileFromAssets('assets', 'sample.jpg');

// Fetch uploader stream
storage.fetch();

// Checking status
storage.uploader.stream.listen((data){
  print('total: ${data.snapshot.totalByteCount} transferred: ${data.snapshot.bytesTransferred}');
});

// Upload file into firebase storage and save file metadata into firestore
final path = '${post.documentPath}/${post.folderName}';
post.file = await storage.save(path, file, mimeType: mimeTypePng, metadata: {'newPost': 'true'}); // 'mimeType' is defined in master/master.dart
await documentAccessor.save(post);

// Dispose uploader stream
storage.dispose();
```

Delete storage file.

```dart
// delete file in firebase storage and delete file metadata in firestore
final path = '${post.documentPath}/${post.folderName}';
await storage.delete(path, post.file);
await documentAccessor.update(post);
```

### Distributed counter

Using DistributedCounter and Counter.

For examople, create score model that have Counter.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class Score extends Document<Score> {
  Score({
    String id,
  }): super(id: id) {
    value = Counter(this, 'shards', numShards);
  }

  /// Document
  String userId;

  /// DistributedCounter
  int numShards = 10;
  Counter value;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'userId', userId);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    userId = valueFromKey<String>(data, 'userId');
  }
}
```

Create and increment and load.

```dart
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
```

### Transaction

This api is simply wrap transaction function of Firestore.

```dart
import 'package:flamingo/transaction.dart';

Transaction.run((transaction) async {
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

## Getting Started
See the example directory for a complete sample app using flamingo.


## Reference
- [Firebase for flutter](https://firebase.google.com/docs/flutter/setup)
- [Ballcap for iOS](https://github.com/1amageek/Ballcap-iOS)
- [Ballcap for TypeScript](https://github.com/1amageek/ballcap.ts)
