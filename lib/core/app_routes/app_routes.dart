import 'package:get/get.dart';

import '../../view/screens/auth_screen/login_screen/login_screen.dart';
import '../../view/screens/auth_screen/register_screen/register_screen.dart'
    show RegisterScreen;

class AppRoutes {
  ///===========================Authentication==========================
  static const String loginScreen = "/LoginScreen";
  static const String registerScreen = "/RegisterScreen";

  static List<GetPage> routes = [
    ///===========================Authentication==========================
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: registerScreen, page: () => RegisterScreen()),

    ///============== Immigration Seeker ==================
  ];
}
