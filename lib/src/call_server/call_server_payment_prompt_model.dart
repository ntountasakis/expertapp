import 'dart:io';
import 'dart:ui';

import 'package:flutter_stripe/flutter_stripe.dart';

enum PaymentState {
  NA,
  AWAITING_PAYMENT,
  PAYMENT_COMPLETE,
  PAYMENT_FAILURE,
  PAYMENT_CANCELLED
}

class CallServerPaymentPromptModel {
  final VoidCallback onPaymentStateChanged;
  PaymentState _state = PaymentState.NA;
  late String _clientSecret;
  late String _stripeCustomerId;
  late String _ephemeralKey;
  late int _centsRequestedAuthorized;

  CallServerPaymentPromptModel(this.onPaymentStateChanged);

  PaymentState get paymentState => _state;
  String get clientSecret => _clientSecret;
  String get stripeCustomerId => _stripeCustomerId;
  int get centsRequestedAuthorized => _centsRequestedAuthorized;

  Future<void> onPaymentDetails(
      {required String clientSecret,
      required String stripeCustomerId,
      required String ephemeralKey,
      required int centsRequestedAuthorized}) async {
    _clientSecret = clientSecret;
    _stripeCustomerId = stripeCustomerId;
    _ephemeralKey = ephemeralKey;
    _centsRequestedAuthorized = centsRequestedAuthorized;
    _state = PaymentState.AWAITING_PAYMENT;
  }

  Future<void> presentPaymentSheet() async {
    try {
      bool platformPaySupported = await Stripe.instance
          .isPlatformPaySupported(googlePay: getGooglePayParams());
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Flutter Stripe Store Demo',
          paymentIntentClientSecret: _clientSecret,
          customerEphemeralKeySecret: _ephemeralKey,
          customerId: stripeCustomerId,
          applePay: getPaymentSheetApplePay(platformPaySupported),
          googlePay: getPaymentSheetGooglePay(platformPaySupported),
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (exception) {
      if (exception.error.code == FailureCode.Canceled) {
        onPaymentCanceled();
        onPaymentStateChanged();
      }
    }
  }

  IsGooglePaySupportedParams? getGooglePayParams() {
    // TODO: flip testenv to false
    return IsGooglePaySupportedParams(
        testEnv: true,
        supportsTapToPay: false,
        existingPaymentMethodRequired: false);
  }

  PaymentSheetGooglePay? getPaymentSheetGooglePay(bool platformPaySupported) {
    // TODO: flip testenv to false
    if (platformPaySupported) {
      return PaymentSheetGooglePay(
        merchantCountryCode: "US",
        currencyCode: "USD",
        testEnv: true,
      );
    }
  }

  PaymentSheetApplePay? getPaymentSheetApplePay(bool platformPaySupported) {
    if (Platform.isIOS && platformPaySupported) {
      return PaymentSheetApplePay(
        merchantCountryCode: "US",
      );
    }
    return null;
  }

  void onPaymentComplete() {
    _state = PaymentState.PAYMENT_COMPLETE;
  }

  void onPaymentFailure() {
    _state = PaymentState.PAYMENT_FAILURE;
  }

  void onPaymentCanceled() {
    _state = PaymentState.PAYMENT_CANCELLED;
  }
}
