import '../generated/protos/call_transaction.pb.dart';

enum PaymentState {
  WAITING_FOR_PAYMENT_DETAILS,
  READY_TO_PRESENT_PAYMENT,
  PAYMENT_COMPLETE,
  PAYMENT_FAILURE
}

class CallServerPaymentPromptModel {
  PaymentState _state = PaymentState.WAITING_FOR_PAYMENT_DETAILS;
  ServerCallBeginPaymentInitiate? _paymentDetails;

  PaymentState get paymentState => _state;
  ServerCallBeginPaymentInitiate? get paymentDetails => _paymentDetails;

  void onPaymentDetails(ServerCallBeginPaymentInitiate details) {
    _paymentDetails = details;
    _state = PaymentState.READY_TO_PRESENT_PAYMENT;
  }

  void onPaymentComplete() {
    _state = PaymentState.PAYMENT_COMPLETE;
  }

  void onPaymentFailure() {
    _state = PaymentState.PAYMENT_FAILURE;
  }
}
