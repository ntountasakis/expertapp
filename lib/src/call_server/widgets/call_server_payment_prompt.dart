import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> showPaymentPrompt(CallServerModel model) async {
  final String stripeClientSecret =
      model.callBeginPaymentPromptModel.paymentDetails!.clientSecret;
  final String stripeCustomerId =
      model.callBeginPaymentPromptModel.paymentDetails!.customerId;

  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      merchantDisplayName: 'Flutter Stripe Store Demo',
      paymentIntentClientSecret: stripeClientSecret,
      customerId: stripeCustomerId,
    ),
  );

  model.callBeginPaymentPromptModel.onPaymentPrompt();
  await Stripe.instance.presentPaymentSheet();
}
