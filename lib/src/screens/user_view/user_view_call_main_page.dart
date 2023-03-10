import 'package:expertapp/src/agora/agora_rtc_engine_wrapper.dart';
import 'package:expertapp/src/agora/agora_video_call.dart';
import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/appbars/user_view/client_in_call_appbar.dart';
import 'package:expertapp/src/util/call_summary_util.dart';
import 'package:expertapp/src/util/call_waiting_join.dart';
import 'package:expertapp/src/util/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class UserViewCallMainPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final AppLifecycle lifecycle;

  const UserViewCallMainPage(
      {required this.currentUserId,
      required this.otherUserId,
      required this.lifecycle});

  @override
  State<UserViewCallMainPage> createState() =>
      _UserViewCallMainPageState(new CallServerManager(
          currentUserId: currentUserId, otherUserId: otherUserId));
}

class _UserViewCallMainPageState extends State<UserViewCallMainPage> {
  final CallServerManager callServerManager;
  bool requestedExit = false;
  bool exiting = false;
  final RtcEngineWrapper engineWrapper = RtcEngineWrapper();
  AgoraVideoCall? videoCall;

  _UserViewCallMainPageState(this.callServerManager);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callServerManager.initiateCall(context);
    });
  }

  Widget buildVideoCallView(BuildContext context, CallServerModel model) {
    if (model.agoraCredentials == null ||
        model.callCounterpartyConnectionState ==
            CallServerCounterpartyConnectionState.DISCONNECTED) {
      return CircularProgressIndicator();
    } else if (videoCall == null) {
      final agoraChannelName = model.agoraCredentials!.channelName;
      final agoraToken = model.agoraCredentials!.token;
      final agoraUid = model.agoraCredentials!.uid;
      videoCall = AgoraVideoCall(
        agoraChannelName: agoraChannelName,
        agoraToken: agoraToken,
        agoraUid: agoraUid,
        onChatButtonTap: onChatButtonTap,
        onEndCallButtonTap: onEndCallTap,
        engineWrapper: engineWrapper,
      );
    }
    return videoCall!;
  }

  void onChatButtonTap() {
    context.pushNamed(Routes.UV_CALL_CHAT_PAGE,
        params: {Routes.EXPERT_ID_PARAM: widget.otherUserId});
  }

  Future<void> onEndCallTap() async {
    requestedExit = true;
    await callServerManager.requestDisconnect();
  }

  Future<void> onPaymentCancelled(
      BuildContext context, CallServerModel model) async {
    if (!requestedExit) {
      requestedExit = true;
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        await callServerManager.requestDisconnect();
      });
    }
  }

  void onServerDisconnect(CallServerModel model) {
    if (!exiting) {
      exiting = true;
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        if (videoCall != null) {
          await engineWrapper.teardown();
        }
        final counterpartyJoined = model.callCounterpartyConnectionState ==
            CallServerCounterpartyConnectionState.JOINED;
        if (counterpartyJoined) {
          context.goNamed(Routes.UV_CALL_SUMMARY_PAGE,
              params: {Routes.CALLED_UID_PARAM: widget.otherUserId});
        } else {
          model.reset();
          context.goNamed(Routes.HOME_PAGE);
        }
      });
    }
  }

  Widget buildAwaitingPaymentView(CallServerModel model) {
    final paymentPrompt =
        "We are requesting a hold on your card for the amount of ${formattedRate(model.callPaymentPromptModel.centsRequestedAuthorized)}. "
        "At the end of the call, we will charge your card for the actual amount of time you were connected to the expert. "
        "The call can last a maximum of ${CallSummaryUtil.callLengthFormat(Duration(seconds: model.secMaxCallLength))}. "
        "Once that time has elapsed, the call will automatically end.";
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              paymentPrompt,
              style: CallSummaryUtil.LIGHT_STYLE,
            ),
          ),
          SizedBox(height: 20),
          CallSummaryUtil.buildButton(model, "Authorize Payment Hold",
              (_) async {
            await model.callPaymentPromptModel.presentPaymentSheet();
          }),
          SizedBox(height: 20),
          CallSummaryUtil.buildButton(model, "Cancel Call", (_) async {
            await callServerManager.requestDisconnect();
          }),
        ],
      ),
    );
  }

  Widget buildErrorView(BuildContext context, CallServerModel model) {
    // not going to work, needs to be called only once from the event
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("There was an error connecting to the server."),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  onServerDisconnect(model);
                },
              )
            ],
          );
        });
    return SizedBox();
  }

  Widget buildCallView(BuildContext context, CallServerModel model,
      DocumentWrapper<PublicExpertInfo> calledMetadata) {
    if (model.callConnectionState == CallServerConnectionState.DISCONNECTED) {
      onServerDisconnect(model);
      return SizedBox();
    }
    if (model.callConnectionState == CallServerConnectionState.ERRORED) {
      return buildErrorView(context, model);
    }
    if (model.callPaymentPromptModel.paymentState == PaymentState.NA) {
      return SizedBox();
    }
    if (model.callPaymentPromptModel.paymentState ==
        PaymentState.PAYMENT_CANCELLED) {
      onPaymentCancelled(context, model);
      return SizedBox();
    }
    if (model.callPaymentPromptModel.paymentState !=
        PaymentState.PAYMENT_COMPLETE) {
      return buildAwaitingPaymentView(model);
    }
    if (model.agoraCredentials == null ||
        model.callCounterpartyConnectionState ==
            CallServerCounterpartyConnectionState.DISCONNECTED) {
      return CallWaitingJoin(
          onCancelCallTap: onEndCallTap, calledUserMetadata: calledMetadata);
    }
    return buildVideoCallView(context, model);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentWrapper<PublicExpertInfo>?>(
        future: PublicExpertInfo.get(widget.otherUserId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
          if (snapshot.hasData) {
            final publicExpertInfo = snapshot.data;
            return Consumer<CallServerModel>(builder: (context, model, child) {
              return Scaffold(
                appBar: ClientInCallAppbar(publicExpertInfo!),
                body: buildCallView(context, model, publicExpertInfo),
              );
            });
          } else {
            return Scaffold(
              appBar: AppBar(title: const Text("Expert Call")),
              body: CircularProgressIndicator(),
            );
          }
        });
  }
}