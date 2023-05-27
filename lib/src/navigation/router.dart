import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/preferences/preferences.dart';
import 'package:expertapp/src/screens/common_view/common_view_contact_us_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_call_join_expired_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_expert_profile_page.dart';
import 'package:expertapp/src/screens/auth/sign_in_page.dart';
import 'package:expertapp/src/screens/common_view/common_view_delete_account_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_show_platform_fee_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_update_availability_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_update_phone_number_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_update_phone_number_sign_up_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_update_rates_sign_up_page.dart';
import 'package:expertapp/src/screens/user_view/past_chats_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_stripe_earnings_dashboard.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_update_availability_sign_up_page.dart';
import 'package:expertapp/src/screens/intro/onboarding_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_expert_availability_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_connected_account_signup_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_update_rates_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_completed_calls_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_completed_calls_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_call_summary_page.dart';
import 'package:expertapp/src/screens/common_view/common_view_chat_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_expert_listings_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_expert_profile_sign_up_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_call_summary_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_expert_profile_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_review_submit_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_call_join_prompt_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_call_main_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_call_preview_page.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_call_main_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_signup_page.dart';
import 'package:expertapp/src/screens/user_view/user_view_stripe_payment_methods_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AppLifecycle lifecycle;
  final GlobalKey<NavigatorState> navigatorKey;

  GoRouter get goRouter => _goRouter;

  AppRouter(this.lifecycle, this.navigatorKey);

  late final GoRouter _goRouter = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.ONBOARDING,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final signedIn = lifecycle.authenticatedUser != null;
      final userExists = lifecycle.currentUserId() != null;

      if (state.location == Routes.ONBOARDING) {
        if (await Preferences.shouldShowOnboarding()) {
          return null;
        }
        return Routes.HOME_PAGE;
      }

      if (state.location == Routes.DELETE_ACCOUNT_PAGE && !signedIn) {
        return Routes.HOME_PAGE;
      }

      if (state.location != Routes.UV_USER_SIGNUP_PAGE &&
          state.location != Routes.SIGN_IN_PAGE) {
        return null;
      }

      if (userExists) {
        return Routes.HOME_PAGE;
      }
      if (signedIn) {
        return Routes.UV_USER_SIGNUP_PAGE;
      }
      return Routes.SIGN_IN_PAGE;
    },
    refreshListenable: lifecycle,
    routes: <GoRoute>[
      GoRoute(
        name: Routes.ONBOARDING,
        path: Routes.ONBOARDING,
        builder: (BuildContext context, GoRouterState state) {
          return OnBoardingPage();
        },
      ),
      GoRoute(
        name: Routes.CONTACT_US_PAGE,
        path: Routes.CONTACT_US_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return CommonViewContactUsPage();
        },
      ),
      GoRoute(
        name: Routes.HOME_PAGE,
        path: Routes.HOME_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return UserViewExpertListingsPage(
              isSignedIn: lifecycle.authenticatedUser != null,
              currentUserId: lifecycle.currentUserId());
        },
        routes: <GoRoute>[
          GoRoute(
              name: Routes.UV_EXPERT_PROFILE_PAGE,
              path:
                  Routes.UV_EXPERT_PROFILE_PAGE + '/:' + Routes.EXPERT_ID_PARAM,
              builder: (BuildContext context, GoRouterState state) {
                final expertId = state.pathParameters[Routes.EXPERT_ID_PARAM];
                return UserViewExpertProfilePage(
                    key: ValueKey(expertId),
                    currentUid: lifecycle.currentUserId(),
                    expertUid: expertId!);
              },
              routes: <GoRoute>[
                GoRoute(
                  name: Routes.UV_EXPERT_CALL_PREVIEW_PAGE,
                  path: Routes.UV_EXPERT_CALL_PREVIEW_PAGE,
                  builder: (BuildContext context, GoRouterState state) {
                    final expertId =
                        state.pathParameters[Routes.EXPERT_ID_PARAM];
                    return UserViewCallPreviewPage(expertId!);
                  },
                ),
              ]),
        ],
      ),
      GoRoute(
          path: Routes.SIGN_IN_PAGE,
          name: Routes.SIGN_IN_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return SignInPage();
          }),
      GoRoute(
          name: Routes.DELETE_ACCOUNT_PAGE,
          path: Routes.DELETE_ACCOUNT_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return CommonViewDeleteAccountPage();
          }),
      GoRoute(
        name: Routes.UV_USER_SIGNUP_PAGE,
        path: Routes.UV_USER_SIGNUP_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return UserViewSignupPage(
              firstName: lifecycle.getFirstName(),
              lastName: lifecycle.getLastName(),
              email: lifecycle.getEmail());
        },
      ),
      GoRoute(
        name: Routes.EV_PROFILE_EDIT_PAGE,
        path: Routes.EV_PROFILE_EDIT_PAGE +
            '/:' +
            Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM,
        builder: (BuildContext context, GoRouterState state) {
          final fromSignupFlow =
              state.pathParameters[Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM];
          if (fromSignupFlow == 'true') {
            return ExpertViewExpertProfileSignUpPage(
                expertUid: lifecycle.currentUserId()!);
          } else {
            return ExpertViewExpertProfilePage(
                expertUid: lifecycle.currentUserId()!);
          }
        },
      ),
      GoRoute(
        name: Routes.UV_COMPLETED_CALLS_PAGE,
        path: Routes.UV_COMPLETED_CALLS_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return UserViewCompletedCallsPage(lifecycle.currentUserId()!);
        },
      ),
      GoRoute(
        name: Routes.EV_COMPLETED_CALLS_PAGE,
        path: Routes.EV_COMPLETED_CALLS_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return ExpertViewCompletedCallsPage(lifecycle.currentUserId()!);
        },
      ),
      GoRoute(
          name: Routes.UV_CALL_HOME_PAGE,
          path: Routes.UV_CALL_HOME_PAGE +
              '/:' +
              Routes.EXPERT_ID_PARAM +
              '/:' +
              Routes.OTHER_USER_SHORT_NAME,
          builder: (BuildContext context, GoRouterState state) {
            final expertId = state.pathParameters[Routes.EXPERT_ID_PARAM];
            final otherUserShortName =
                state.pathParameters[Routes.OTHER_USER_SHORT_NAME];
            return UserViewCallMainPage(
                currentUserId: lifecycle.currentUserId()!,
                otherUserId: expertId!,
                otherUserShortName: otherUserShortName!,
                lifecycle: lifecycle);
          },
          routes: <GoRoute>[
            GoRoute(
              name: Routes.UV_CALL_CHAT_PAGE,
              path: Routes.UV_CALL_CHAT_PAGE + '/:' + Routes.IS_EDITABLE_PARAM,
              builder: (BuildContext context, GoRouterState state) {
                final expertId = state.pathParameters[Routes.EXPERT_ID_PARAM];
                final isEditable =
                    state.pathParameters[Routes.IS_EDITABLE_PARAM];
                final otherUserShortName =
                    state.pathParameters[Routes.OTHER_USER_SHORT_NAME];
                return CommonViewChatPage(
                  currentUserUid: lifecycle.currentUserId()!,
                  otherUserUid: expertId!,
                  otherUserShortName: otherUserShortName!,
                  isEditable: isEditable! == 'true',
                );
              },
            ),
          ]),
      GoRoute(
          name: Routes.UV_REVIEW_SUBMIT_PAGE,
          path: Routes.UV_REVIEW_SUBMIT_PAGE + '/:' + Routes.EXPERT_ID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final expertUid = state.pathParameters[Routes.EXPERT_ID_PARAM];
            return UserViewReviewSubmitPage(
                currentUserId: lifecycle.currentUserId()!,
                expertUserId: expertUid!,
                lifecycle: lifecycle);
          }),
      GoRoute(
          name: Routes.UV_CALL_SUMMARY_PAGE,
          path: Routes.UV_CALL_SUMMARY_PAGE + '/:' + Routes.CALLED_UID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final calledUid = state.pathParameters[Routes.CALLED_UID_PARAM];
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
            final callerUid = state.pathParameters[Routes.CALLER_UID_PARAM];
            final transactionId =
                state.pathParameters[Routes.CALL_TRANSACTION_ID_PARAM];
            final rateStartCents =
                int.parse(state.pathParameters[Routes.CALL_RATE_START_PARAM]!);
            final ratePerMinuteCents = int.parse(
                state.pathParameters[Routes.CALL_RATE_PER_MINUTE_PARAM]!);
            final callJoinExpirationTimeUtcMs = int.parse(state.pathParameters[
                Routes.CALL_JOIN_EXPIRATION_TIME_UTC_MS_PARAM]!);
            return ExpertViewCallJoinPromptPage(
              callJoinExpirationTimeUtcMs: callJoinExpirationTimeUtcMs,
              transactionId: transactionId!,
              callerUserId: callerUid!,
              expertRate: ExpertRate(
                  centsCallStart: rateStartCents,
                  centsPerMinute: ratePerMinuteCents),
            );
          }),
      GoRoute(
          name: Routes.EV_CALL_JOIN_EXPIRED_PAGE,
          path: Routes.EV_CALL_JOIN_EXPIRED_PAGE +
              '/:' +
              Routes.CALL_TRANSACTION_ID_PARAM +
              '/:' +
              Routes.OTHER_USER_SHORT_NAME,
          builder: (BuildContext context, GoRouterState state) {
            final transactionId =
                state.pathParameters[Routes.CALL_TRANSACTION_ID_PARAM];
            final callerShortName =
                state.pathParameters[Routes.OTHER_USER_SHORT_NAME];
            return ExpertViewCallJoinExpiredPage(
              callerShortName: callerShortName!,
              callTransactionId: transactionId!,
            );
          }),
      GoRoute(
          name: Routes.EV_CALL_HOME_PAGE,
          path: Routes.EV_CALL_HOME_PAGE +
              '/:' +
              Routes.CALLER_UID_PARAM +
              '/:' +
              Routes.CALL_TRANSACTION_ID_PARAM +
              '/:' +
              Routes.OTHER_USER_SHORT_NAME,
          builder: (BuildContext context, GoRouterState state) {
            final callerUid = state.pathParameters[Routes.CALLER_UID_PARAM];
            final transactionId =
                state.pathParameters[Routes.CALL_TRANSACTION_ID_PARAM];
            final callerShortName =
                state.pathParameters[Routes.OTHER_USER_SHORT_NAME];
            return ExpertViewCallMainPage(
              callTransactionId: transactionId!,
              currentUserId: lifecycle.currentUserId()!,
              callerUserId: callerUid!,
              callerShortName: callerShortName!,
            );
          },
          routes: <GoRoute>[
            GoRoute(
              name: Routes.EV_CALL_CHAT_PAGE,
              path: Routes.EV_CALL_CHAT_PAGE,
              builder: (BuildContext context, GoRouterState state) {
                final callerUid = state.pathParameters[Routes.CALLER_UID_PARAM];
                final otherUserShortName =
                    state.pathParameters[Routes.OTHER_USER_SHORT_NAME];
                return CommonViewChatPage(
                  currentUserUid: lifecycle.currentUserId()!,
                  otherUserUid: callerUid!,
                  otherUserShortName: otherUserShortName!,
                  isEditable: true,
                );
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
          path: Routes.EV_UPDATE_RATE_PAGE +
              '/:' +
              Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final fromSignupFlow =
                state.pathParameters[Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM];
            if (fromSignupFlow == 'true') {
              return ExpertViewUpdateRatesSignUpPage(
                  uid: lifecycle.currentUserId()!);
            } else {
              return ExpertViewUpdateRatesPage(uid: lifecycle.currentUserId()!);
            }
          }),
      GoRoute(
          name: Routes.EV_UPDATE_AVAILABILITY_PAGE,
          path: Routes.EV_UPDATE_AVAILABILITY_PAGE +
              '/:' +
              Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final fromSignupFlow =
                state.pathParameters[Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM];
            if (fromSignupFlow == 'true') {
              return ExpertViewUpdateAvailabilitySignUpPage(
                  uid: lifecycle.currentUserId()!);
            } else {
              return ExpertViewUpdateAvailabilityPage(
                  uid: lifecycle.currentUserId()!);
            }
          }),
      GoRoute(
          name: Routes.EV_UPDATE_PHONE_NUMBER_PAGE,
          path: Routes.EV_UPDATE_PHONE_NUMBER_PAGE +
              '/:' +
              Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final fromSignupFlow =
                state.pathParameters[Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM];
            if (fromSignupFlow == 'true') {
              return ExpertViewUpdatePhoneNumberSignUpPage(
                  uid: lifecycle.currentUserId()!);
            } else {
              return ExpertViewUpdatePhoneNumberPage(
                  uid: lifecycle.currentUserId()!);
            }
          }),
      GoRoute(
          name: Routes.UV_VIEW_EXPERT_AVAILABILITY_PAGE,
          path: Routes.UV_VIEW_EXPERT_AVAILABILITY_PAGE +
              '/:' +
              Routes.EXPERT_ID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final expertId = state.pathParameters[Routes.EXPERT_ID_PARAM];
            return UserViewExpertAvailabilityPage(uid: expertId!);
          }),
      GoRoute(
          name: Routes.UV_PAST_CHATS,
          path: Routes.UV_PAST_CHATS,
          builder: (BuildContext context, GoRouterState state) {
            return PastChatsPage(uid: lifecycle.currentUserId()!);
          }),
      GoRoute(
          name: Routes.EV_CONNECTED_ACCOUNT_SIGNUP_PAGE,
          path: Routes.EV_CONNECTED_ACCOUNT_SIGNUP_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return ExpertViewConnectedAccountSignupPage(
                uid: lifecycle.currentUserId()!);
          }),
      GoRoute(
          name: Routes.EV_STRIPE_EARNINGS_DASHBOARD_PAGE,
          path: Routes.EV_STRIPE_EARNINGS_DASHBOARD_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return ExpertViewStripeEarningsDashboard(
                uid: lifecycle.currentUserId()!);
          }),
      GoRoute(
          name: Routes.EV_PLATFORM_FEE_PAGE,
          path: Routes.EV_PLATFORM_FEE_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            return ExpertViewShowPlatformFeePage();
          }),
      GoRoute(
          name: Routes.UV_STRIPE_PAYMENT_METHODS_DASHBOARD,
          path: Routes.UV_STRIPE_PAYMENT_METHODS_DASHBOARD,
          builder: (BuildContext context, GoRouterState state) {
            return UserViewStripeBillingDashboard(
                uid: lifecycle.currentUserId()!);
          }),
    ],
  );
}
