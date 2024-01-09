import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/util/call_summary_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ExpertPhoneNumberPicker extends StatefulWidget {
  final String initialPhoneNumber;
  final String initialPhoneNumberIsoCode;
  final bool initialConsentStatus;
  final bool fromSignUpFlow;

  const ExpertPhoneNumberPicker({
    Key? key,
    required this.initialPhoneNumber,
    required this.initialPhoneNumberIsoCode,
    required this.initialConsentStatus,
    required this.fromSignUpFlow,
  }) : super(key: key);

  @override
  State<ExpertPhoneNumberPicker> createState() =>
      _ExpertPhoneNumberPickerState();
}

class _ExpertPhoneNumberPickerState extends State<ExpertPhoneNumberPicker> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();

  PhoneNumber currentNumber = PhoneNumber(isoCode: 'US');
  bool currentConsentStatus = false;

  @override
  void initState() {
    super.initState();
    currentConsentStatus = widget.initialConsentStatus;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPhoneNumber.isNotEmpty) {
        getPhoneNumber(
            widget.initialPhoneNumber, widget.initialPhoneNumberIsoCode);
      }
    });
  }

  void getPhoneNumber(String phoneNumber, String isoCode) async {
    PhoneNumber number =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, isoCode);

    setState(() {
      this.currentNumber = number;
    });
  }

  Widget buildSmsConsentToggle() {
    return Row(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                  'Do you consent to receive SMS incoming call notifications?\n'
                  'This is more reliable than push notifications and will \n'
                  'help you to never miss a call.'),
            ),
            SizedBox(height: 10),
            ToggleSwitch(
              minWidth: 90.0,
              cornerRadius: 20.0,
              activeBgColors: [
                [Colors.red[800]!],
                [Colors.green[800]!],
              ],
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              initialLabelIndex: currentConsentStatus ? 1 : 0,
              totalSwitches: 2,
              labels: ['False', 'True'],
              radiusStyle: true,
              onToggle: (index) {
                setState(() {
                  currentConsentStatus = index == 1 ? true : false;
                  if (!currentConsentStatus) {
                    setState(() {
                      currentNumber = PhoneNumber(isoCode: 'US');
                      formKey.currentState?.setState(() {
                        controller.clear();
                      });
                    });
                  }
                });
              },
            ),
          ],
        )
      ],
    );
  }

  Widget buildPhoneInputPicker() {
    return Visibility(
      visible: currentConsentStatus,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InternationalPhoneNumberInput(
          onInputChanged: (PhoneNumber number) {
            print(number.phoneNumber);
          },
          onInputValidated: (bool value) {
            print(value);
          },
          selectorConfig: SelectorConfig(
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          ),
          ignoreBlank: false,
          autoValidateMode: AutovalidateMode.disabled,
          selectorTextStyle: TextStyle(color: Colors.black),
          initialValue: currentNumber,
          textFieldController: controller,
          formatInput: true,
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          inputBorder: OutlineInputBorder(),
          onSaved: (PhoneNumber number) async {
            final result = await onSavePressed(number);
            if (result.success) {
              setState(() {
                currentNumber = number;
              });
            }
          },
        ),
      ),
    );
  }

  Future<UpdateResult> onSavePressed(PhoneNumber? number) async {
    final UpdateResult result = await updateExpertPhoneNumber(
      phoneNumber: number != null ? number.phoneNumber! : '',
      phoneNumberDialCode: number != null ? number.dialCode! : '',
      phoneNumberIsoCode: number != null ? number.isoCode! : '',
      consentsToSms: currentConsentStatus,
      fromSignUpFlow: widget.fromSignUpFlow,
    );
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
            ],
          );
        });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            buildSmsConsentToggle(),
            SizedBox(height: 20),
            buildPhoneInputPicker(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (currentConsentStatus) {
                  final isValid = formKey.currentState?.validate();
                  if (isValid != null && isValid) {
                    formKey.currentState?.save();
                  }
                } else {
                  onSavePressed(null);
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
