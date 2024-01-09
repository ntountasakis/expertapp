import 'package:expertapp/src/environment/environment_config.dart';

class ProdEnvironmentConfig implements EnvironmentConfig {
  @override
  String rpcServerHostname() {
    return 'expertapp-server-atromez3ka-uc.a.run.app';
  }

  @override
  int rpcServerPort() {
    return 443;
  }

  @override
  bool isProd() {
    return true;
  }
}
