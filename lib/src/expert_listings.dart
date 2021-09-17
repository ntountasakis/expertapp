import 'package:expertapp/src/expert_listing_preview.dart';
import 'package:flutter/material.dart';

class ExpertListings extends StatefulWidget {
  @override
  _ExpertListingsState createState() => _ExpertListingsState();
}

class _ExpertListingsState extends State<ExpertListings> {
  final _experts = List<String>.generate(3, (index) => "Expert $index");

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _experts.length,
      itemBuilder: (context, index) {
        return ExpertListingPreview();
      },
    );
  }
}
