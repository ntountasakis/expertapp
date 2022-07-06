import 'package:expertapp/src/call_server/call_model.dart';
import 'package:expertapp/src/environment/environment_config.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pbgrpc.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:provider/provider.dart';

class CallManager {
  static final CHANNEL_OPTIONS = EnvironmentConfig.getConfig().isProd()
      ? ChannelOptions(credentials: ChannelCredentials.secure())
      : ChannelOptions(credentials: ChannelCredentials.insecure());
  static final CHANNEL = ClientChannel(
      EnvironmentConfig.getConfig().rpcServerHostname(),
      port: EnvironmentConfig.getConfig().rpcServerPort(),
      options: CHANNEL_OPTIONS);

  final _client = CallTransactionClient(CHANNEL);

  Future<void> call(
      {required BuildContext context,
      required String currentUserId,
      required String calledUserId}) async {
    final request =
        CallRequest(callerUid: currentUserId, calledUid: calledUserId);
    final model = Provider.of<CallModel>(context, listen: false);
    model.onCallRequest();
    final response = await _client.initiateCall(request);

    if (response.success) {
      model.onConnected();
    } else {
      model.onErrored(response.errorMessage);
    }
  }
}
