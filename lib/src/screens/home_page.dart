import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            SizedBox(
              width: 100,
              height: 200,
            ),
            ElevatedButton(
              child: Text("Go to listings"),
              onPressed: (() {
                context.goNamed(Routes.EXPERT_LISTINGS_PAGE);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
