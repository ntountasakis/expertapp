import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/payment_status.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedCallsPage extends StatelessWidget {
  final DocumentWrapper<UserMetadata> userMetadata;

  CompletedCallsPage(this.userMetadata);

  Widget buildCallPopup(CallTransaction call, String transactionId) {
    String helpText = '''If you need assistance with this call,
    please refer to  this call using this ID:
    ${transactionId}
    when contacting customer service.''';

    return AlertDialog(
      title: const Text("Call Details"),
      content: Text(helpText),
    );
  }

  Widget buildCallCard(CallTransaction call, String transactionId) {
    return FutureBuilder(
        future: Future.wait([
          PaymentStatus.get(call.callerCallStartPaymentStatusId),
          PaymentStatus.get(call.callerCallTerminatePaymentStatusId),
          UserMetadata.get(call.calledUid)
        ]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            final startPayment =
                snapshot.data![0] as DocumentWrapper<PaymentStatus>?;
            final endPayment =
                snapshot.data![1] as DocumentWrapper<PaymentStatus>?;
            final expertMetadata =
                snapshot.data![2] as DocumentWrapper<UserMetadata>?;

            if (startPayment == null || endPayment == null) {
              return SizedBox();
            }

            String title = 'Call';
            if (expertMetadata != null) {
              title += ' with ' +
                  expertMetadata.documentType.firstName +
                  ' ' +
                  expertMetadata.documentType.lastName;
            }

            final endTime =
                DateTime.fromMillisecondsSinceEpoch(call.callEndTimeUtsMs);
            int amountSpentCents = startPayment.documentType.centsToCollect +
                endPayment.documentType.centsCollected;

            String dateFormat = DateFormat.yMd().add_jm().format(endTime);
            final dollarFormat = new NumberFormat('#,##0.00', "en_US");
            String subtitle =
                'Ended on ${dateFormat}. Paid \$${dollarFormat.format(amountSpentCents / 100)}';

            return Card(
                key: Key(transactionId),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(subtitle),
                  leading: SizedBox(
                      width: 50,
                      child: ProfilePicture(
                          expertMetadata!.documentType.profilePicUrl)),
                  trailing: GestureDetector(
                    onTap: () {
                      showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return buildCallPopup(call, transactionId);
                          });
                    },
                    child: Icon(Icons.more_vert),
                  ),
                ));
          }
          return SizedBox();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Completed Calls")),
      body: StreamBuilder(
        stream: CallTransaction.getStream(userMetadata.documentId),
        builder: (BuildContext context,
            AsyncSnapshot<Iterable<DocumentWrapper<CallTransaction>>>
                snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final DocumentWrapper<CallTransaction> call =
                      snapshot.data!.elementAt(index);
                  return buildCallCard(call.documentType, call.documentId);
                });
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
