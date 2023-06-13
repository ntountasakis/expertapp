import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/util/call_summary_util.dart';
import 'package:expertapp/src/util/loading_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RatePickers extends StatefulWidget {
  final num initialValueRateStartCall;
  final num initialValueRatePerMinute;
  final bool fromSignUpFlow;

  const RatePickers(
      {Key? key,
      required this.initialValueRateStartCall,
      required this.initialValueRatePerMinute,
      required this.fromSignUpFlow})
      : super(key: key);

  @override
  State<RatePickers> createState() => _MyRatePickerState();
}

class _MyRatePickerState extends State<RatePickers> {
  final _formKey = GlobalKey<FormState>();
  final _formatter = CurrencyTextInputFormatter();
  bool isSubmitting = false;

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

  Future<void> onSubmitPressed() async {
    _formKey.currentState!.save();
    if (_ratePerMinute == -1 || _rateStartCall == -1) {
      return;
    }
    setState(() => isSubmitting = true);
    final UpdateResult result = await updateExpertRate(
        centsPerMinute: _ratePerMinute,
        centsStartCall: _rateStartCall,
        fromSignUpFlow: widget.fromSignUpFlow);
    setState(() => isSubmitting = false);
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(result.success ? "Success" : "Error"),
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    result.message,
                    style: CallSummaryUtil.LIGHT_STYLE,
                  ),
                ),
              ),
              TextButton(
                child: Text("OK"),
                onPressed: () async {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Widget buildSubmitButton(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SizedBox()),
        ElevatedButton.icon(
          onPressed: isSubmitting ? null : onSubmitPressed,
          label: isSubmitting ? loadingIcon() : Icon(Icons.check),
          icon: Text("Submit"),
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
