import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:flutter/material.dart';

class ExpertPricingCard extends StatelessWidget {
  final ExpertRate expertRate;
  final TextStyle pricingHeader =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  final TextStyle pricingContent =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

  ExpertPricingCard(this.expertRate);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Text(
          'Pricing',
          style: pricingHeader,
        ),
        Text(
          'Fee to Start Call: ' + expertRate.formattedStartCallFee(),
          style: pricingContent,
        ),
        Text(
          'Fee Per Minute: ' + expertRate.formattedPerMinuteFee(),
          style: pricingContent,
        )
      ],
    ));
  }
}
