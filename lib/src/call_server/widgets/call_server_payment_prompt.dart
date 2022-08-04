import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> showPaymentPrompt(
    {required BuildContext context, required CallServerModel model}) async {
  if (model.callBeginPaymentInitiate == null) {
    return;
  }

  final String stripeClientSecret =
      model.callBeginPaymentInitiate!.clientSecret;
  final String stripeCustomerId = model.callBeginPaymentInitiate!.customerId;

  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      customFlow: true,
      merchantDisplayName: 'Flutter Stripe Store Demo',
      paymentIntentClientSecret: stripeClientSecret,
      customerId: stripeCustomerId,
    ),
  );

  await Stripe.instance.presentPaymentSheet();
}
