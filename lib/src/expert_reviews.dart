import 'package:expertapp/src/expert_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ExpertReviews extends StatefulWidget {
  static List<ExpertReview> _fetchReviews() {
    return [
      ExpertReview(
          "Nick Jonas",
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut leo eu nibh pharetra interdum a et nunc. Aliquam erat volutpat. Morbi a nisl hendrerit, dignissim lorem sodales, condimentum libero. Nam bibendum felis iaculis, molestie neque pretium, finibus leo. Proin tellus elit, venenatis at velit pretium, aliquam imperdiet ante. Donec erat sapien, accumsan sit amet placerat eget, imperdiet id nunc. Nunc tempus, felis in efficitur gravida, mi risus tempor libero, eget dapibus nisi orci et eros. Donec mollis lorem vitae dui porttitor pellentesque. Ut quis urna libero. Nunc eu faucibus sapien, sit amet tempus massa",
          4.2),
      ExpertReview(
          "Bo Burnham",
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut leo eu nibh pharetra interdum a et nunc. Aliquam erat volutpat. Morbi a nisl hendrerit, dignissim lorem sodales, condimentum libero. Nam bibendum felis iaculis, molestie neque pretium, finibus leo. Proin tellus elit, venenatis at velit pretium, aliquam imperdiet ante. Donec erat sapien, accumsan sit amet placerat eget, imperdiet id nunc. Nunc tempus, felis in efficitur gravida, mi risus tempor libero, eget dapibus nisi orci et eros. Donec mollis lorem vitae dui porttitor pellentesque. Ut quis urna libero. Nunc eu faucibus sapien, sit amet tempus massa",
          5.0),
      ExpertReview(
          "Billy Bob",
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut leo eu nibh pharetra interdum a et nunc. Aliquam erat volutpat. Morbi a nisl hendrerit, dignissim lorem sodales, condimentum libero. Nam bibendum felis iaculis, molestie neque pretium, finibus leo. Proin tellus elit, venenatis at velit pretium, aliquam imperdiet ante. Donec erat sapien, accumsan sit amet placerat eget, imperdiet id nunc. Nunc tempus, felis in efficitur gravida, mi risus tempor libero, eget dapibus nisi orci et eros. Donec mollis lorem vitae dui porttitor pellentesque. Ut quis urna libero. Nunc eu faucibus sapien, sit amet tempus massa",
          5.0),
    ];
  }

  @override
  State<ExpertReviews> createState() => _ExpertReviewsState();
}

class _ExpertReviewsState extends State<ExpertReviews> {
  List<ExpertReview> _reviews = ExpertReviews._fetchReviews();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          debugPrint('index: $index');
          return _reviews[index];
        });
  }
}
