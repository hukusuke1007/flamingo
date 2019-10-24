import 'dart:async';

import 'package:flutter/services.dart';

class Flamingo {
  static const MethodChannel _channel =
      const MethodChannel('flamingo');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
