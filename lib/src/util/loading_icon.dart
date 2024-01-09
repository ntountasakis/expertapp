import 'package:flutter/material.dart';

Widget loadingIcon() {
  return Container(
      width: 24,
      height: 24,
      padding: const EdgeInsets.all(2.0),
      child: CircularProgressIndicator(
        color:Colors.white,
        strokeWidth: 3,
      ));
}
