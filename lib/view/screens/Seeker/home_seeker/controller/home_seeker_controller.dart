import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../../../../../model/category_model.dart';
import '../../../../../model/skill_model.dart';
import '../../../../../model/provider_model.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../../../../../utils/ToastMsg/toast_message.dart';
import '../../../../../utils/app_colors/app_colors.dart';

class HomeSeekerController extends GetxController {
  final CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();
  var selectedCategoryIndex = (-1).obs;

  var categories = <CategoryModel>[].obs;
  var skills = <SkillModel>[].obs;
  var providers = <ProviderModel>[].obs;

  var isLoadingCategories = false.obs;
  var isLoadingSkills = false.obs;
  var isLoadingProviders = false.obs;

  var markers = <Marker>{}.obs;
  var initialPosition = const LatLng(23.7947, 90.4010).obs;

  // Active initiated booking state
  var hasActiveBooking = false.obs;
  var activeBookingData = Rxn<Map<String, dynamic>>();
  var isCancellingBooking = false.obs;
  var isConfirmingBooking = false.obs;
  bool get isBookingActionLoading =>
      isCancellingBooking.value || isConfirmingBooking.value;
  var isInitiatingBooking = false.obs;

  // Last search query context for booking initiate
  int currentSkillId = 0;
  double seekerLat = 0.0;
  double seekerLng = 0.0;

