import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  static Future<File> getImageFileFromAssets(String path, String name) async {
    final byteData = await rootBundle.load('$path/$name');
    final file = File('${(await getTemporaryDirectory())!.path}/$name');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }
}
