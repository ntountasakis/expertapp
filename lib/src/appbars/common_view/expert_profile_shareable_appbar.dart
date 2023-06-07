import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ExpertProfileAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  final String expertUid;
  final String title;

  const ExpertProfileAppbar({required this.expertUid, required this.title});

  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        centerTitle: true,
        title: FittedBox(fit: BoxFit.fitWidth, child: Text(title)),
        actions: [
          InkWell(
            onTap: () async {
              final url = await getShareableExpertProfileDynamicLink(expertUid);
              Share.share(url);
            },
            child: Row(
              children: [
                Text("Share"),
                SizedBox(width: 5),
                Icon(Icons.share),
                SizedBox(width: 5),
              ],
            ),
          ),
        ]);
  }
}
