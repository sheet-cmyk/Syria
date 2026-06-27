import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class DeviceService {
  static Future<String> getDeviceId() async {
    if (kIsWeb) return 'unknown';
    final info = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = await info.androidInfo;
      return android.id;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = await info.iosInfo;
      return ios.identifierForVendor ?? 'unknown';
    }
    return 'unknown';
  }
}
