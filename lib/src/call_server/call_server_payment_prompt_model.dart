import '../generated/protos/call_transaction.pb.dart';

enum PaymentState {
  WAITING_FOR_PAYMENT_DETAILS,
  READY_TO_PRESENT_PAYMENT,
  PAYMENT_COMPLETE,
  PAYMENT_FAILURE
}

class CallServerPaymentPromptModel {
  PaymentState _state = PaymentState.WAITING_FOR_PAYMENT_DETAILS;
  late String _clientSecret;
  late String _stripeCustomerId;

  PaymentState get paymentState => _state;
  String get clientSecret => _clientSecret;
  String get stripeCustomerId => _stripeCustomerId;

  void onPaymentDetails(
      {required String clientSecret, required String stripeCustomerId}) {
    _clientSecret = clientSecret;
    _stripeCustomerId = stripeCustomerId;
    _state = PaymentState.READY_TO_PRESENT_PAYMENT;
  }

  void onPaymentComplete() {
    _state = PaymentState.PAYMENT_COMPLETE;
  }

  void onPaymentFailure() {
    _state = PaymentState.PAYMENT_FAILURE;
  }
}
