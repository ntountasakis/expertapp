import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarRating extends StatelessWidget {
  final double _rating;
  final double _starSize;

  StarRating(this._rating, this._starSize);

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
        rating: _rating,
        itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Colors.black,
            ),
        itemCount: 5,
        itemSize: _starSize,
        direction: Axis.horizontal);
  }
}
