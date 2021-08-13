import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/services.dart' show rootBundle;

class ImageHelperWeb {
  static Future<html.Blob> getImageBlobFromAssets(String name,
      {String assetsName = 'assets'}) async {
    final byteData = await rootBundle.load('$assetsName/$name');
    print("assets ${byteData.lengthInBytes}");
    final pngBytes = byteData.buffer.asUint8List();
    final blob = html.Blob(<dynamic>[pngBytes], 'application/octet-stream');
    return blob;
  }
}

Future<dynamic> getImageFromAsset(String name,
        {String assetsName = 'assets'}) =>
    ImageHelperWeb.getImageBlobFromAssets(name, assetsName: assetsName);
