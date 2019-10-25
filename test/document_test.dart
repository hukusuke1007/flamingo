import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flamingo/flamingo.dart';
import 'model/user.dart';

void main() {

  setUp(() {
    Flamingo.configure(firestore().collection('version').document("1"));
    print('setUp');
  });

  tearDown(() {
    print('tearDown');
  });

  test('Document 1', () async {
    final user = User();
    user.uid = user.id;
    user.name = 'shohei';
    user.memos = ['a', 'i', 'u', 'e', 'o'];
    final documentAccessor = DocumentAccessor();
    await documentAccessor.save(user);
    user.log();
    expect(true, true);
  });

}
