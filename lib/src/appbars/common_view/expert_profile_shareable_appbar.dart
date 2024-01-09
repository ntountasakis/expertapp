import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/util/loading_icon.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ExpertProfileAppbar extends StatefulWidget
    implements PreferredSizeWidget {
  final String expertUid;
  final String title;

  const ExpertProfileAppbar({required this.expertUid, required this.title});

  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  State<ExpertProfileAppbar> createState() => _ExpertProfileAppbarState();
}

class _ExpertProfileAppbarState extends State<ExpertProfileAppbar> {
  bool isAwaitingShareLink = false;

  Future<void> onTap() async {
    setState(() => isAwaitingShareLink = true);
    final url = await getShareableExpertProfileDynamicLink(widget.expertUid);
    setState(() => isAwaitingShareLink = false);
    Share.share(url);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        centerTitle: true,
        title: FittedBox(fit: BoxFit.fitWidth, child: Text(widget.title)),
        actions: [
          ElevatedButton.icon(
            onPressed: isAwaitingShareLink ? null : onTap,
            label: isAwaitingShareLink ? loadingIcon() : Icon(Icons.share),
            icon: Text("Share"),
          ),
        ]);
  }
}
