import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ExpertProfileAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String expertUid;

  const ExpertProfileAppbar({required this.expertUid});

  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Expert Profile"),
      actions: [
        Row(
          children: [
            Text("Share"),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                final url =
                    await getShareableExpertProfileDynamicLink(expertUid);
                Share.share(url);
              },
            ),
          ],
        ),
      ],
    );
  }
}
