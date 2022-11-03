import 'package:expertapp/src/agora/agora_video_call.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/chat_page.dart';
import 'package:expertapp/src/screens/expert_listings_page.dart';
import 'package:expertapp/src/screens/expert_profile_page.dart';
import 'package:expertapp/src/screens/expert_review_submit_page.dart';
import 'package:expertapp/src/screens/home_page.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:expertapp/src/screens/transaction/call_transaction_expert_prompt.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_main.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_preview.dart';
import 'package:expertapp/src/screens/transaction/expert/call_transaction_expert_main.dart';
import 'package:expertapp/src/screens/user_signup_page.dart';
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
      final userExists = lifecycle.userMetadata != null;

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
                return ExpertProfilePage(expertId!);
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
                currentUserId: lifecycle.userMetadata!.documentId,
                otherUserId: expertId!);
          },
          routes: <GoRoute>[
            GoRoute(
              name: Routes.EXPERT_CALL_CHAT_PAGE,
              path: Routes.EXPERT_CALL_CHAT_PAGE,
              builder: (BuildContext context, GoRouterState state) {
                final expertId = state.params[Routes.EXPERT_ID_PARAM];
                return ChatPage(
                    currentUserUid: lifecycle.userMetadata!.documentId,
                    otherUserUid: expertId!);
              },
            ),
            GoRoute(
              name: Routes.EXPERT_CALL_VIDEO_PAGE,
              path: Routes.EXPERT_CALL_VIDEO_PAGE +
                  '/:' +
                  Routes.AGORA_CHANNEL_NAME_PARAM +
                  '/:' +
                  Routes.AGORA_TOKEN_PARAM +
                  '/:' +
                  Routes.AGORA_UID_PARAM,
              builder: (BuildContext context, GoRouterState state) {
                final agoraChannelName =
                    state.params[Routes.AGORA_CHANNEL_NAME_PARAM];
                final agoraToken = state.params[Routes.AGORA_TOKEN_PARAM];
                final agoraUid = state.params[Routes.AGORA_UID_PARAM];
                return AgoraVideoCall(
                  agoraChannelName: agoraChannelName!,
                  agoraToken: agoraToken!,
                  agoraUid: int.parse(agoraUid!),
                );
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
                currentUserId: lifecycle.userMetadata!.documentId,
                expertUserId: expertUid!);
          }),
      GoRoute(
          name: Routes.CALL_JOIN_PROMPT_PAGE,
          path: Routes.CALL_JOIN_PROMPT_PAGE +
              '/:' +
              Routes.CALLED_UID_PARAM +
              '/:' +
              Routes.CALLER_UID_PARAM +
              '/:' +
              Routes.CALL_TRANSACTION_ID_PARAM,
          builder: (BuildContext context, GoRouterState state) {
            final callerUid = state.params[Routes.CALLER_UID_PARAM];
            final transactionId =
                state.params[Routes.CALL_TRANSACTION_ID_PARAM];
            return CallTransactionExpertPrompt(
                transactionId: transactionId!,
                currentUserId: lifecycle.userMetadata!.documentId,
                callerUserId: callerUid!);
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
                currentUserId: lifecycle.userMetadata!.documentId,
                callerUserId: callerUid!);
          },
          routes: <GoRoute>[
            GoRoute(
              name: Routes.CLIENT_CALL_CHAT_PAGE,
              path: Routes.CLIENT_CALL_CHAT_PAGE,
              builder: (BuildContext context, GoRouterState state) {
                final callerUid = state.params[Routes.CALLER_UID_PARAM];
                return ChatPage(
                    currentUserUid: lifecycle.userMetadata!.documentId,
                    otherUserUid: callerUid!);
              },
            ),
            GoRoute(
              name: Routes.CLIENT_CALL_VIDEO_PAGE,
              path: Routes.CLIENT_CALL_VIDEO_PAGE +
                  '/:' +
                  Routes.AGORA_CHANNEL_NAME_PARAM +
                  '/:' +
                  Routes.AGORA_TOKEN_PARAM +
                  '/:' +
                  Routes.AGORA_UID_PARAM,
              builder: (BuildContext context, GoRouterState state) {
                final agoraChannelName =
                    state.params[Routes.AGORA_CHANNEL_NAME_PARAM];
                final agoraToken = state.params[Routes.AGORA_TOKEN_PARAM];
                final agoraUid = state.params[Routes.AGORA_UID_PARAM];
                return AgoraVideoCall(
                  agoraChannelName: agoraChannelName!,
                  agoraToken: agoraToken!,
                  agoraUid: int.parse(agoraUid!),
                );
              },
            ),
          ]),
    ],
  );
}