  @override
  void onInit() {
    super.onInit();
    getCategories();
    checkActiveBooking();
  }

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    if (categories.isNotEmpty) {
      getSkills(categories[index].id);
    }
  }

  /// Check if the seeker currently has an active INITIATED booking
  Future<void> checkActiveBooking() async {
    try {
      final response = await ApiClient.getData(ApiUrl.activeBooking);
      if (response.statusCode == 200 && response.body != null) {
        bool hasActive = response.body['has_active_booking'] ?? false;
        hasActiveBooking.value = hasActive;
        if (hasActive && response.body['booking'] != null) {
          activeBookingData.value = Map<String, dynamic>.from(response.body['booking']);
        } else {
          activeBookingData.value = null;
        }
      } else {
        hasActiveBooking.value = false;
        activeBookingData.value = null;
      }
    } catch (e) {
      debugPrint("Error checking active booking: $e");
    }
  }

  Future<void> getCategories() async {
    isLoadingCategories.value = true;
    final response = await ApiClient.getData(ApiUrl.categoryList);
    isLoadingCategories.value = false;
    if (response.statusCode == 200) {
      List data = response.body;
      categories.value = data.map((e) => CategoryModel.fromJson(e)).toList();
    }
  }

  Future<void> getSkills(int categoryId) async {
    isLoadingSkills.value = true;
    final response = await ApiClient.getData(
      ApiUrl.skillList(categoryId.toString()),
    );
    isLoadingSkills.value = false;
    if (response.statusCode == 200) {
      List data = response.body;
      skills.value = data.map((e) => SkillModel.fromJson(e)).toList();
      _showSkillsBottomSheet();
    }
  }

  void _showSkillsBottomSheet() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: SafeArea(
          bottom: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select a Skill",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: skills
                    .map(
                      (skill) => ActionChip(
                        label: Text(skill.name),
                        onPressed: () {
                          Get.back();
                          searchProviders(skill.id);
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> searchProviders(int skillId) async {
    currentSkillId = skillId;

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Error", "Location permissions are denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        "Error",
        "Location permissions are permanently denied, we cannot request permissions.",
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    seekerLat = position.latitude;
    seekerLng = position.longitude;
    initialPosition.value = LatLng(position.latitude, position.longitude);

    isLoadingProviders.value = true;
    final response = await ApiClient.getData(
      "${ApiUrl.searchProviders}?skill_id=$skillId&seeker_lat=${position.latitude}&seeker_lng=${position.longitude}&search_radius_km=5",
    );
    isLoadingProviders.value = false;

    if (response.statusCode == 200) {
      List data = response.body['items'] ?? response.body['providers'] ?? [];
      providers.value = data.map((e) => ProviderModel.fromJson(e)).toList();
      _updateMarkers(position);

      if (providers.isEmpty && response.body['warning'] != null) {
        String warning = response.body['warning'].toString();
        Get.snackbar(
          "Notice".tr,
          warning,
          backgroundColor: Colors.amber.shade100,
          colorText: Colors.black87,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }

      // Check active booking status whenever search runs
      await checkActiveBooking();

      // Force map refresh to show markers immediately
      Future.delayed(const Duration(milliseconds: 200), () {
        if (customInfoWindowController.googleMapController != null) {
          customInfoWindowController.googleMapController!.animateCamera(
            CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
          );
        }
      });
    }
  }

  void _updateMarkers(Position currentPosition) {
    var newMarkers = <Marker>{};
    for (int i = 0; i < providers.length; i++) {
      var provider = providers[i];
      double lat = provider.latitude != 0 ? provider.latitude : 0;
      double lng = provider.longitude != 0 ? provider.longitude : 0;

      if (lat == 0 || lng == 0) {
        // Distribute markers in a circle around seeker based on distanceKm
        final double angle = (2 * math.pi / (providers.isEmpty ? 1 : providers.length)) * i;
        final double distKm = provider.distanceKm > 0 ? provider.distanceKm : (0.5 + (i * 0.3));
        final double dLat = (distKm / 111.0) * math.cos(angle);
        final double dLng = (distKm / (111.0 * math.cos(currentPosition.latitude * math.pi / 180))) * math.sin(angle);
        lat = currentPosition.latitude + dLat;
        lng = currentPosition.longitude + dLng;
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId(provider.userId.isNotEmpty ? provider.userId : 'provider_$i'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          consumeTapEvents: true, // Non-clickable marker: only displays on map
        ),
      );
    }
    markers.assignAll(newMarkers);
  }

  /// 1. Request to Call: Initiate booking with backend and get phone number
  Future<void> initiateBooking(ProviderModel provider) async {
    if (isInitiatingBooking.value) return;
    isInitiatingBooking.value = true;

    try {
      if (seekerLat == 0.0 || seekerLng == 0.0) {
        try {
          Position pos = await Geolocator.getCurrentPosition();
          seekerLat = pos.latitude;
          seekerLng = pos.longitude;
        } catch (_) {
          seekerLat = initialPosition.value.latitude;
          seekerLng = initialPosition.value.longitude;
        }
      }

      int skillIdToSend = currentSkillId;
      if (skillIdToSend == 0 && skills.isNotEmpty) {
        skillIdToSend = skills.first.id;
      }
      if (skillIdToSend == 0) {
        skillIdToSend = 1;
      }

      final Map<String, dynamic> requestBody = {
        "provider_id": provider.userId,
        "skill_id": skillIdToSend,
        "latitude": seekerLat,
        "longitude": seekerLng,
      };

      final response = await ApiClient.postData(
        ApiUrl.initiateBooking,
        requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body;
        String phone = data['provider_phone'] ?? provider.phoneEn ?? '';
        String providerName = data['provider_name'] ?? provider.name;
        String bookingId = data['booking_id']?.toString() ?? '';

        // Update active booking status
        hasActiveBooking.value = true;
        activeBookingData.value = {
          'booking_id': bookingId,
          'provider_name': providerName,
          'provider_phone': phone,
          'status': 'initiated',
          'created_at': DateTime.now().toIso8601String(),
        };

        // Show Call Dialog with provider details
        _showCallProviderDialog(
          providerName: providerName,
          phone: phone,
          bookingId: bookingId,
        );
      } else {
        String msg = "Could not initiate booking".tr;
        if (response.body is Map && response.body['detail'] != null) {
          msg = response.body['detail'].toString();
        }
        showCustomSnackBar(msg);
        // Refresh active booking state in case one was already active
        await checkActiveBooking();
      }
    } catch (e) {
      debugPrint("Error initiating booking: $e");
      showCustomSnackBar("Something went wrong".tr);
    } finally {
      isInitiatingBooking.value = false;
    }
  }

  /// Show popup with provider's contact number and Call button
  void _showCallProviderDialog({
    required String providerName,
    required String phone,
    required String bookingId,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_in_talk, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Contact Provider'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'call_provider_confirm_msg'.trParams({'name': providerName}),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      phone.isNotEmpty ? phone : "Number not available".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              checkActiveBooking();
            },
            child: Text('Close'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              Get.back(); // close dialog
              if (phone.isNotEmpty) {
                final Uri launchUri = Uri(scheme: 'tel', path: phone);
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri);
                } else {
                  showCustomSnackBar('Could not launch phone app'.tr);
                }
              }
              // When user returns to app, reload last active initiated booking
              await checkActiveBooking();
            },
            icon: const Icon(Icons.call, color: Colors.white, size: 18),
            label: Text(
              'Call Now'.tr,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 2. Cancel Booking
  Future<void> cancelBooking(String bookingId) async {
    if (isCancellingBooking.value || isConfirmingBooking.value) return;
    isCancellingBooking.value = true;

    try {
      final response = await ApiClient.patchData(
        ApiUrl.respondBooking(bookingId),
        {"hired": false},
      );

      if (response.statusCode == 200) {
        showCustomSnackBar("Booking cancelled successfully".tr, isError: false);
        hasActiveBooking.value = false;
        activeBookingData.value = null;
        Get.until((route) => route.isFirst); // Return to home screen
      } else {
        String msg = "Could not cancel booking".tr;
        if (response.body is Map && response.body['detail'] != null) {
          msg = response.body['detail'].toString();
        }
        showCustomSnackBar(msg);
      }
    } catch (e) {
      debugPrint("Error cancelling booking: $e");
      showCustomSnackBar("Something went wrong".tr);
    } finally {
      isCancellingBooking.value = false;
      await checkActiveBooking();
    }
  }

  /// 3. Confirm Hire Booking
  Future<void> confirmHireBooking(String bookingId) async {
    // Backend requires a future work_schedule when hired is true.
    // Default to +2 hours from now, or allow prompt
    DateTime defaultSchedule = DateTime.now().add(const Duration(hours: 2)).toUtc();

    if (isCancellingBooking.value || isConfirmingBooking.value) return;
    isConfirmingBooking.value = true;

    try {
      final response = await ApiClient.patchData(
        ApiUrl.respondBooking(bookingId),
        {
          "hired": true,
          "work_schedule": defaultSchedule.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        showCustomSnackBar("Booking confirmed successfully!".tr, isError: false);
        hasActiveBooking.value = false;
        activeBookingData.value = null;
        Get.until((route) => route.isFirst); // Return to home screen
      } else {
        String msg = "Could not confirm booking".tr;
        if (response.body is Map && response.body['detail'] != null) {
          msg = response.body['detail'].toString();
        }
        showCustomSnackBar(msg);
      }
    } catch (e) {
      debugPrint("Error confirming booking: $e");
      showCustomSnackBar("Something went wrong".tr);
    } finally {
      isConfirmingBooking.value = false;
      await checkActiveBooking();
    }
  }
}
