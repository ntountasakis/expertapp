import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/util/call_summary_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedCallsUtil {
  static Widget buildCallPopup(CallTransaction call, String transactionId) {
    String helpText = 'If you need assistance with this call, '
        'please refer to  this call using this ID: '
        '${transactionId} '
        'when contacting customer service.';

    return AlertDialog(
      title: const Text("Call Details"),
      content: Text(helpText),
    );
  }

  static String formatEndDate(CallTransaction call) {
    final endTime = DateTime.fromMillisecondsSinceEpoch(call.callEndTimeUtsMs);
    return DateFormat.yMd().add_jm().format(endTime);
  }

  static String formatCents(int cents) {
    final dollarFormat = new NumberFormat('#,##0.00', "en_US");
    return '\$${dollarFormat.format(cents / 100)}';
  }

  static String formatCallLength(CallTransaction call) {
    final callLengthSec =
        (call.callEndTimeUtsMs - call.calledJoinTimeUtcMs) ~/ 1000;
    return CallSummaryUtil.callLengthFormat(Duration(seconds: callLengthSec));
  }
}
