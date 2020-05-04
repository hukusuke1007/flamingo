import 'package:flamingo/flamingo.dart';

class Public<T> extends Document<T> {
  Public({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values);

  @override
  CollectionReference get collectionRootReference => rootReference.collection('public');

}

