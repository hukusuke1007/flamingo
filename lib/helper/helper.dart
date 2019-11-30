import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class Helper {
  static Map<String, dynamic> fromMap(Map map) => Map<String, dynamic>.from(map);
  static Future<File> getImageFileFromAssets(String path, String name) async {
    final byteData = await rootBundle.load('$path/$name');
    final file = File('${(await getTemporaryDirectory()).path}/$name');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }
  static String randomString({int length}) {
    const _randomChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const _charsLength = _randomChars.length;
    final rand = Random();
    final codeUnits = List.generate(length != null ? length : 10, (index) {
      final n = rand.nextInt(_charsLength);
      return _randomChars.codeUnitAt(n);
    },);
    return String.fromCharCodes(codeUnits);
  }
}

