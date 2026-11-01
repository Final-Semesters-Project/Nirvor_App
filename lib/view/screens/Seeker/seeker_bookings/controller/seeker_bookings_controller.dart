import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../../../../../utils/ToastMsg/toast_message.dart';
import '../../../../../utils/app_colors/app_colors.dart';
import '../model/seeker_booking_model.dart';
import '../screen/booking_details_screen.dart';

class SeekerBookingsController extends GetxController {
  final ScrollController scrollController = ScrollController();

  var bookings = <BookingItemModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isActionLoading = false.obs;

  // Pagination state
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalCount = 0.obs;
  var hasNext = false.obs;

  // Single booking detail state
  var singleBookingDetail = Rxn<BookingDetailModel>();
  var isLoadingDetail = false.obs;

  // Provider public profile state
  var providerPublicProfile = Rxn<PublicProviderModel>();
  var isLoadingProviderProfile = false.obs;

  // Review state
  var isSubmittingReview = false.obs;
  // In-memory session tracking for instant UI updates when user submits a review
  final RxSet<String> reviewedBookingIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings(refresh: true);
    _setupScrollListener();
  }

  void markBookingAsReviewed(String bookingId) {
    if (bookingId.isNotEmpty) {
      reviewedBookingIds.add(bookingId);
    }
  }

  bool isBookingReviewed(String bookingId, {bool? backendHasReviewed}) {
    if (backendHasReviewed == true) return true;
    return reviewedBookingIds.contains(bookingId);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          hasNext.value &&
          !isLoadingMore.value &&
          !isLoading.value) {
        loadMoreBookings();
      }
    });
  }

  /// Sort bookings: Active (In Progress -> Initiated) at TOP, Completed & Cancelled at BOTTOM
  void _sortBookings(List<BookingItemModel> list) {
    int getPriority(BookingItemModel b) {
      if (b.isInProgress) return 0;
      if (b.isInitiated) return 1;
      if (b.isCompleted) return 2;
      return 3; // cancelled / auto_expired
    }

    list.sort((a, b) {
      int pA = getPriority(a);
      int pB = getPriority(b);
      if (pA != pB) return pA.compareTo(pB);
      // Secondary sort: most recent first
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  /// Fetch bookings from backend: GET /api/v1/bookings/seeker/me
  Future<void> fetchBookings({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      isLoading.value = true;
    }

    try {
      final response = await ApiClient.getData(
        ApiUrl.seekerBookingHistory(currentPage.value, pageSize: 20),
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        List itemsJson = data['items'] ?? [];
        List<BookingItemModel> newItems =
            itemsJson.map((e) => BookingItemModel.fromJson(e)).toList();

        totalCount.value = data['total'] ?? newItems.length;
        totalPages.value = data['total_pages'] ?? 1;
        hasNext.value = data['has_next'] ?? false;

        if (refresh) {
          _sortBookings(newItems);
          bookings.assignAll(newItems);
        } else {
          var combined = List<BookingItemModel>.from(bookings)..addAll(newItems);
          _sortBookings(combined);
          bookings.assignAll(combined);
        }
      }
    } catch (e) {
      debugPrint("Error fetching seeker bookings: $e");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more bookings (Pagination: page_size = 20)
  Future<void> loadMoreBookings() async {
    if (hasNext.value && !isLoadingMore.value) {
      isLoadingMore.value = true;
      currentPage.value++;
      await fetchBookings(refresh: false);
    }
  }

  /// Fetch single booking detail: GET /api/v1/bookings/{booking_id}
  Future<void> fetchBookingDetail(String bookingId) async {
    isLoadingDetail.value = true;
    singleBookingDetail.value = null;
    providerPublicProfile.value = null;
    try {
      final response =
          await ApiClient.getData(ApiUrl.singleBookingDetail(bookingId));
      if (response.statusCode == 200 && response.body != null) {
        final detail = BookingDetailModel.fromJson(response.body);
        singleBookingDetail.value = detail;
        if (detail.providerId != null && detail.providerId!.isNotEmpty) {
          fetchProviderPublicProfile(detail.providerId!);
        }
      }
    } catch (e) {
      debugPrint("Error fetching booking detail: $e");
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Fetch provider public profile: GET /api/v1/provider/{provider_id}/public
  Future<void> fetchProviderPublicProfile(String providerId) async {
    isLoadingProviderProfile.value = true;
    try {
      final response = await ApiClient.getData(
        ApiUrl.providerPublicProfile(providerId),
      );
      if (response.statusCode == 200 && response.body != null) {
        providerPublicProfile.value =
            PublicProviderModel.fromJson(response.body);
      }
    } catch (e) {
      debugPrint("Error fetching provider public profile: $e");
    } finally {
      isLoadingProviderProfile.value = false;
    }
  }

  /// Mark booking as completed: PATCH /api/v1/bookings/{booking_id}/complete
  Future<void> markAsCompleted(
    String bookingId, {
    String? providerName,
    String? photoUrl,
  }) async {
    Get.defaultDialog(
      title: 'Complete Service?'.tr,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText:
          'Has the service been finished satisfactorily by the provider?'.tr,
      middleTextStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
      textConfirm: 'Yes, Completed'.tr,
      textCancel: 'Cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () async {
        Get.back(); 
        isActionLoading.value = true;

        try {
          final response = await ApiClient.patchData(
            ApiUrl.completeBooking(bookingId),
            {},
          );

          if (response.statusCode == 200) {
            showCustomSnackBar("Booking marked as completed!".tr,
                isError: false);
            // Refresh list & current detail
            await fetchBookings(refresh: true);
            if (singleBookingDetail.value?.bookingId == bookingId) {
              await fetchBookingDetail(bookingId);
            }

            // Immediately show review form as requested:
            // "Seeker confirms the job is done... Then the review form will show."
            final name = providerName ??
                providerPublicProfile.value?.name ??
                singleBookingDetail.value?.otherPartyName ??
                'Provider';
            final pic = photoUrl ??
                providerPublicProfile.value?.photoUrl ??
                '';
            showReviewBottomSheet(
              bookingId,
              providerName: name,
              photoUrl: pic,
            );
          } else {
            String msg = "Could not complete booking".tr;
            if (response.body is Map && response.body['detail'] != null) {
              msg = response.body['detail'].toString();
            }
            showCustomSnackBar(msg, isError: true);
          }
        } catch (e) {
          debugPrint("Error marking booking completed: $e");
          showCustomSnackBar("Something went wrong".tr, isError: true);
        } finally {
          isActionLoading.value = false;
        }
      },
    );
  }

  /// Submit review: POST /api/v1/reviews
  Future<void> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
    required bool isAnonymous,
  }) async {
    isSubmittingReview.value = true;
    try {
      final body = {
        "booking_id": bookingId,
        "rating": rating,
        if (comment != null && comment.trim().isNotEmpty)
          "comment": comment.trim(),
        "is_anonymous": isAnonymous,
      };

      final response = await ApiClient.postData(ApiUrl.reviews, body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        markBookingAsReviewed(bookingId);
        Get.back(); // close review bottom sheet
        showCustomSnackBar(
          "Thank you! Your review has been submitted.".tr,
          isError: false,
        );
        // Refresh provider public profile to update average rating
        if (singleBookingDetail.value?.providerId != null) {
          await fetchProviderPublicProfile(
              singleBookingDetail.value!.providerId!);
        }
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
          showCustomSnackBar("You have already reviewed this booking".tr, isError: false);
        } else {
          showCustomSnackBar(msg, isError: true);
        }
      }
    } catch (e) {
      debugPrint("Error submitting review: $e");
      showCustomSnackBar("Something went wrong".tr, isError: true);
    } finally {
      isSubmittingReview.value = false;
    }
  }

  /// Bottom sheet for Rating and Review
  void showReviewBottomSheet(
    String bookingId, {
    String providerName = '',
    String photoUrl = '',
  }) {
    final RxInt selectedRating = 0.obs;
    final TextEditingController commentController = TextEditingController();
    final RxBool isAnonymous = true.obs;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
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
                            'Rate & Review Provider'.tr,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            providerName.isNotEmpty
                                ? '${'How was your experience with'.tr} $providerName?'
                                : 'How was your experience with the provider?'.tr,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
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

                // Comment input
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
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Anonymous checkbox
                Obx(() => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: CheckboxListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        title: Text(
                          'Submit review anonymously'.tr,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Your name will not appear on public reviews'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        value: isAnonymous.value,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          isAnonymous.value = val ?? true;
                        },
                      ),
                    )),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                                  await submitReview(
                                    bookingId: bookingId,
                                    rating: selectedRating.value,
                                    comment: commentController.text,
                                    isAnonymous: isAnonymous.value,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
      isScrollControlled: true,
    );
  }

  /// Cancel booking: PATCH /api/v1/bookings/{booking_id}/respond (hired: false)
  Future<void> cancelBooking(String bookingId) async {
    Get.defaultDialog(
      title: 'Cancel Booking?'.tr,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText: 'Are you sure you want to cancel this booking?'.tr,
      middleTextStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
      textConfirm: 'Yes, Cancel'.tr,
      textCancel: 'No, Keep'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade600,
      onConfirm: () async {
        Get.back(); // close dialog
        isActionLoading.value = true;

        try {
          final response = await ApiClient.patchData(
            ApiUrl.respondBooking(bookingId),
            {"hired": false},
          );

          if (response.statusCode == 200) {
            showCustomSnackBar("Booking cancelled successfully".tr,
                isError: false);
            await fetchBookings(refresh: true);
            if (singleBookingDetail.value?.bookingId == bookingId) {
              await fetchBookingDetail(bookingId);
            }
          } else {
            String msg = "Could not cancel booking".tr;
            if (response.body is Map && response.body['detail'] != null) {
              msg = response.body['detail'].toString();
            }
            showCustomSnackBar(msg, isError: true);
          }
        } catch (e) {
          debugPrint("Error cancelling booking: $e");
          showCustomSnackBar("Something went wrong".tr, isError: true);
        } finally {
          isActionLoading.value = false;
        }
      },
    );
  }

  /// Confirm Hire & Schedule: PATCH /api/v1/bookings/{booking_id}/respond (hired: true, work_schedule)
  void showWorkSchedulePicker(String bookingId, {String providerName = ''}) {
    DateTime initial = DateTime.now().add(const Duration(hours: 1));
    initial = DateTime(
      initial.year,
      initial.month,
      initial.day,
      initial.hour,
      (initial.minute / 15).ceil() * 15 % 60,
    );

    var selectedDate = Rx<DateTime>(initial);
    var selectedTime = Rx<TimeOfDay>(
      TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    var errorMessage = ''.obs;

    DateTime getCombinedDateTime() {
      final date = selectedDate.value;
      final time = selectedTime.value;
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: SafeArea(
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'select_work_schedule'.tr,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            providerName.isNotEmpty
                                ? '${'work_schedule_subtitle_provider'.tr}: $providerName'
                                : 'work_schedule_subtitle'.tr,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        final dateStr = DateFormat('EEE, dd MMM yyyy')
                            .format(selectedDate.value);
                        return InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: Get.context!,
                              initialDate: selectedDate.value.isBefore(now)
                                  ? now
                                  : selectedDate.value,
                              firstDate: now,
                              lastDate: now.add(const Duration(days: 60)),
                            );
                            if (picked != null) {
                              selectedDate.value = picked;
                              errorMessage.value = '';
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month,
                                        size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'date'.tr,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final time = selectedTime.value;
                        final hour =
                            time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
                        final minute = time.minute.toString().padLeft(2, '0');
                        final period = time.period == DayPeriod.am ? 'AM' : 'PM';
                        final timeStr = "$hour:$minute $period";

                        return InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: Get.context!,
                              initialTime: selectedTime.value,
                            );
                            if (picked != null) {
                              selectedTime.value = picked;
                              errorMessage.value = '';
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'time'.tr,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                Obx(() {
                  if (errorMessage.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      errorMessage.value,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: isActionLoading.value
                              ? null
                              : () async {
                                  final combined = getCombinedDateTime();
                                  if (combined.isBefore(DateTime.now()
                                      .add(const Duration(minutes: 5)))) {
                                    errorMessage.value =
                                        'work_schedule_must_be_future'.tr;
                                    return;
                                  }
                                  final isoString =
                                      combined.toUtc().toIso8601String();
                                  Get.back(); // close bottom sheet
                                  isActionLoading.value = true;
                                  try {
                                    final response =
                                        await ApiClient.patchData(
                                      ApiUrl.respondBooking(bookingId),
                                      {
                                        "hired": true,
                                        "work_schedule": isoString,
                                      },
                                    );
                                    if (response.statusCode == 200) {
                                      showCustomSnackBar(
                                          "Booking confirmed successfully!".tr,
                                          isError: false);
                                      await fetchBookings(refresh: true);
                                    } else {
                                      showCustomSnackBar(
                                          "Could not confirm booking".tr,
                                          isError: true);
                                    }
                                  } catch (e) {
                                    debugPrint("Error confirming: $e");
                                  } finally {
                                    isActionLoading.value = false;
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: isActionLoading.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Confirm & Hire'.tr,
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
      isScrollControlled: true,
    );
  }

  /// Make phone call to provider
  Future<void> callProvider(String? phone) async {
    if (phone == null || phone.isEmpty) {
      showCustomSnackBar("Number not available".tr, isError: true);
      return;
    }
    final Uri callUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      showCustomSnackBar("Could not launch phone dialer".tr, isError: true);
    }
  }

  /// Open single booking details screen
  void openBookingDetails(String bookingId) {
    Get.to(() => BookingDetailsScreen(bookingId: bookingId));
  }
}
