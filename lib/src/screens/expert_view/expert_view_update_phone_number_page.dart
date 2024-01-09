import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/private_user_info.dart';
import 'package:expertapp/src/profile/expert/expert_phone_number_picker.dart';
import 'package:flutter/material.dart';

class ExpertViewUpdatePhoneNumberPage extends StatelessWidget {
  final String uid;
  const ExpertViewUpdatePhoneNumberPage({Key? key, required this.uid})
      : super(key: key);

  Widget buildBody(BuildContext context, PrivateUserInfo privateUserInfo) {
    return Column(
      children: [
        ExpertPhoneNumberPicker(
          key: Key('expert_phone_number_picker'),
          initialPhoneNumber: privateUserInfo.phoneNumber,
          initialPhoneNumberIsoCode: privateUserInfo.phoneNumberIsoCode,
          initialConsentStatus: privateUserInfo.consentsToSms,
          fromSignUpFlow: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            "Update Contact Preferences",
          ),
        )),
        body: FutureBuilder(
            future: PrivateUserInfo.get(uid),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentWrapper<PrivateUserInfo>?> snapshot) {
              if (snapshot.hasData) {
                return buildBody(context, snapshot.data!.documentType);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
