import 'package:flutter/material.dart';

class CommonViewContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const text =
        'Should you have any inquiries, feedback, or require assistance, we are here to help.'
        ' Email us at help@guruportal.io, and we will promptly respond to your message.';
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    return Scaffold(
        appBar: AppBar(
          title: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                "Contact Us",
              )),
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(text, style: style),
            ),
          ],
        ));
  }
}
