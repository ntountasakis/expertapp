import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final _imagePath;

  ProfilePicture(this._imagePath);

  @override
  Widget build(BuildContext context) {
    return (ClipOval(
      child: Image.asset(_imagePath),
    ));
  }
}
