import 'package:flutter/material.dart';

Widget buildTappableCard(
    {required BuildContext context,
    required Widget leading,
    required Widget title,
    required Widget subtitle,
    required Widget trailing,
    required Function(BuildContext context)? onTapCallback}) {
  final card = Card(
    child: ListTile(
      dense: true,
      visualDensity: VisualDensity(
          horizontal: VisualDensity.maximumDensity,
          vertical: VisualDensity.maximumDensity),
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
    ),
  );

  if (onTapCallback != null) {
    return GestureDetector(
      onTap: () {
        onTapCallback(context);
      },
      child: card,
    );
  }
  return card;
}
