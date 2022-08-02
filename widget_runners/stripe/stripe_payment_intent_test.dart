import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../widget_runner_test_app.dart';

class StripeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardField(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51LLQIdAoQ8pfRhfFNyVrKysmtjgsXqW2zjx6IxcVpKjvq8iMqTTGRl8BCUnTYiIzq5HUkbnZ9dXtiibhdum3Ozfv00lOhg3RyX';
  await Stripe.instance.applySettings();

  runApp(new WidgetRunnerTestApp(new StripeCard()));
}
