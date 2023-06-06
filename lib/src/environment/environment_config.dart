import 'package:expertapp/src/environment/debug.dart';
import 'package:expertapp/src/environment/prod.dart';

abstract class EnvironmentConfig {
  static const bool IS_PROD = true;

  String rpcServerHostname();
  int rpcServerPort();
  bool isProd();

  factory EnvironmentConfig.getConfig() {
    if (IS_PROD) return ProdEnvironmentConfig();
    return DebugEnvironmentConfig();
  }
}
