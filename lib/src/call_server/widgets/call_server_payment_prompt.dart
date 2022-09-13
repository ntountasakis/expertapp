import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> showPaymentPrompt(CallServerPaymentPromptModel paymentPromptModel) async {
  final String stripeClientSecret = paymentPromptModel.clientSecret;
  final String stripeCustomerId = paymentPromptModel.stripeCustomerId;

  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      merchantDisplayName: 'Flutter Stripe Store Demo',
      paymentIntentClientSecret: stripeClientSecret,
      customerId: stripeCustomerId,
    ),
  );

  await Stripe.instance.presentPaymentSheet();
}
