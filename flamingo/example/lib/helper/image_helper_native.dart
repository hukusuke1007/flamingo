import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

class ImageHelperNative {
  static Future<File> getImageFileFromAssets(String name,
      {String assetsName = 'assets'}) async {
    final byteData = await rootBundle.load('$assetsName/$name');
    final file = File('${(await getTemporaryDirectory()).path}/$name');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }
}

Future<dynamic> getImageFromAsset(String name,
        {String assetsName = 'assets'}) =>
    ImageHelperNative.getImageFileFromAssets(name, assetsName: assetsName);
