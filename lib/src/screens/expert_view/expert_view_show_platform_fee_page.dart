import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:flutter/material.dart';

class ExpertViewShowPlatformFeePage extends StatelessWidget {
  const ExpertViewShowPlatformFeePage({Key? key}) : super(key: key);

  Widget buildPlatformFeeCard(double platformFee) {
    return Card(
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 80.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.0),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[600]!,
                    Colors.blue[800]!,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Pricing Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "For every call you make through our platform, we charge a ${platformFee}% fee deducted from the call earnings. This fee helps us maintain and improve the quality of our service and earn a profit.",
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'We believe that transparency is key when it comes to pricing. If you have any questions or concerns about our pricing structure, please don\'t hesitate to reach out to our customer support team. We\'re here to help!',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlatformFeePage(double? platformFee) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Platform Fee'),
      ),
      body: Center(
        child: platformFee == null
            ? CircularProgressIndicator()
            : buildPlatformFeeCard(platformFee),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getPlatformPercentFee(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final platformPercentFee = snapshot.data as double;
          return buildPlatformFeePage(platformPercentFee);
        }
        return buildPlatformFeePage(null);
      },
    );
  }
}
