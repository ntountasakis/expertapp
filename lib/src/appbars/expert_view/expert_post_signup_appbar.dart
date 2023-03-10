import 'package:expertapp/src/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpertPostSignupAppbar extends StatelessWidget with PreferredSizeWidget {
  final String uid;
  final String titleText;
  final String nextRoute;
  final bool addAdditionalParams;
  final bool allowBackButton;

  const ExpertPostSignupAppbar(
      {required this.uid,
      required this.titleText,
      required this.nextRoute,
      required this.addAdditionalParams,
      required this.allowBackButton});

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
              color: Colors.green[800],
              shape: BoxShape.circle,
            ),
            // padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
                onTap: () {},
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_circle_right_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (addAdditionalParams) {
                      context.pushNamed(nextRoute, params: {
                        Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "true"
                      });
                    } else {
                      context.pushNamed(nextRoute);
                    }
                  },
                )),
          ),
        ),
      ],
    );
  }
}
