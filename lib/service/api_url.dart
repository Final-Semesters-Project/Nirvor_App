class ApiUrl {
  // static const String baseUrl = "http://10.10.28.162:8000/api/v1"; // 12345678
  static const String baseUrl = "https://nirbhor-backend-6yuf.onrender.com/api/v1";
  //static const String baseUrl = "http://10.0.2.2:8000/api/v1"; // 01723354435
  static const String imageUrl = "http://10.10.28.162:8000";
  static String socketUrl = "http://10.10.28.162:8000";
  static String mapKey ="AIzaSyCHBKvR2Wgc4eF53nYTlGYxULSQuVpb9t4"; //"AIzaSyD96BSj2VcHpAfuy2LE1p7NTO7becR44RE";
  static const String stagingApiKey ="apikeytoidentifyiftherequestiscomingfromfrontendteam";

//   Seeker:
// phone=01700000002
// password=password123

// Provider:
// phone=01800000001
// password=password123

  ///========================= Authentication =========================
  static const String signUpSeeker = "/auth/register/seeker";
  static const String signUpProvider = "/auth/register/provider";
  static const String signIn = "/auth/login";
  static const String signOut = "/auth/logout";
  static const String verificationOtp = "/auth/verify-signup-otp";
  static const String forgotPassword = "/auth/forgot-password";
  static const String verificationOtpForgetPass = "/auth/verify-reset-otp";
  static const String newPassword = "/auth/reset-password";

  ///========================= User =========================
  static const String userProfile = "/users/me";

  ///========================= Category & Skills =========================
  static const String categoryList = "/category/list";
  static String skillList(String categoryId) => "/skill/$categoryId/skills";

  ///========================= Search Providers =========================
  static const String searchProviders = "/search/providers";

  ///========================= Bookings =========================
  static const String activeBooking = "/bookings/seeker/last_active_initiated";

  ///========================= FCM Token =========================
  static const String fcmToken = "/auth/fcm/token";
}
