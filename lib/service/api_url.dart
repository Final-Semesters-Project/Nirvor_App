class ApiUrl {
  // static const String baseUrl = "http://10.10.28.162:8000/api/v1"; // 12345678
  static const String baseUrl =
      "https://nirbhor-backend-6yuf.onrender.com/api/v1";
  //static const String baseUrl = "http://10.0.2.2:8000/api/v1"; // 01723354435
  static const String imageUrl = "http://10.10.28.162:8000";
  static String socketUrl = "http://10.10.28.162:8000";
  static const String mapKey = "AIzaSyCHBKvR2Wgc4eF53nYTlGYxULSQuVpb9t4";
  static const String stagingApiKey =
      "apikeytoidentifyiftherequestiscomingfromfrontendteam";

  //   Seeker:
  // phone=01700000002
  // password=password123

  // Provider:
  // phone=01800000001 , 18,17
  // password=password123 , 1-9

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
  static const String seekerAddress = "/seeker/me/address";
  static const String updatePassword = "/users/me/update-password";

  ///========================= Category & Skills =========================
  static const String categoryList = "/category/list";
  static String skillList(String categoryId) => "/skill/$categoryId/skills";

  ///========================= Search Providers =========================
  static const String searchProviders = "/search/providers";

  ///========================= Bookings =========================
  static const String activeBooking = "/bookings/seeker/last_active_initiated";
  static const String initiateBooking = "/bookings/initiate";
  static String respondBooking(String bookingId) =>
      "/bookings/$bookingId/respond";
  static String seekerBookingHistory(int page, {int pageSize = 20}) =>
      "/bookings/seeker/me?page=$page&page_size=$pageSize";
  static String singleBookingDetail(String bookingId) => "/bookings/$bookingId";
  static String completeBooking(String bookingId) =>
      "/bookings/$bookingId/complete";
  static String providerIncomingBookings({int page = 1, int pageSize = 20}) =>
      "/bookings/provider/me?page=$page&page_size=$pageSize";
  static const String providerCompletedBookings =
      "/bookings/provider/me/completed";

  ///========================= Provider Dashboard & Profile =========================
  static const String providerDashboard = "/provider/dashboard";
  static const String updateProviderProfile = "/provider/me/update_profile";
  static String nidUploadSignature(String side) =>
      "/uploads/upload-signature/nid?side=$side";
  static const String providerAddSkill = "/provider/me/add_skill";
  static String providerRemoveSkill(int skillId) =>
      "/provider/me/remove_skill?skill_id=$skillId";
  static String providerPublicProfile(String providerId) =>
      "/provider/$providerId/public";

  ///========================= Reviews =========================
  static const String reviews = "/reviews";
  static String providerReviews(
    String providerId, {
    int page = 1,
    int pageSize = 20,
  }) => "/reviews/provider/$providerId?page=$page&page_size=$pageSize";

  ///========================= Urgent Broadcast =========================
  static const String urgentBroadcast = "/urgentBroadcast/broadcast";
  static String urgentBroadcastStatus(String broadcastId) =>
      "/urgentBroadcast/broadcast/$broadcastId/status";
  static String urgentBroadcastDetail(String broadcastId) =>
      "/urgentBroadcast/broadcast/$broadcastId";
  static String claimUrgentBroadcast(String broadcastId) =>
      "/urgentBroadcast/broadcast/$broadcastId/claim";

  ///========================= FCM Token =========================
  static const String fcmToken = "/auth/fcm/token";
}
