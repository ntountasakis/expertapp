import 'package:flutter/material.dart';

class CommonViewContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const text =
        'Should you have any inquiries, feedback, or require assistance, our dedicated team is here to help.'
        ' Email us at help@todo.com, and we will promptly respond to your message.';
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    return Scaffold(
        appBar: AppBar(
          title: Text("Contact Us"),
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
