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

// Save
await documentAccessor.save(user);

// Update
await documentAccessor.update(user);

// Delete
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
// Get
final user = User(id: '0000');  // need to 'id'.
final hoge = await documentAccessor.load<User>(user);
```

Get documents in collection.

```dart
final path = Document.path<User>();
final snapshot = await firestoreInstance().collection(path).getDocuments();

// From snapshot
final listA = snapshot.documents.map((item) => User(snapshot: item)).toList()
  ..forEach((item) {
    print(item.id); // user model.
  });

// From values.
final listB = snapshot.documents.map((item) => User(id: item.documentID, values: item.data)).toList()
  ..forEach((item) {
    print(item.id); // user model.
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

Upload into Firebase Storage.

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
post.file = await storage.save('${post.documentPath}/${post.folderName}', file, mimeType: mimeTypePng); // 'mimeType' is defined in master/master.dart
await documentAccessor.save(post);

// dispose for uploading status
storage.dispose();
```

Delete into Firebase Storage.

```dart
// delete file in firebase storage and delete file metadata in firestore
await storage.delete('${post.documentPath}/${post.folderName}', post.file);
await documentAccessor.update(post);
```

### Distributed counter

Using DistributedCounter and Counter.

For examople, create score model that have Counter.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';

class Score extends Document<Score> {
  Score({String id, DocumentSnapshot snapshot, Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values) {
    // Need to defined Counter.
    // Must be set collectionName and num of shards.
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
  void fromData(Map<String, dynamic> data) {}
}
```

Create and increment and load.

```dart
// Create document before set distributed counter.
final score = Score()
await documentAccessor.save(score);

// Create
final distributedCounter = DistributedCounter();
await distributedCounter.create(score.value);

// Increment
for (var i = 0; i < 10; i++) {
  await distributedCounter.increment(score.value, count: 1);
}

// Load
final count = await distributedCounter.load(score.value);
print('count $count ${score.value.count}'); // count 10 10
```

## Getting Started
See the example directory for a complete sample app using flamingo.