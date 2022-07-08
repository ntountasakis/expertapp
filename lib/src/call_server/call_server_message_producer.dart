import 'dart:async';

import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';

class CallServerMessageProducer {
  final _controller = StreamController<ClientMessageContainer>();

  Stream<ClientMessageContainer> messageProducerStream() {
    return _controller.stream;
  }

  void sendMessage(ClientMessageContainer aMessage) {
    _controller.add(aMessage);
  }

  Future<void> shutdown() async {
    return _controller.close();
  }
}
