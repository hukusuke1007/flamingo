import 'package:flutter_test/flutter_test.dart';

import '../lib/model/index.dart';

void main() {
  test('test', () {
    final user = User()
      ..name = 'nana'
      ..profile = 'I am nana';
    print(user.toData());
    expect(UserFieldValueKey.cartA.value, 'cartA');
  });
}
