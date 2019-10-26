# Flamingo

Firesbase Firestore model framework library.

## Installation


## Setup
Please check Setup of cloud_firestore.<br>
[https://pub.dev/packages/cloud_firestore](https://pub.dev/packages/cloud_firestore)

## Usage

Adding a configure code to main.dart.

```dart
import 'package:flamingo/flamingo.dart';

Flamingo.configure(rootName: 'version', version: 1);
```

Create model class that inherited Document. And please add json mapping code into override functions.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class User extends Document<User> {
  User({String id, DocumentSnapshot snapshot, Map<String, dynamic> values,
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

### Sub Collection



### File
Can operation into Firebase Storage and upload and delete storage file. Using StorageFile and Storage class.

For examople, create post model that have StorageFile.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class Post extends Document<Post> {
  Post({String id}): super(id: id);

  // Storage
  StorageFile file;
  String folderName = 'file';

  // For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    if (file != null) {
      if (!file.isDeleted) {
        data[folderName] = file.toJson();
      } else {
        data[folderName] = FieldValue.delete();
      }
    }
    return data;
  }

  // For load data
  @override
  void fromData(Map<String, dynamic> data) {
    if (isVal(data, folderName)) {
      file = StorageFile.fromJson(Helper.fromMap(data[folderName] as Map));
    }
  }
}
```

Upload file to Firebase Storage.

```dart
final post = Post();
final storage = Storage();
final file = await Helper.getImageFileFromAssets('sample.jpg');

// fetch for uploading status
storage.fetch();

// confirm status
storage.uploader.stream.listen((data){
  print('total: ${data.snapshot.totalByteCount} transferred: ${data.snapshot.bytesTransferred}');
});

// upload file into firebase storage and save file metadata into firestore
final path = '${post.documentPath}/${post.folderName}';
post.file = await storage.save(path, file, mimeType: mimeTypePng); // 'mimeType' is defined in master/master.dart
await documentAccessor.save(post);

// dispose for uploading status
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
  Score({String id,
  }): super(id: id) {
    // Need to defined Counter. Must be set collectionName and num of shards.
    value = Counter(this, 'shards', numShards);
  }

  // DistributedCounter
  int numShards = 10;
  Counter value;

  // For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    return data;
  }

  // For load data
  @override
  void fromData(Map<String, dynamic> data) {
  }
}
```

Create and increment and load.

```dart
// Create document before set distributed counter.
final score = Score()
await documentAccessor.save(score);

// create
final distributedCounter = DistributedCounter();
await distributedCounter.create(score.value);

// increment
for (var i = 0; i < 10; i++) {
  await distributedCounter.increment(score.value, count: 1);
}

// get
final count = await distributedCounter.load(score.value);
print('count $count ${score.value.count}'); // count 10 10
```

## Getting Started
See the example directory for a complete sample app using flamingo.