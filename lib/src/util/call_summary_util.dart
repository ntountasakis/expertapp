import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:expertapp/src/util/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';

import '../navigation/routes.dart';

class CallSummaryUtil {
  static final BOLD_STYLE = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.grey[800],
  );

  static final LIGHT_STYLE = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.grey[800],
  );

  static final ButtonStyle BUTTON_STYLE =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  static String callLengthFormat(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}\h $twoDigitMinutes\m $twoDigitSeconds\s";
  }

  static Future<void> postCallGoHome(
      BuildContext context, CallServerModel model) async {
    final secLengthCall =
        model.callSummary != null ? model.callSummary!.lengthOfCallSec : 0;
    model.reset();
    context.goNamed(Routes.HOME_PAGE);
    if (secLengthCall > 120) {
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      }
    }
  }

  static Widget buildCallLength(ServerCallSummary summary) {
    final boldStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.grey[800],
    );
    final duration = Duration(seconds: summary.lengthOfCallSec);
    return Text(
      "Call Length: " + callLengthFormat(duration),
      style: boldStyle,
    );
  }

  static Widget buildCostOfCall(ServerCallSummary summary) {
    final cost = formattedRate(summary.costOfCallCents);
    return Text(
      "Cost of Call: " + cost,
      style: BOLD_STYLE,
    );
  }

  static Widget buildCallEarningsSubtotal(ServerCallSummary summary) {
    final subtotal = formattedRate(summary.costOfCallCents);
    return Text(
      "Call Subtotal: " + subtotal,
      style: BOLD_STYLE,
    );
  }

  static Widget buildCallEarningsPlatformFee(ServerCallSummary summary) {
    final platformFee = formattedRate(summary.platformFeeCents);
    return Text(
      "Payment Platform Fee: " + platformFee,
      style: BOLD_STYLE,
    );
  }

  static Widget buildCallEarningsAmountEarned(ServerCallSummary summary) {
    final amountEarned = formattedRate(summary.earnedTotalCents);
    return Text(
      "Amount Earned: " + amountEarned,
      style: BOLD_STYLE,
    );
  }

  static Widget buildButton(CallServerModel model, String buttonText,
      Function(CallServerModel) onButtonPressed) {
    return ElevatedButton(
      style: BUTTON_STYLE,
      onPressed: () async {
        onButtonPressed(model);
      },
      child: Text(buttonText),
    );
  }

  static Widget buildClientCallFinishedSummaryBlurb(ServerCallSummary summary) {
    final blurb =
        "Your payment method was charged ${formattedRate(summary.costOfCallCents)} for the call. "
        "We have cancelled the hold on the remaining amount that was authorized at the start of the call. "
        "Please consider leaving a review. Thank you for using GlobalGuides!";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        blurb,
        style: LIGHT_STYLE,
      ),
    );
  }

  static Widget buildClientCallCanceledSummaryBlurb(
      CallServerPaymentPromptModel paymentPrompt) {
    final blurb =
        "Your payment method was refunded in the amount of  ${formattedRate(paymentPrompt.centsRequestedAuthorized)}. "
        "If you experienced any issues with the platform, please reach out to customer service. "
        "Thank you for using GlobalGuides!";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        blurb,
        style: LIGHT_STYLE,
      ),
    );
  }

  static Widget buildExpertCallSummaryBlurb(ServerCallSummary summary) {
    final blurb =
        "After fees, you earned ${formattedRate(summary.earnedTotalCents)} for the call. "
        "Funds will be transferred to your bank account on file within 3-5 business days. "
        "Thank for your services on GlobalGuides!";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        blurb,
        style: LIGHT_STYLE,
      ),
    );
  }
}
