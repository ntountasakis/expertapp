import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  static String version = "";

  static Future<void> initVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
  }
}
