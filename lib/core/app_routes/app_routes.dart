import 'package:get/get.dart';
import 'package:nirbhor/view/screens/Seeker/home_seeker/screen/home_seeker_screen.dart';
import 'package:nirbhor/view/screens/auth_screen/setup_details/setup_details_screen.dart';

import '../../view/screens/auth_screen/login_screen/login_screen.dart';
import '../../view/screens/auth_screen/register_screen/register_screen.dart'
    show RegisterScreen;
import '../../view/screens/auth_screen/otp_verify_screen/otp_verify_screen.dart';
import '../../view/screens/auth_screen/password_login_screen/password_login_screen.dart';
import '../../view/screens/auth_screen/welcome_screen/welcome_screen.dart';
import '../../view/screens/auth_screen/register_method_screen/register_method_screen.dart';
import '../../view/screens/Provider/home_provider/screen/provider_home_screen.dart';

class AppRoutes {
  ///===========================Authentication==========================
  static const String loginScreen = "/LoginScreen";
  static const String registerScreen = "/RegisterScreen";
  static const String otpVerifyScreen = "/OtpVerifyScreen";
  static const String passwordLoginScreen = "/PasswordLoginScreen";
  static const String welcomeScreen = "/WelcomeScreen";
  static const String registerMethodScreen = "/RegisterMethodScreen";
  static const String homeSeekerScreen = "/HomeSeekerScreen";
  static const String setupDetailsScreen = "/SetupDetailsScreen";
  static const String providerHomeScreen = "/ProviderHomeScreen";

  static List<GetPage> routes = [
    ///===========================Authentication==========================
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: registerScreen, page: () => RegisterScreen()),
    GetPage(name: otpVerifyScreen, page: () => OtpVerifyScreen()),
    GetPage(name: passwordLoginScreen, page: () => PasswordLoginScreen()),
    GetPage(name: welcomeScreen, page: () => const WelcomeScreen()),
    GetPage(
      name: registerMethodScreen,
      page: () => const RegisterMethodScreen(),
    ),
    GetPage(name: setupDetailsScreen, page: () => const SetupDetailsScreen()),

    ///============== Immigration Seeker ==================
    GetPage(name: homeSeekerScreen, page: () => HomeSeekerScreen()),

    ///============== Provider ==================
    GetPage(name: providerHomeScreen, page: () => const ProviderHomeScreen()),
  ];
}
