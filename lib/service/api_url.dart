class ApiUrl {
  static const String baseUrl = "http://10.0.2.2:8000/api/v1";
  //static const String baseUrl = "http://10.10.28.90:8000/api/v1";
  static const String imageUrl = "http://10.0.2.2:8080";
  static String socketUrl = "http://10.0.2.2:8080";
  static String mapKey = "AIzaSyD96BSj2VcHpAfuy2LE1p7NTO7becR44RE";

  ///========================= Authentication =========================
  static const String signUpSeeker = "/auth/register/seeker";
  static const String signUpProvider = "/auth/register/provider";
  static const String signIn = "/auth/login";
  static const String verificationOtp = "/auth/verify-signup-otp";
  static const String forgotPassword = "/auth/forgot-password";
  static const String verificationOtpForgetPass = "/auth/verify-reset-otp";
  static const String newPassword = "/auth/reset-password";

  ///========================= User =========================
  // static String getRecommendedCountries ({required String page}) => "/recommendations/history?page=$page&limit=10";

  ///========================= Category & Skills =========================
  static const String categoryList = "/category/list";
  static String skillList(String categoryId) => "/skill/$categoryId/skills";

  ///========================= FCM Token =========================
  static const String fcmToken = "/auth/fcm/token";
}
