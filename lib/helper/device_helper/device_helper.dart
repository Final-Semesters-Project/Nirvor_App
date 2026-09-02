import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceHelper {
  static String userAgent = "Unknown Device";

  static Future<void> initUserAgent() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      
      String osVersion = "";
      String deviceModel = "";
      String appVersion = "App v${packageInfo.version}";

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        osVersion = "Android ${androidInfo.version.release}";
        deviceModel = "${androidInfo.manufacturer} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        osVersion = "iOS ${iosInfo.systemVersion}";
        deviceModel = iosInfo.utsname.machine;
      }

      userAgent = "$osVersion | $deviceModel | $appVersion";
    } catch (e) {
      userAgent = "${Platform.operatingSystem} ${Platform.operatingSystemVersion}";
    }
  }
}
