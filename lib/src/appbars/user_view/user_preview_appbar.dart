import 'package:flutter/material.dart';

class UserPreviewAppbar extends StatelessWidget with PreferredSizeWidget {
  final String shortName;
  final String namePrefix;

  UserPreviewAppbar(this.shortName, this.namePrefix);

  String buildTitle() {
    String title = shortName;
    if (namePrefix != "") {
      title = namePrefix + " " + title;
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(buildTitle()),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
