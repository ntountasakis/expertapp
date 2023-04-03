import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_facebook/firebase_ui_oauth_facebook.dart';

class FirebaseAuthProviders {
  static String GOOGLE_CLIENT_ID = '111394228371-4slr6ceip09bqefipq2ikbvribtj93qj.apps.googleusercontent.com';
  static String FACEBOOK_CLIENT_ID = '294313229392786';

  static void configureProviders() {
    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
      GoogleProvider(clientId: GOOGLE_CLIENT_ID),
      FacebookProvider(clientId: FACEBOOK_CLIENT_ID),
      AppleProvider(),
    ]);
  }
}
