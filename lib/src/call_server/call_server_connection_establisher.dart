import 'package:expertapp/src/environment/environment_config.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pbgrpc.dart';
import 'package:grpc/grpc.dart';

class CallServerConnectionEstablisher {
  static final CHANNEL_OPTIONS = EnvironmentConfig.getConfig().isProd()
      ? ChannelOptions(credentials: ChannelCredentials.secure())
      : ChannelOptions(credentials: ChannelCredentials.insecure());
  static final CHANNEL = ClientChannel(
      EnvironmentConfig.getConfig().rpcServerHostname(),
      port: EnvironmentConfig.getConfig().rpcServerPort(),
      options: CHANNEL_OPTIONS);

  final _client = CallTransactionClient(CHANNEL);

  Stream<ServerMessageContainer> connect(
    Stream<ClientMessageContainer> clientMessageStream) {
    return _client.initiateCall(clientMessageStream);
  }
}
