class ApiUrl {
  static const String baseUrl = "https://global-jump-backend.onrender.com/api/v1";
  //static const String baseUrl = "http://10.0.2.2:8080/api/v1";
  //static const String baseUrl = "https://womens-jennifer-procedure-cars.trycloudflare.com";
  static const String imageUrl = "http://10.0.2.2:8080";
  static String socketUrl = "http://10.0.2.2:8080";
  static String mapKey = "AIzaSyD96BSj2VcHpAfuy2LE1p7NTO7becR44RE";

  ///========================= Authentication =========================
  static const String signUp = "/auth/signup";
  static const String signIn = "/auth/login";
  static const String verificationOtp = "/auth/verify-signup-otp";
  static const String forgotPassword = "/auth/forgot-password";
  static const String verificationOtpForgetPass = "/auth/verify-reset-otp";
  static const String newPassword = "/auth/reset-password";

  // =================== my profile =====================================
  static const String privacyPolicy = "/legal-docs/privacy-policy";
  static const String termsCondition = "/legal-docs/terms-conditions";
  static const String aboutUs = "/legal-docs/about-us";
  static const String contactUs = "/contact";
  static const String changePassword = "/auth/change-password";
  static const String myProfile = "/auth/me";
  static const String updateProfile = "/users/update-user";
  static const String setupUserProfile = "/users/user-profile-complete";
  static const String setupUserProfileConsultants = "/users/consultant-profile-complete";


  ///========================= User =========================
  // static String getRecommendedCountries ({required String page}) => "/recommendations/history?page=$page&limit=10";

  static String getRecommendedCountries({required String page,String? search, List<String>? visaTypes, int? minSuccess, bool? englishOnly, bool? fastTrackOnly,}) {
    String url = "/recommendations/history?page=$page&limit=10";

    if (search != null && search.isNotEmpty) {
      url += "&search=${Uri.encodeComponent(search)}";
    }

    if (minSuccess != null) {
      url += "&minSuccess=$minSuccess";
    }

    if (englishOnly == true) {
      url += "&englishOnly=true";
    }

    if (fastTrackOnly == true) {
      url += "&fastTrackOnly=true";
    }

    if (visaTypes != null && visaTypes.isNotEmpty) {
      String types = visaTypes.join(",");
      url += "&visaTypes=$types";
    }

    return url;
  }

  static String getSingleCountry({required String country}) => "/countries/$country"; //eligibleVisas
  static String eligibleVisas({required String country}) => "/countries/$country/eligible-visas"; 
  static String saveCountry({required String id}) => "/recommendations/save/$id";
  static String deleteCountry({required String id}) => "/recommendations/saved/$id";
  static String getConsultants({required String page}) => "/users/all-consultants?page=$page&limit=10";
  static String getBookedConsultants({required String page}) => "/bookings/my-bookings?page=$page&limit=10";
  static String bookedConsultant({required String id}) => "/bookings/$id";
  static String getSaveCountry({required String page}) => "/recommendations/saved?page=$page&limit=10";
  static String getSingleConsultant({required String id}) => "/users/consultant/$id";
  static const String recommendationsCountries = "/recommendations/generate";

  ///========================= Consultant =========================
  static const String consultantAnalytics = "/bookings/consultant/analytics";
  static const String earningTrend = "/bookings/consultant/analytics/earning-trend";
  static const String bookingTrend = "/bookings/consultant/analytics/booking-trend";
  static String allAppointments ({required String page}) => "/bookings/consultant/my-bookings?page=$page&limit=10";
  static String myBookingCalender ({required String year, required String month}) => "/bookings/consultant/calendar/booked-dates?year=$year&month=$month";
  static String getSingleBooking({required String id}) => "/bookings/consultant/my-bookings/$id";
  static String cancelAppointment({required String id}) => "/bookings/consultant/booking/respond/$id";
  static String confirmAppointment({required String id}) => "/bookings/consultant/booking/respond/$id";





  static String getGalleryPostFilter({
    required int page,
    required String filter,
  }) => "/api/v1/memories_event/find_my_upload_memories_event?contentType=$filter&page=$page&limit=10";
  //share post
  static String sharePost(String postId) => "post/$postId";

  // map
  static const String getMap = "/map?sw_lat=18&sw_lng=89&ne_lat=24&ne_lng=92&category_id=68185fc91db8477bce1fade2";
}
