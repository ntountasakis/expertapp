import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/util/call_summary_util.dart';
import 'package:expertapp/src/util/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExpertRatePage extends StatelessWidget {
  final String uid;

  const ExpertRatePage({required this.uid});

  Widget buildExistingRateView(DocumentWrapper<ExpertRate>? expertRate) {
    if (expertRate == null) {
      return Text("You have no rate registered yet.");
    }
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(children: [
          Text(
              "You will earn money for accepting calls with the following rates."),
          SizedBox(
            height: 20,
          ),
          Text("Current rate earned per minute: " +
              formattedRate(expertRate.documentType.centsPerMinute)),
          SizedBox(
            height: 20,
          ),
          Text("Current rate earned to accept a call: " +
              formattedRate(expertRate.documentType.centsCallStart)),
        ]));
  }

  Widget buildExpertRateSelector(
      BuildContext context, DocumentWrapper<ExpertRate>? expertRate) {
    num existingRatePerMinute = 0;
    num existingRateStartCall = 0;
    if (expertRate != null) {
      existingRatePerMinute = expertRate.documentType.centsPerMinute;
      existingRateStartCall = expertRate.documentType.centsCallStart;
    }
    return new RatePickers(
        initialValueRateStartCall: existingRateStartCall,
        initialValueRatePerMinute: existingRatePerMinute);
  }

  @override
  Widget build(BuildContext context) {
    final body = StreamBuilder<DocumentWrapper<ExpertRate>?>(
        stream: ExpertRate.getStream(uid),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<ExpertRate>?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Column(
              children: [
                buildExistingRateView(snapshot.data),
                SizedBox(
                  height: 40,
                ),
                buildExpertRateSelector(context, snapshot.data),
              ],
            );
          }
          return SizedBox();
        });

    return Scaffold(
      appBar: AppBar(
        title: Text("Call Rate"),
      ),
      body: body,
    );
  }
}

class RatePickers extends StatefulWidget {
  final num initialValueRateStartCall;
  final num initialValueRatePerMinute;

  const RatePickers(
      {Key? key,
      required this.initialValueRateStartCall,
      required this.initialValueRatePerMinute})
      : super(key: key);

  @override
  State<RatePickers> createState() => _MyRatePickerState();
}

class _MyRatePickerState extends State<RatePickers> {
  final _formKey = GlobalKey<FormState>();
  final _formatter = CurrencyTextInputFormatter();

  late int _rateStartCall = -1;
  late int _ratePerMinute = -1;

  void updateRatePerMinute(int value) {
    setState(() {
      _ratePerMinute = value;
    });
  }

  void updateRateStartCall(int value) {
    setState(() {
      _rateStartCall = value;
    });
  }

  Widget buildRatePicker(
      num initValue, String rateLabel, void Function(int) onUpdate) {
    return Row(
      children: [
        SizedBox(
          width: 225,
          child: Text(rateLabel, style: CallSummaryUtil.BOLD_STYLE),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            initialValue: _formatter.format(initValue.toString()),
            inputFormatters: <TextInputFormatter>[_formatter],
            keyboardType: TextInputType.number,
            onSaved: (value) {
              if (value != null) {
                final splitted = value.split("USD");
                final doubleValue = double.parse(splitted[1]);
                final centsValue = (doubleValue * 100).toInt();
                onUpdate(centsValue);
              }
            },
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SizedBox()),
        ElevatedButton(
          onPressed: () async {
            _formKey.currentState!.save();
            if (_ratePerMinute == -1 || _rateStartCall == -1) {
              return;
            }
            final UpdateResult result = await updateExpertRate(
                centsPerMinute: _ratePerMinute, centsStartCall: _rateStartCall);
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Text(result.success ? "Success" : "Error"),
                    children: [
                      Center(
                        child: Text(
                          result.message,
                          style: CallSummaryUtil.LIGHT_STYLE,
                        ),
                      ),
                    ],
                  );
                });
          },
          child: Text("Submit"),
        ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildRatePicker(widget.initialValueRatePerMinute,
              "Update rate earned per minute", updateRatePerMinute),
          SizedBox(
            height: 10,
          ),
          buildRatePicker(widget.initialValueRateStartCall,
              "Update rate earned to accept a call", updateRateStartCall),
          SizedBox(
            height: 20,
          ),
          buildSubmitButton(context),
        ],
      ),
    );
  }
}
