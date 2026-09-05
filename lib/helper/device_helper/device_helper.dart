import 'package:get/get.dart';

class DeviceHelper {
  static String userAgent = "Unknown Device";

  static Future<void> initUserAgent() async {
    if (GetPlatform.isWeb) {
      userAgent = "web";
    } else if (GetPlatform.isAndroid) {
      userAgent = "android";
    } else if (GetPlatform.isIOS) {
      userAgent = "ios";
    } else {
      userAgent = "unknown";
    }
  }
}
