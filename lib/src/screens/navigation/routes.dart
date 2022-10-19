class Routes {
  static const SIGN_IN_PREFIX = 'signin';
  static const SIGN_IN_START = '$SIGN_IN_PREFIX:$signInStartPage';
  static const signInStartPage = 'start';
  static const signInAuthPage = 'auth';
  static const signInUserCreatePage = 'user_create';

  static const HOME = '/';

  static String subRouteSignIn(String route) {
    final routes = route.split(':');
    if (routes.length != 2) {
      throw new Exception(
          "Invalid Signin route: ${route}. Cannot deduce subroute");
    }
    return routes[1];
  }
}
