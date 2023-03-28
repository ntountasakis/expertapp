import 'package:expertapp/src/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register or Sign In"),
        actions: [
          ElevatedButton(
            onPressed: () async {
              context.goNamed(Routes.HOME_PAGE);
            },
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SignInScreen(providerConfigs: [
        EmailProviderConfiguration(),
        GoogleProviderConfiguration(
          clientId:
              '111394228371-4slr6ceip09bqefipq2ikbvribtj93qj.apps.googleusercontent.com',
        ),
        FacebookProviderConfiguration(
          clientId: '294313229392786',
        )
      ]),
    );
  }
}
