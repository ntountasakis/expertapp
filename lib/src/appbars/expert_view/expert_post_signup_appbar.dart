import 'package:flutter/material.dart';

class ExpertPostSignupAppbar extends StatelessWidget with PreferredSizeWidget {
  final String uid;
  final String titleText;
  final bool allowBackButton;
  final bool allowProceed;
  final Function(BuildContext) onAllowProceedPressed;
  final VoidCallback? onDisallowedProceedPressed;

  const ExpertPostSignupAppbar({
    required this.uid,
    required this.titleText,
    required this.allowBackButton,
    required this.allowProceed,
    required this.onAllowProceedPressed,
    required this.onDisallowedProceedPressed,
  });

  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: allowBackButton,
      title: Text(this.titleText),
      actions: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
              color: allowProceed ? Colors.green[800] : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: GestureDetector(
                onTap: () {},
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_circle_right_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (allowProceed) {
                        onAllowProceedPressed(context);
                      } else if (onDisallowedProceedPressed != null)
                        onDisallowedProceedPressed!();
                    })),
          ),
        ),
      ],
    );
  }
}
