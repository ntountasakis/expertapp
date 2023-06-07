import 'package:flutter/material.dart';

class UserPreviewAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String shortName;
  final String namePrefix;

  UserPreviewAppbar(this.shortName, this.namePrefix);

  Widget buildTitle() {
    String title = shortName;
    if (namePrefix != "") {
      title = namePrefix + " " + title;
    }
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(
        title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: buildTitle(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
