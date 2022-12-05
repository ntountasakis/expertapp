import 'package:flutter/material.dart';

Widget startCallButton(VoidCallback onStartCallTap) {
  return _callButton(Icons.call_rounded, Colors.green, onStartCallTap);
}

Widget endCallButton(VoidCallback onEndCallTap) {
  return _callButton(Icons.call_end_rounded, Colors.red, onEndCallTap);
}

Widget callButtonRow(BuildContext context, List<Widget> buttons) {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    child: Center(
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: buttons,
        ),
      ),
    ),
  );
}

Widget _callButton(IconData aIcon, Color aColor, VoidCallback aTap) {
  return Container(
    decoration: BoxDecoration(
      color: aColor,
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: Icon(
        aIcon,
        size: 25,
        color: Colors.white,
      ),
      onPressed: () async {
        aTap();
      },
    ),
  );
}
