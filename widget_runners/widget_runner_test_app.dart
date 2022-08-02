import 'package:flutter/material.dart';

class WidgetRunnerTestApp extends StatelessWidget {
  // This widget is the root of your application.
  Widget testWidget;
  WidgetRunnerTestApp(this.testWidget);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: testWidget,
    );
  }
}
