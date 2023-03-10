import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_update_availability_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_expert_availability_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_connected_account_signup_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_update_rates_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_completed_calls_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_completed_calls_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_call_summary_page.dart';
import 'package:expertapp/src/screens/common_view/common_view_chat_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_expert_listings_page.dart';
import 'package:expertapp/src/screens/common_view/common_view_expert_profile_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_call_summary_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_review_submit_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_call_prompt_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_call_main_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_call_preview_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_call_main_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_signup_page.dart';
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
    initialLocation: Routes.HOME_PAGE,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final signedIn = lifecycle.authenticatedUser != null;
      final userExists = lifecycle.currentUserId() != null;

      if (!signedIn) {
        return state.location != Routes.SIGN_IN_PAGE
            ? Routes.SIGN_IN_PAGE
            : null;
      }
      if (!userExists) {
        return state.location != Routes.UV_USER_SIGNUP_PAGE
            ? Routes.UV_USER_SIGNUP_PAGE
            : null;
      }
      if (state.location == Routes.SIGN_IN_PAGE ||
          state.location == Routes.UV_USER_SIGNUP_PAGE) {
        return Routes.HOME_PAGE;
      }
      return null;
    },
    refreshListenable: lifecycle,
    routes: <GoRoute>[
      GoRoute(
        name: Routes.HOME_PAGE,
        path: Routes.HOME_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return UserViewExpertListingsPage(
              currentUserId: lifecycle.authenticatedUser!.uid);
        },
        routes: <GoRoute>[
          GoRoute(
              name: Routes.UV_EXPERT_PROFILE_PAGE,
              path:
                  Routes.UV_EXPERT_PROFILE_PAGE + '/:' + Routes.EXPERT_ID_PARAM,
              builder: (BuildContext context, GoRouterState state) {
                final expertId = state.params[Routes.EXPERT_ID_PARAM];
                return CommonViewExpertProfilePage(expertId!, false);
              },
              routes: <GoRoute>[
                GoRoute(
                  name: Routes.UV_EXPERT_CALL_PREVIEW_PAGE,
                  path: Routes.UV_EXPERT_CALL_PREVIEW_PAGE,
                  builder: (BuildContext context, GoRouterState state) {
                    final expertId = state.params[Routes.EXPERT_ID_PARAM];
                    return UserViewCallPreviewPage(expertId!);
                  },
                ),
              ]),
        ],
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
        name: Routes.UV_USER_SIGNUP_PAGE,
        path: Routes.UV_USER_SIGNUP_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return UserViewSignupPage();
        },
      ),
      GoRoute(
        name: Routes.EV_PROFILE_EDIT_PAGE,
        path: Routes.EV_PROFILE_EDIT_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return CommonViewExpertProfilePage(lifecycle.currentUserId()!, true);
        },
      ),
      GoRoute(
        name: Routes.UV_COMPLETED_CALLS_PAGE,
        path: Routes.UV_COMPLETED_CALLS_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return UserViewCompletedCallsPage(lifecycle.authenticatedUser!.uid);
        },
      ),
      GoRoute(
        name: Routes.EV_COMPLETED_CALLS_PAGE,
        path: Routes.EV_COMPLETED_CALLS_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return ExpertViewCompletedCallsPage(lifecycle.authenticatedUser!.uid);
        },
      ),
      GoRoute(
          name: Routes.UV_CALL_HOME_PAGE,
          path: Routes.UV_CALL_HOME_PAGE + '/:' + Routes.EXPERT_ID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final expertId = state.params[Routes.EXPERT_ID_PARAM];
            return UserViewCallMainPage(
                currentUserId: lifecycle.currentUserId()!,
                otherUserId: expertId!,
                lifecycle: lifecycle);
          },
          routes: <GoRoute>[
            GoRoute(
              name: Routes.UV_CALL_CHAT_PAGE,
              path: Routes.UV_CALL_CHAT_PAGE,
              builder: (BuildContext context, GoRouterState state) {
                final expertId = state.params[Routes.EXPERT_ID_PARAM];
                return CommonViewChatPage(
                    currentUserUid: lifecycle.currentUserId()!,
                    otherUserUid: expertId!);
              },
            ),
          ]),
      GoRoute(
          name: Routes.UV_REVIEW_SUBMIT_PAGE,
          path: Routes.UV_REVIEW_SUBMIT_PAGE + '/:' + Routes.EXPERT_ID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final expertUid = state.params[Routes.EXPERT_ID_PARAM];
            return UserViewReviewSubmitPage(
                currentUserId: lifecycle.currentUserId()!,
                expertUserId: expertUid!,
                lifecycle: lifecycle);
          }),
      GoRoute(
          name: Routes.UV_CALL_SUMMARY_PAGE,
          path: Routes.UV_CALL_SUMMARY_PAGE + '/:' + Routes.CALLED_UID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final calledUid = state.params[Routes.CALLED_UID_PARAM];
            return UserViewCallSummaryPage(otherUserId: calledUid!);
          }),
      GoRoute(
          name: Routes.EV_CALL_JOIN_PROMPT_PAGE,
          path: Routes.EV_CALL_JOIN_PROMPT_PAGE +
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
              Routes.CALL_JOIN_EXPIRATION_TIME_UTC_MS_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final callerUid = state.params[Routes.CALLER_UID_PARAM];
            final transactionId =
                state.params[Routes.CALL_TRANSACTION_ID_PARAM];
            final rateStartCents =
                int.parse(state.params[Routes.CALL_RATE_START_PARAM]!);
            final ratePerMinuteCents =
                int.parse(state.params[Routes.CALL_RATE_PER_MINUTE_PARAM]!);
            final callJoinExpirationTimeUtcMs = int.parse(
                state.params[Routes.CALL_JOIN_EXPIRATION_TIME_UTC_MS_PARAM]!);
            return ExpertViewCallPromptPage(
              transactionId: transactionId!,
              currentUserId: lifecycle.currentUserId()!,
              callerUserId: callerUid!,
              expertRate: ExpertRate(
                  centsCallStart: rateStartCents,
                  centsPerMinute: ratePerMinuteCents),
              callJoinExpirationTimeUtcMs: callJoinExpirationTimeUtcMs,
            );
          }),
      GoRoute(
          name: Routes.EV_CALL_HOME_PAGE,
          path: Routes.EV_CALL_HOME_PAGE +
              '/:' +
              Routes.CALLER_UID_PARAM +
              '/:' +
              Routes.CALL_TRANSACTION_ID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final callerUid = state.params[Routes.CALLER_UID_PARAM];
            final transactionId =
                state.params[Routes.CALL_TRANSACTION_ID_PARAM];
            return ExpertViewCallMainPage(
                callTransactionId: transactionId!,
                currentUserId: lifecycle.currentUserId()!,
                callerUserId: callerUid!);
          },
          routes: <GoRoute>[
            GoRoute(
              name: Routes.EV_CALL_CHAT_PAGE,
              path: Routes.EV_CALL_CHAT_PAGE,
              builder: (BuildContext context, GoRouterState state) {
                final callerUid = state.params[Routes.CALLER_UID_PARAM];
                return CommonViewChatPage(
                    currentUserUid: lifecycle.currentUserId()!,
                    otherUserUid: callerUid!);
              },
            ),
          ]),
      GoRoute(
          name: Routes.EV_CALL_SUMMARY_PAGE,
          path: Routes.EV_CALL_SUMMARY_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return ExpertViewCallSummaryPage();
          }),
      GoRoute(
          name: Routes.EV_UPDATE_RATE_PAGE,
          path: Routes.EV_UPDATE_RATE_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return ExpertViewUpdateRatesPage(uid: lifecycle.currentUserId()!);
          }),
      GoRoute(
          name: Routes.EV_UPDATE_AVAILABILITY_PAGE,
          path: Routes.EV_UPDATE_AVAILABILITY_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return ExpertViewUpdateAvailabilityPage(
                uid: lifecycle.currentUserId()!);
          }),
      GoRoute(
          name: Routes.UV_VIEW_EXPERT_AVAILABILITY_PAGE,
          path: Routes.UV_VIEW_EXPERT_AVAILABILITY_PAGE +
              '/:' +
              Routes.EXPERT_ID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final expertId = state.params[Routes.EXPERT_ID_PARAM];
            return UserViewExpertAvailabilityPage(uid: expertId!);
          }),
      GoRoute(
          name: Routes.EV_CONNECTED_ACCOUNT_SIGNUP_PAGE,
          path: Routes.EV_CONNECTED_ACCOUNT_SIGNUP_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return ExpertViewConnectedAccountSignupPage(
                uid: lifecycle.currentUserId()!);
          }),
    ],
  );
}