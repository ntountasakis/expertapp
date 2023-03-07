import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/util/expert_availability_util.dart';
import 'package:flutter/material.dart';

class UserViewExpertAvailabilityPage extends StatelessWidget {
  final String uid;

  const UserViewExpertAvailabilityPage({required this.uid});

  Widget buildAvailabilityView() {
    return FutureBuilder(
        future: PublicExpertInfo.get(uid),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
          if (snapshot.hasData) {
            DocumentWrapper<PublicExpertInfo?> info = snapshot.data!;
            if (info.documentType == null) {
              throw Exception("No expert info found for uid $uid");
            }
            return Column(
              children: [
                SizedBox(height: 20),
                ExpertAvailabilityUtil.buildTimeSummary(
                    context: context,
                    availability: info.documentType!.availability,
                    title: "You can call them during these times"),
              ],
            );
          }
          return CircularProgressIndicator();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Availability for accepting calls"),
        ),
        body: Container(
          child: buildAvailabilityView(),
        ));
  }
}
