import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/expert/expert_availability_update_page.dart';
import 'package:expertapp/src/screens/expert/expert_availability_view_page.dart';
import 'package:expertapp/src/screens/expert/expert_connected_account_signup.dart';
import 'package:expertapp/src/screens/expert/expert_rate_page.dart';
import 'package:expertapp/src/screens/history/completed_incoming_calls_page.dart';
import 'package:expertapp/src/screens/history/completed_outgoing_calls_page.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_summary.dart';
import 'package:expertapp/src/screens/transaction/common/chat_page.dart';
import 'package:expertapp/src/screens/expert/expert_listings_page.dart';
import 'package:expertapp/src/screens/expert/expert_profile_page.dart';
import 'package:expertapp/src/screens/transaction/expert/call_expert_summary.dart';
import 'package:expertapp/src/screens/transaction/expert/expert_review_submit_page.dart';
import 'package:expertapp/src/screens/home_page.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:expertapp/src/screens/transaction/expert/call_transaction_expert_prompt.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_main.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_preview.dart';
import 'package:expertapp/src/screens/transaction/expert/call_transaction_expert_main.dart';
import 'package:expertapp/src/screens/user/user_signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AppLifecycle lifecycle;
  final GlobalKey<NavigatorState> navigatorKey;

  GoRouter get goRouter => _goRouter;

  AppRouter(this.lifecycle, this.navigatorKey);

  late final GoRouter _goRouter = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.HOME,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final signedIn = lifecycle.authenticatedUser != null;
      final userExists = lifecycle.publicExpertInfo != null;

      if (!signedIn) {
        return state.location != Routes.SIGN_IN_PAGE
            ? Routes.SIGN_IN_PAGE
            : null;
      }
      if (!userExists) {
        return state.location != Routes.USER_CREATE_PAGE
            ? Routes.USER_CREATE_PAGE
            : null;
      }
      if (state.location == Routes.SIGN_IN_PAGE ||
          state.location == Routes.USER_CREATE_PAGE) {
        return Routes.EXPERT_LISTINGS_PAGE;
      }
      return null;
    },
    refreshListenable: lifecycle,
    routes: <GoRoute>[
      GoRoute(
        name: Routes.HOME,
        path: Routes.HOME,
        builder: (BuildContext context, GoRouterState state) {
          return HomePage();
        },
      ),
      GoRoute(
          path: Routes.SIGN_IN_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return SignInScreen(providerConfigs: [
              EmailProviderConfiguration(),
              GoogleProviderConfiguration(
                clientId:
                    '111394228371-4slr6ceip09bqefipq2ikbvribtj93qj.apps.googleusercontent.com',
              ),
              FacebookProviderConfiguration(
                clientId: '294313229392786',
              )
            ]);
          }),
      GoRoute(
        name: Routes.USER_CREATE_PAGE,
        path: Routes.USER_CREATE_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return UserSignupPage();
        },
      ),
      GoRoute(
        name: Routes.USER_PROFILE_PAGE,
        path: Routes.USER_PROFILE_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return ExpertProfilePage(
              lifecycle.publicExpertInfo!.documentId, true);
        },
      ),
      GoRoute(
        name: Routes.USER_COMPLETED_CALLS,
        path: Routes.USER_COMPLETED_CALLS,
        builder: (BuildContext context, GoRouterState state) {
          return CompletedOutgoingCallsPage(lifecycle.authenticatedUser!.uid);
        },
      ),
      GoRoute(
        name: Routes.CLIENT_COMPLETED_CALLS,
        path: Routes.CLIENT_COMPLETED_CALLS,
        builder: (BuildContext context, GoRouterState state) {
          return CompletedIncomingCallsPage(lifecycle.authenticatedUser!.uid);
        },
      ),
      GoRoute(
        name: Routes.EXPERT_LISTINGS_PAGE,
        path: Routes.EXPERT_LISTINGS_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return ExpertListingsPage();
        },
        routes: <GoRoute>[
          GoRoute(
              name: Routes.EXPERT_PROFILE_PAGE,
              path: Routes.EXPERT_PROFILE_PAGE + '/:' + Routes.EXPERT_ID_PARAM,
              builder: (BuildContext context, GoRouterState state) {
                final expertId = state.params[Routes.EXPERT_ID_PARAM];
                return ExpertProfilePage(expertId!, false);
              },
              routes: <GoRoute>[
                GoRoute(
                  name: Routes.EXPERT_CALL_PREVIEW_PAGE,
                  path: Routes.EXPERT_CALL_PREVIEW_PAGE,
                  builder: (BuildContext context, GoRouterState state) {
                    final expertId = state.params[Routes.EXPERT_ID_PARAM];
                    return CallClientPreview(expertId!);
                  },
                ),
              ]),
        ],
      ),
      GoRoute(
          name: Routes.EXPERT_CALL_HOME_PAGE,
          path: Routes.EXPERT_CALL_HOME_PAGE + '/:' + Routes.EXPERT_ID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final expertId = state.params[Routes.EXPERT_ID_PARAM];
            return CallClientMain(
                currentUserId: lifecycle.publicExpertInfo!.documentId,
                otherUserId: expertId!,
                lifecycle: lifecycle);
          },
          routes: <GoRoute>[
            GoRoute(
              name: Routes.EXPERT_CALL_CHAT_PAGE,
              path: Routes.EXPERT_CALL_CHAT_PAGE,
              builder: (BuildContext context, GoRouterState state) {
                final expertId = state.params[Routes.EXPERT_ID_PARAM];
                return ChatPage(
                    currentUserUid: lifecycle.publicExpertInfo!.documentId,
                    otherUserUid: expertId!);
              },
            ),
          ]),
      GoRoute(
          name: Routes.EXPERT_REVIEW_SUBMIT_PAGE,
          path:
              Routes.EXPERT_REVIEW_SUBMIT_PAGE + '/:' + Routes.EXPERT_ID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final expertUid = state.params[Routes.EXPERT_ID_PARAM];
            return ExpertReviewSubmitPage(
                currentUserId: lifecycle.publicExpertInfo!.documentId,
                expertUserId: expertUid!,
                lifecycle: lifecycle);
          }),
      GoRoute(
          name: Routes.EXPERT_CALL_SUMMARY_PAGE,
          path:
              Routes.EXPERT_CALL_SUMMARY_PAGE + '/:' + Routes.CALLED_UID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final calledUid = state.params[Routes.CALLED_UID_PARAM];
            return CallClientSummary(otherUserId: calledUid!);
          }),
      GoRoute(
          name: Routes.CALL_JOIN_PROMPT_PAGE,
          path: Routes.CALL_JOIN_PROMPT_PAGE +
              '/:' +
              Routes.CALLED_UID_PARAM +
              '/:' +
              Routes.CALLER_UID_PARAM +
              '/:' +
              Routes.CALL_TRANSACTION_ID_PARAM +
              '/:' +
              Routes.CALL_RATE_START_PARAM +
              '/:' +
              Routes.CALL_RATE_PER_MINUTE_PARAM +
              '/:' +
              Routes.CALL_JOIN_EXPIRATION_TIME_UTC_MS,
          builder: (BuildContext context, GoRouterState state) {
            final callerUid = state.params[Routes.CALLER_UID_PARAM];
            final transactionId =
                state.params[Routes.CALL_TRANSACTION_ID_PARAM];
            final rateStartCents =
                int.parse(state.params[Routes.CALL_RATE_START_PARAM]!);
            final ratePerMinuteCents =
                int.parse(state.params[Routes.CALL_RATE_PER_MINUTE_PARAM]!);
            final callJoinExpirationTimeUtcMs = int.parse(
                state.params[Routes.CALL_JOIN_EXPIRATION_TIME_UTC_MS]!);
            return CallTransactionExpertPrompt(
              transactionId: transactionId!,
              currentUserId: lifecycle.publicExpertInfo!.documentId,
              callerUserId: callerUid!,
              expertRate: ExpertRate(
                  centsCallStart: rateStartCents,
                  centsPerMinute: ratePerMinuteCents),
              callJoinExpirationTimeUtcMs: callJoinExpirationTimeUtcMs,
            );
          }),
      GoRoute(
          name: Routes.CLIENT_CALL_HOME,
          path: Routes.CLIENT_CALL_HOME +
              '/:' +
              Routes.CALLER_UID_PARAM +
              '/:' +
              Routes.CALL_TRANSACTION_ID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final callerUid = state.params[Routes.CALLER_UID_PARAM];
            final transactionId =
                state.params[Routes.CALL_TRANSACTION_ID_PARAM];
            return CallTransactionExpertMain(
                callTransactionId: transactionId!,
                currentUserId: lifecycle.publicExpertInfo!.documentId,
                callerUserId: callerUid!);
          },
          routes: <GoRoute>[
            GoRoute(
              name: Routes.CLIENT_CALL_CHAT_PAGE,
              path: Routes.CLIENT_CALL_CHAT_PAGE,
              builder: (BuildContext context, GoRouterState state) {
                final callerUid = state.params[Routes.CALLER_UID_PARAM];
                return ChatPage(
                    currentUserUid: lifecycle.publicExpertInfo!.documentId,
                    otherUserUid: callerUid!);
              },
            ),
          ]),
      GoRoute(
          name: Routes.CLIENT_SUMMARY_PAGE,
          path: Routes.CLIENT_SUMMARY_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return CallExpertSummary();
          }),
      GoRoute(
          name: Routes.EXPERT_UPDATE_RATE_PAGE,
          path: Routes.EXPERT_UPDATE_RATE_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return ExpertRatePage(uid: lifecycle.publicExpertInfo!.documentId);
          }),
      GoRoute(
          name: Routes.EXPERT_UPDATE_AVAILABILITY_PAGE,
          path: Routes.EXPERT_UPDATE_AVAILABILITY_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return ExpertAvailabilityUpdatePage(
                uid: lifecycle.publicExpertInfo!.documentId);
          }),
      GoRoute(
          name: Routes.EXPERT_VIEW_AVAILABILITY_PAGE,
          path: Routes.EXPERT_VIEW_AVAILABILITY_PAGE +
              '/:' +
              Routes.EXPERT_ID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final expertId = state.params[Routes.EXPERT_ID_PARAM];
            return ExpertAvailabilityViewPage(uid: expertId!);
          }),
      GoRoute(
          name: Routes.EXPERT_CONNECTED_ACCOUNT_SIGNUP_PAGE,
          path: Routes.EXPERT_CONNECTED_ACCOUNT_SIGNUP_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return ExpertConnectedAccountSignup(
                uid: lifecycle.publicExpertInfo!.documentId);
          }),
    ],
  );
}
