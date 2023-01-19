import 'dart:io';

import 'package:expertapp/src/environment/environment_config.dart';

class DebugEnvironmentConfig implements EnvironmentConfig {
  @override
  String rpcServerHostname() {
    final localhostString = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return localhostString;
  }

  @override
  int rpcServerPort() {
    return 8080;
  }

  @override
  bool isProd() {
    return false;
  }
}
