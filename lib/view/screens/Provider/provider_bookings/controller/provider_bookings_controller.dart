import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../../../../../utils/ToastMsg/toast_message.dart';
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
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        showCustomSnackBar("Could not launch phone dialer".tr, isError: true);
      }
    } catch (e) {
      debugPrint("Error launching phone dialer: $e");
      showCustomSnackBar("Could not launch phone dialer".tr, isError: true);
    }
  }

  /// Open job location on Google Maps
  Future<void> openMapLocation(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      showCustomSnackBar("Location coordinates not available".tr, isError: true);
      return;
    }
    final Uri mapUri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    try {
      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      } else {
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

  /// Open details screen
  void openBookingDetails(String bookingId, {String? skillName, String? seekerName}) {
    Get.to(
      () => ProviderBookingDetailsScreen(
        bookingId: bookingId,
        skillName: skillName,
        seekerName: seekerName,
      ),
    );
  }
}

