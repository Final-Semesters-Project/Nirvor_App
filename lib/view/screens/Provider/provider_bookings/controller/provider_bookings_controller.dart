import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../../../../../utils/ToastMsg/toast_message.dart';
import '../../../../../utils/app_colors/app_colors.dart';
import '../../../Seeker/seeker_bookings/model/seeker_booking_model.dart';
import '../screen/provider_booking_details_screen.dart';

class ProviderBookingsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  final ScrollController activeScrollController = ScrollController();
  final ScrollController completedScrollController = ScrollController();

  // Tab Index (0: Active, 1: Completed)
  final RxInt selectedTabIndex = 0.obs;

  // Active Bookings State (/api/v1/bookings/provider/me)
  final RxList<BookingItemModel> activeBookings = <BookingItemModel>[].obs;
  final RxBool isLoadingActive = false.obs;
  final RxBool isLoadingMoreActive = false.obs;
  final RxInt activeCurrentPage = 1.obs;
  final RxInt activeTotalPages = 1.obs;
  final RxBool activeHasNext = false.obs;
  final RxInt activeTotal = 0.obs;

  // Completed Bookings State (/api/v1/bookings/provider/me/completed)
  final RxList<BookingItemModel> completedBookings = <BookingItemModel>[].obs;
  final RxBool isLoadingCompleted = false.obs;
  final RxInt completedTotal = 0.obs;

  // Single Booking Detail State (/api/v1/bookings/{booking_id})
  final Rxn<BookingDetailModel> singleBookingDetail = Rxn<BookingDetailModel>();
  final RxBool isLoadingDetail = false.obs;

  // Review State for Provider -> Seeker review
  final RxBool isSubmittingReview = false.obs;
  final RxSet<String> reviewedBookingIds = <String>{}.obs;

  bool isBookingReviewed(String bookingId, {bool? backendHasReviewed}) {
    final bool inMemory = reviewedBookingIds.contains(bookingId);
    return backendHasReviewed == true || inMemory;
  }

  void markBookingAsReviewed(String bookingId) {
    if (bookingId.isNotEmpty) {
      reviewedBookingIds.add(bookingId);
      if (singleBookingDetail.value != null &&
          singleBookingDetail.value!.bookingId == bookingId) {
        singleBookingDetail.value =
            singleBookingDetail.value!.copyWith(hasReviewed: true);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        selectedTabIndex.value = tabController.index;
      }
    });

    activeScrollController.addListener(() {
      if (activeScrollController.position.pixels >=
              activeScrollController.position.maxScrollExtent - 200 &&
          activeHasNext.value &&
          !isLoadingMoreActive.value &&
          !isLoadingActive.value) {
        loadMoreActiveBookings();
      }
    });

    fetchAllData();
  }

  @override
  void onClose() {
    tabController.dispose();
    activeScrollController.dispose();
    completedScrollController.dispose();
    super.onClose();
  }

  /// Initial fetch for both tabs
  Future<void> fetchAllData() async {
    await Future.wait([
      fetchActiveBookings(refresh: true),
      fetchCompletedBookings(refresh: true),
    ]);
  }

  /// Fetch active bookings: GET /api/v1/bookings/provider/me
  Future<void> fetchActiveBookings({bool refresh = false}) async {
    if (refresh) {
      activeCurrentPage.value = 1;
      isLoadingActive.value = true;
    }

    try {
      final response = await ApiClient.getData(
        ApiUrl.providerIncomingBookings(
          page: activeCurrentPage.value,
          pageSize: 20,
        ),
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        List itemsJson = [];
        if (data is Map && data['items'] != null) {
          itemsJson = data['items'];
          activeTotal.value = data['total'] ?? itemsJson.length;
          activeTotalPages.value = data['total_pages'] ?? 1;
          activeHasNext.value = data['has_next'] ?? false;
        } else if (data is List) {
          itemsJson = data;
          activeTotal.value = itemsJson.length;
          activeTotalPages.value = 1;
          activeHasNext.value = false;
        }

        final List<BookingItemModel> newItems =
            itemsJson.map((e) => BookingItemModel.fromJson(e)).toList();

        if (refresh) {
          activeBookings.assignAll(newItems);
        } else {
          activeBookings.addAll(newItems);
        }
      }
    } catch (e) {
      debugPrint("Error fetching provider active bookings: $e");
    } finally {
      isLoadingActive.value = false;
      isLoadingMoreActive.value = false;
    }
  }

  /// Load more active bookings (Pagination)
  Future<void> loadMoreActiveBookings() async {
    if (activeHasNext.value && !isLoadingMoreActive.value) {
      isLoadingMoreActive.value = true;
      activeCurrentPage.value++;
      await fetchActiveBookings(refresh: false);
    }
  }

  /// Fetch completed bookings: GET /api/v1/bookings/provider/me/completed
  Future<void> fetchCompletedBookings({bool refresh = false}) async {
    if (refresh) {
      isLoadingCompleted.value = true;
    }

    try {
      final response = await ApiClient.getData(ApiUrl.providerCompletedBookings);

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        List itemsJson = [];
        if (data is List) {
          itemsJson = data;
        } else if (data is Map && data['items'] != null) {
          itemsJson = data['items'];
        }

        final List<BookingItemModel> items =
            itemsJson.map((e) => BookingItemModel.fromJson(e)).toList();

        completedBookings.assignAll(items);
        completedTotal.value = items.length;
      }
    } catch (e) {
      debugPrint("Error fetching provider completed bookings: $e");
    } finally {
      isLoadingCompleted.value = false;
    }
  }

  /// Fetch single booking detail: GET /api/v1/bookings/{booking_id}
  Future<void> fetchBookingDetail(String bookingId) async {
    isLoadingDetail.value = true;
    singleBookingDetail.value = null;

    try {
      final response =
          await ApiClient.getData(ApiUrl.singleBookingDetail(bookingId));
      if (response.statusCode == 200 && response.body != null) {
        final detail = BookingDetailModel.fromJson(response.body);
        singleBookingDetail.value = detail;
      }
    } catch (e) {
      debugPrint("Error fetching booking detail: $e");
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Make phone call to seeker
  Future<void> callSeeker(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      showCustomSnackBar("Number not available".tr, isError: true);
      return;
    }
    final Uri callUri = Uri(scheme: 'tel', path: phone.trim());
    try {
      bool launched = false;
      try {
        launched = await launchUrl(callUri);
      } catch (_) {
        launched = false;
      }
      if (!launched) {
        try {
          launched = await launchUrl(callUri, mode: LaunchMode.externalApplication);
        } catch (_) {
          launched = false;
        }
      }
      if (!launched) {
        showCustomSnackBar("Could not launch phone dialer".tr, isError: true);
      }
    } catch (e) {
      debugPrint("Error launching phone dialer: $e");
      showCustomSnackBar("Could not launch phone dialer".tr, isError: true);
    }
  }

  /// Open job location on Google Maps
  Future<void> openMapLocation(double? lat, double? lng) async {
    if (lat == null || lng == null || (lat == 0.0 && lng == 0.0)) {
      showCustomSnackBar("Location coordinates not available".tr, isError: true);
      return;
    }

    // 1. Native geo scheme (directly opens Google Maps / Navigation app on Android & iOS)
    final Uri geoUri = Uri.parse("geo:$lat,$lng?q=$lat,$lng");
    // 2. Google Maps universal search URL (fallback)
    final Uri webSearchUri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    // 3. Google Maps directions URL (second fallback)
    final Uri webDirUri = Uri.parse("https://maps.google.com/?q=$lat,$lng");

    try {
      bool launched = false;

      // 1. Try native geo URI with external application mode
      try {
        launched = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint("geoUri launch failed: $e");
        launched = false;
      }

      // 2. If geo intent fails or isn't handled, fallback to web map URL
      if (!launched) {
        try {
          launched = await launchUrl(webSearchUri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint("webSearchUri external launch failed: $e");
          launched = false;
        }
      }

      // 3. Fallback to platform default browser
      if (!launched) {
        try {
          launched = await launchUrl(webSearchUri, mode: LaunchMode.platformDefault);
        } catch (e) {
          debugPrint("webSearchUri platformDefault launch failed: $e");
          launched = false;
        }
      }

      // 4. Fallback to legacy maps URL
      if (!launched) {
        try {
          launched = await launchUrl(webDirUri, mode: LaunchMode.externalApplication);
        } catch (_) {}
      }

      if (!launched) {
        showCustomSnackBar("Could not open Google Maps".tr, isError: true);
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
      showCustomSnackBar("Could not open Google Maps".tr, isError: true);
    }
  }

  /// Copy text to clipboard
  void copyToClipboard(String text, String label) {
    if (text.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    showCustomSnackBar("$label copied to clipboard".tr, isError: false);
  }

  /// Submit review for seeker: POST /api/v1/reviews
  Future<void> submitSeekerReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    isSubmittingReview.value = true;
    try {
      final body = <String, dynamic>{
        "booking_id": bookingId,
        "rating": rating,
        if (comment != null && comment.trim().isNotEmpty)
          "comment": comment.trim(),
        "is_anonymous": false,
      };

      final response = await ApiClient.postData(ApiUrl.reviews, body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        markBookingAsReviewed(bookingId);
        Get.back(); // close review bottom sheet
        showCustomSnackBar(
          "Thank you! Your review has been submitted.".tr,
          isError: false,
        );
        await fetchBookingDetail(bookingId);
      } else {
        String msg = "Could not submit review".tr;
        if (response.body is Map && response.body['detail'] != null) {
          msg = response.body['detail'].toString();
        }
        if (msg.toLowerCase().contains("already") ||
            response.statusCode == 409 ||
            (response.statusCode == 400 && msg.toLowerCase().contains("review"))) {
          markBookingAsReviewed(bookingId);
          Get.back();
          showCustomSnackBar(
            "You have already reviewed this booking".tr,
            isError: false,
          );
        } else {
          showCustomSnackBar(msg, isError: true);
        }
      }
    } catch (e) {
      debugPrint("Error submitting seeker review: $e");
      showCustomSnackBar("Something went wrong".tr, isError: true);
    } finally {
      isSubmittingReview.value = false;
    }
  }

  /// Bottom sheet for Rating and Reviewing Seeker (only rating & comment, no cost, no anonymous)
  void showSeekerReviewBottomSheet(
    String bookingId, {
    String seekerName = '',
  }) {
    final RxInt selectedRating = 0.obs;
    final TextEditingController commentController = TextEditingController();

    Get.bottomSheet(
      SafeArea(
        top: true,
        bottom: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.88,
          ),
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SafeArea(
                top: false,
                bottom: true,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Title & Subtitle
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.star_rounded,
                                color: Colors.amber.shade800, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rate & Review Seeker'.tr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  seekerName.isNotEmpty
                                      ? '${'How was your experience with'.tr} $seekerName?'
                                      : 'How was your experience with the seeker?'.tr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Star Rating Picker
                      Center(
                        child: Column(
                          children: [
                            Obx(() => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(5, (index) {
                                    final starNum = index + 1;
                                    final isFilled =
                                        starNum <= selectedRating.value;
                                    return IconButton(
                                      iconSize: 36,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      icon: Icon(
                                        isFilled
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        color: isFilled
                                            ? Colors.amber.shade600
                                            : Colors.grey.shade400,
                                      ),
                                      onPressed: () {
                                        selectedRating.value = starNum;
                                      },
                                    );
                                  }),
                                )),
                            const SizedBox(height: 4),
                            Obx(() {
                              String ratingText = '';
                              Color textColor = Colors.amber.shade900;
                              switch (selectedRating.value) {
                                case 1:
                                  ratingText = 'rating_poor'.tr;
                                  textColor = Colors.red.shade700;
                                  break;
                                case 2:
                                  ratingText = 'rating_fair'.tr;
                                  textColor = Colors.orange.shade800;
                                  break;
                                case 3:
                                  ratingText = 'rating_good'.tr;
                                  textColor = Colors.amber.shade800;
                                  break;
                                case 4:
                                  ratingText = 'rating_very_good'.tr;
                                  textColor = Colors.teal.shade700;
                                  break;
                                case 5:
                                  ratingText = 'rating_excellent'.tr;
                                  textColor = Colors.green.shade700;
                                  break;
                                default:
                                  ratingText = 'tap_star_to_rate'.tr;
                                  textColor = Colors.grey.shade500;
                                  break;
                              }
                              return Text(
                                ratingText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Comment input (NO cost, NO anonymous option)
                      Text(
                        'Write a Review (Optional)'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: commentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Share details of your experience with this service...'.tr,
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                          fillColor: Colors.grey.shade50,
                          filled: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text('Skip'.tr),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: isSubmittingReview.value
                                    ? null
                                    : () async {
                                        if (selectedRating.value == 0) {
                                          showCustomSnackBar(
                                            'Please select a star rating first'.tr,
                                            isError: true,
                                          );
                                          return;
                                        }
                                        await submitSeekerReview(
                                          bookingId: bookingId,
                                          rating: selectedRating.value,
                                          comment: commentController.text,
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: isSubmittingReview.value
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Submit Review'.tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  /// Open details screen
  void openBookingDetails(String bookingId,
      {String? skillName, String? seekerName, String? seekerId}) {
    Get.to(
      () => ProviderBookingDetailsScreen(
        bookingId: bookingId,
        skillName: skillName,
        seekerName: seekerName,
        seekerId: seekerId,
      ),
    );
  }
}

