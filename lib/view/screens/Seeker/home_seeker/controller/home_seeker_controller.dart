import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'dart:math' as math;
import '../../../../../model/category_model.dart';
import '../../../../../model/skill_model.dart';
import '../../../../../model/provider_model.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';

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

  Future<void> checkActiveBooking() async {
    final response = await ApiClient.getData(ApiUrl.activeBooking);
    if (response.statusCode == 200) {
      bool hasActive = response.body['has_active_booking'] ?? false;
      if (hasActive) {
        Get.defaultDialog(
          title: "Active Booking",
          middleText:
              "You have an active booking. Please confirm or cancel it.",
          barrierDismissible: false,
          confirm: ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text("Confirm"),
          ),
          cancel: TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
        );
      }
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
    initialPosition.value = LatLng(position.latitude, position.longitude);

    isLoadingProviders.value = true;
    final response = await ApiClient.getData(
      "${ApiUrl.searchProviders}?skill_id=$skillId&seeker_lat=${position.latitude}&seeker_lng=${position.longitude}&search_radius_km=5",
    );
    isLoadingProviders.value = false;

    if (response.statusCode == 200) {
      List data = response.body['providers'] ?? [];
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          consumeTapEvents: true, // Non-clickable marker: only displays on map
        ),
      );
    }
    markers.assignAll(newMarkers);
  }
}
