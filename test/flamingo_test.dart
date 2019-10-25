import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flamingo/flamingo.dart';

void main() {

  setUp(() {
    print('test');
  });

  tearDown(() {
    print('tearDown');
  });

  test('Document 1', () async {
    expect(true, true);
  });

}
