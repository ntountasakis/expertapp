import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_signup_progress.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HamburgerMenu extends StatelessWidget {
  final bool isSignedIn;
  final String? currentUserId;

  const HamburgerMenu({required this.isSignedIn, this.currentUserId});

  ListTile pastChatsTile(BuildContext context) {
    return ListTile(
        title: Text("Past Chats"),
        onTap: () {
          context.pushNamed(Routes.UV_PAST_CHATS);
        });
  }

  ListTile profileTile(BuildContext context) {
    return ListTile(
        title: Text("My Profile"),
        onTap: () {
          context.pushNamed(Routes.EV_PROFILE_EDIT_PAGE,
              pathParameters: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "false"});
        });
  }

  ListTile pastCallsWithExpertsTile(BuildContext context) {
    return ListTile(
        title: Text("Past Calls with Guides"),
        onTap: () {
          context.pushNamed(Routes.UV_COMPLETED_CALLS_PAGE);
        });
  }

  ListTile pastCallsWithClientsTile(BuildContext context) {
    return ListTile(
        title: Text("Past Calls with Clients"),
        onTap: () {
          context.pushNamed(Routes.EV_COMPLETED_CALLS_PAGE);
        });
  }

  ListTile updateCallPricesTile(BuildContext context) {
    return ListTile(
        title: Text("Update Call Prices"),
        onTap: () {
          context.pushNamed(Routes.EV_UPDATE_RATE_PAGE,
              pathParameters: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "false"});
        });
  }

  ListTile updateCallAvailabilityTile(BuildContext context) {
    return ListTile(
        title: Text("Update Call Availability Times"),
        onTap: () {
          context.pushNamed(Routes.EV_UPDATE_AVAILABILITY_PAGE,
              pathParameters: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "false"});
        });
  }

  ListTile updatePhoneNumberTile(BuildContext context) {
    return ListTile(
        title: Text("Update Contact Preferences"),
        onTap: () {
          context.pushNamed(Routes.EV_UPDATE_PHONE_NUMBER_PAGE,
              pathParameters: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "false"});
        });
  }

  ListTile platformFeesTile(BuildContext context) {
    return ListTile(
        title: Text("Platform Fees"),
        onTap: () {
          context.pushNamed(Routes.EV_PLATFORM_FEE_PAGE);
        });
  }

  ListTile stripeEarningsDashboard(BuildContext context) {
    return ListTile(
        title: Text("Stripe Earnings Dashboard"),
        onTap: () {
          context.pushNamed(Routes.EV_STRIPE_EARNINGS_DASHBOARD_PAGE);
        });
  }

  ListTile stripePaymentMethodsDashboard(BuildContext context) {
    return ListTile(
        title: Text("Manage Your Payment Methods"),
        onTap: () {
          context.pushNamed(Routes.UV_STRIPE_PAYMENT_METHODS_DASHBOARD);
        });
  }

  ListTile becomeAnExpertTile(BuildContext context) {
    return ListTile(
        title: Text("Become a Guide!"),
        onTap: () {
          context.pushNamed(Routes.EV_CONNECTED_ACCOUNT_SIGNUP_PAGE);
        });
  }

  ListTile finishSignUpExpertTile(
      BuildContext context, ExpertSignupProgress progress) {
    return ListTile(
        title: Text("Complete Guide Signup"),
        onTap: () {
          context.pushNamed(Routes.EV_CONNECTED_ACCOUNT_SIGNUP_PAGE);
          context.pushNamed(Routes.EV_UPDATE_PHONE_NUMBER_PAGE,
              pathParameters: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "true"});
          if (progress.updatedSmsPreferences) {
            context.pushNamed(Routes.EV_UPDATE_AVAILABILITY_PAGE,
                pathParameters: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "true"});
            if (progress.updatedAvailability) {
              context.pushNamed(Routes.EV_UPDATE_RATE_PAGE, pathParameters: {
                Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "true"
              });
              if (progress.updatedCallRate) {
                context.pushNamed(Routes.EV_PROFILE_EDIT_PAGE, pathParameters: {
                  Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "true"
                });
              }
            }
          }
        });
  }

  ListTile signOutTile(BuildContext context) {
    return ListTile(
        title: Text("Sign Out"),
        onTap: () async {
          await FirebaseAuth.FirebaseAuth.instance.signOut();
        });
  }

  ListTile createNoUserAccountSignInTile(BuildContext context) {
    final text =
        isSignedIn ? "Complete Account Signup" : "Create Account / Sign In";
    return ListTile(
        title: Text(text),
        onTap: () async {
          context.pushReplacementNamed(Routes.SIGN_IN_PAGE);
        });
  }

  ListTile deleteAccountTile(BuildContext context) {
    const style = TextStyle(color: Colors.red);
    return ListTile(
        title: Text(
          "Delete Account",
          style: style,
        ),
        onTap: () async {
          context.pushNamed(Routes.DELETE_ACCOUNT_PAGE);
        });
  }

  ListTile contactUsTile(BuildContext context) {
    return ListTile(
        title: Text(
          "Contact Us",
        ),
        onTap: () async {
          context.pushNamed(Routes.CONTACT_US_PAGE);
        });
  }

  Widget buildExpertMenu(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Color.fromRGBO(62, 82, 114, 1),
          ),
          child: Text("Main Menu"),
        ),
        profileTile(context),
        stripeEarningsDashboard(context),
        stripePaymentMethodsDashboard(context),
        pastCallsWithExpertsTile(context),
        pastCallsWithClientsTile(context),
        pastChatsTile(context),
        updateCallPricesTile(context),
        updateCallAvailabilityTile(context),
        updatePhoneNumberTile(context),
        platformFeesTile(context),
        contactUsTile(context),
        signOutTile(context),
        deleteAccountTile(context),
      ]),
    );
  }

  Widget buildMidSignUpExpertMenu(
      BuildContext context, ExpertSignupProgress progress) {
    return Drawer(
      child: ListView(children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Color.fromRGBO(62, 82, 114, 1),
          ),
          child: Text("Main Menu"),
        ),
        finishSignUpExpertTile(context, progress),
        contactUsTile(context),
        signOutTile(context),
        deleteAccountTile(context),
      ]),
    );
  }

  Widget buildRegularUserMenu(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Color.fromRGBO(62, 82, 114, 1),
          ),
          child: Text("Main Menu"),
        ),
        becomeAnExpertTile(context),
        pastCallsWithExpertsTile(context),
        pastChatsTile(context),
        stripePaymentMethodsDashboard(context),
        contactUsTile(context),
        signOutTile(context),
        deleteAccountTile(context),
      ]),
    );
  }

  Widget buildNoAccountMenu(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Color.fromRGBO(62, 82, 114, 1),
          ),
          child: Text("Main Menu"),
        ),
        createNoUserAccountSignInTile(context),
        contactUsTile(context),
        isSignedIn ? deleteAccountTile(context) : Container(),
        isSignedIn ? signOutTile(context) : Container(),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) return buildNoAccountMenu(context);
    return FutureBuilder<List<DocumentWrapper<dynamic>?>>(
      future: Future.wait([
        PublicExpertInfo.get(uid: currentUserId!, fromSignUpFlow: true),
        PublicExpertInfo.get(uid: currentUserId!, fromSignUpFlow: false),
        ExpertSignupProgress.get(uid: currentUserId!),
      ]),
      builder: (BuildContext context,
          AsyncSnapshot<List<DocumentWrapper<dynamic>?>> snapshot) {
        if (snapshot.hasData) {
          final stagingExpertInfo = snapshot.data![0];
          final publicExpertInfo = snapshot.data![1];
          final expertSignupProgress = snapshot.data![2];
          if (stagingExpertInfo != null && expertSignupProgress != null) {
            final signupWrapper =
                snapshot.data![2] as DocumentWrapper<ExpertSignupProgress>;
            return buildMidSignUpExpertMenu(
                context, signupWrapper.documentType);
          } else if (publicExpertInfo != null) {
            return buildExpertMenu(context);
          } else {
            return buildRegularUserMenu(context);
          }
        } else {
          return buildRegularUserMenu(context);
        }
      },
    );
  }
}
