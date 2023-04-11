import 'package:expertapp/src/firebase/firestore/document_models/expert_signup_progress.dart';
import 'package:flutter/material.dart';

class ExpertPostSignupAppbar {
  final String uid;
  final String titleText;
  final bool allowBackButton;
  final bool allowProceed;
  final ExpertSignupProgress progress;
  final Function(BuildContext) onAllowProceedPressed;
  final Function(BuildContext, ExpertSignupProgress)?
      onDisallowedProceedPressed;

  const ExpertPostSignupAppbar({
    required this.uid,
    required this.titleText,
    required this.allowBackButton,
    required this.allowProceed,
    required this.progress,
    required this.onAllowProceedPressed,
    required this.onDisallowedProceedPressed,
  });

  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  PreferredSizeWidget buildAppBar(BuildContext context) {
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
                        onDisallowedProceedPressed!(context, progress);
                    })),
          ),
        ),
      ],
    );
  }
}
