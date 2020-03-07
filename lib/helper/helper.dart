import 'dart:math';

class Helper {
  static Map<String, dynamic> fromMap(Map map) => Map<String, dynamic>.from(map);

  static String randomString({int length}) {
    const _randomChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const _charsLength = _randomChars.length;
    final rand = Random();
    final codeUnits = List.generate(
      length != null ? length : 10,
      (index) {
        final n = rand.nextInt(_charsLength);
        return _randomChars.codeUnitAt(n);
      },
    );
    return String.fromCharCodes(codeUnits);
  }
}
