import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:flutter/material.dart';

class ExpertPricingCard extends StatelessWidget {
  final ExpertRate expertRate;
  final TextStyle pricingHeader =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  final TextStyle pricingContent =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

  ExpertPricingCard(this.expertRate);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Text(
          'Call Pricing',
          style: pricingHeader,
        ),
        Text(
          'Rate: ' + expertRate.formattedRate(),
          style: pricingContent,
        )
      ],
    ));
  }
}
