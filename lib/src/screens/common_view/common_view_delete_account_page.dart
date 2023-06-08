import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

class CommonViewDeleteAccountPage extends StatelessWidget {
  Widget buildWarningText() {
    const text =
        '''Are you sure you want to delete your account? Please note that this action is irreversible and all your data will be permanently deleted from our system.

If you're experiencing any issues or have feedback about our product, please contact our customer service team at help@guruportal.io so we can help you and improve our service for everyone.

If you're absolutely sure you want to proceed with the account deletion, please click the button below.
        ''';
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    return Row(children: [
      SizedBox(width: 20),
      Expanded(child: Text(text, style: style)),
      SizedBox(width: 20),
    ]);
  }

  Widget buildDeleteButton(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      backgroundColor: Colors.red[500],
      elevation: 4.0,
      shadowColor: Colors.red[900],
    );
    return Row(children: [
      SizedBox(width: 20),
      Expanded(
          child: ElevatedButton(
              style: style,
              onPressed: () async {
                final result = await onAccountDelete();
                await showPostDeleteDialog(context, result);
                if (result.success) {
                  await FirebaseAuth.FirebaseAuth.instance.signOut();
                }
              },
              child: Text("Delete Account"))),
      SizedBox(width: 20),
    ]);
  }

  Future<void> showPostDeleteDialog(
      BuildContext context, UpdateResult result) async {
    final title = result.success ? "Success" : "Error";
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(result.message),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            "Delete Account",
          ),
        )),
        body: Column(
          children: [
            SizedBox(height: 20),
            buildWarningText(),
            buildDeleteButton(context),
          ],
        ));
  }
}
