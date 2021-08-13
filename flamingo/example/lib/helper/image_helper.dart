import 'image_helper_stub.dart'
    if (dart.library.io) 'image_helper_native.dart'
    if (dart.library.js) 'image_helper_web.dart';

/// https://medium.com/flutter-community/conditional-imports-across-flutter-and-web-4b88885a886e
class ImageHelper {
  static Future<dynamic> getImage(String name,
          {String assetsName = 'assets'}) =>
      getImageFromAsset(name, assetsName: assetsName);
}
