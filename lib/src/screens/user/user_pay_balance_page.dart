import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/payment_status.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserPayBalancePage extends StatefulWidget {
  final AppLifecycle lifecycle;

  UserPayBalancePage(this.lifecycle);

  @override
  State<UserPayBalancePage> createState() => _UserPayBalancePageState();
}

class _UserPayBalancePageState extends State<UserPayBalancePage> {
  late OutstandingBalanceDetails? balanceDetails = null;
  final paymentPromptModel = new CallServerPaymentPromptModel();

  @override
  void initState() {
    super.initState();
    resolveBalanceDetails();
  }

  void resolveBalanceDetails() async {
    final paymentInfo = await getInfoToPayOutstandingBalance();
    setState(() {
      balanceDetails = paymentInfo;
    });
    if (paymentInfo.hasOutstandingBalance()) {
      await paymentPromptModel.onPaymentDetails(
          clientSecret: paymentInfo.clientSecret,
          stripeCustomerId: paymentInfo.customerId);
    }
  }

  Widget buildPaymentCompleteButton() {
    return Column(
      children: [
        const Text("Amount due paid, you can exit this screen"),
        ElevatedButton(
          child: const Text("Return to Home Screen"),
          onPressed: () async {
            await widget.lifecycle.refreshOwedBalance();
            context.goNamed(Routes.HOME);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Colors.black), //change your color here
          title: const Text("Pay Outstanding Balance"),
        ),
        body: Builder(builder: (context) {
          if (balanceDetails == null) {
            return CircularProgressIndicator();
          }
          if (!balanceDetails!.hasOutstandingBalance()) {
            return const Text("You have no outstanding balance");
          }
          return StreamBuilder(
              stream: PaymentStatus.getStreamOfUpdatesForPayments(
                  balanceDetails!.paymentStatusId),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentWrapper<PaymentStatus?>> snapshot) {
                if (snapshot.hasData) {
                  final paymentStatusDoc = snapshot.data!;
                  if (paymentStatusDoc.documentType == null) {
                    return const Text("Error, cannot process payment");
                  }
                  final amountOwed =
                      paymentStatusDoc.documentType!.amountOwedCents();
                  if (amountOwed == 0) {
                    return buildPaymentCompleteButton();
                  }
                  return Text("You owe ${amountOwed} cents");
                }
                return CircularProgressIndicator();
              });
        }));
  }
}
