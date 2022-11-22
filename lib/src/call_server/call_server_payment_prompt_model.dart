import 'package:flutter_stripe/flutter_stripe.dart';

import '../generated/protos/call_transaction.pb.dart';

enum PaymentState { NA, AWAITING_PAYMENT, PAYMENT_COMPLETE, PAYMENT_FAILURE }

class CallServerPaymentPromptModel {
  PaymentState _state = PaymentState.NA;
  late String _clientSecret;
  late String _stripeCustomerId;

  PaymentState get paymentState => _state;
  String get clientSecret => _clientSecret;
  String get stripeCustomerId => _stripeCustomerId;

  Future<void> onPaymentDetails(
      {required String clientSecret,
      required String stripeCustomerId,
      required String ephemeralKey}) async {
    _clientSecret = clientSecret;
    _stripeCustomerId = stripeCustomerId;
    _state = PaymentState.AWAITING_PAYMENT;

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'Flutter Stripe Store Demo',
        paymentIntentClientSecret: _clientSecret,
        customerEphemeralKeySecret: ephemeralKey,
        customerId: stripeCustomerId,
      ),
    );
    await Stripe.instance.presentPaymentSheet();
  }

  void onPaymentComplete() {
    _state = PaymentState.PAYMENT_COMPLETE;
  }

  void onPaymentFailure() {
    _state = PaymentState.PAYMENT_FAILURE;
  }
}
