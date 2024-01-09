import 'package:flutter/material.dart';

class TextRating extends StatelessWidget {
  final _rating;
  final _fontSize;
  const TextRating(this._rating, this._fontSize);

  @override
  Widget build(BuildContext context) {
    var roundedRating = double.parse((_rating).toStringAsFixed(2));
    return Text("$roundedRating / 5", style: TextStyle(fontSize: _fontSize));
  }
}
