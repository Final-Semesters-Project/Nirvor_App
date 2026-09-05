import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../model/category_model.dart';
import '../../../../../model/skill_model.dart';
import '../../../../../model/provider_model.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';

class HomeSeekerController extends GetxController {
  var selectedCategoryIndex = 0.obs;

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
          middleText: "You have an active booking. Please confirm or cancel it.",
          barrierDismissible: false,
          confirm: ElevatedButton(onPressed: () => Get.back(), child: const Text("Confirm")),
          cancel: TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
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
    final response = await ApiClient.getData(ApiUrl.skillList(categoryId.toString()));
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
              const Text("Select a Skill", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: skills.map((skill) => ActionChip(
                  label: Text(skill.name),
                  onPressed: () {
                    Get.back();
                    searchProviders(skill.id);
                  },
                )).toList(),
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
      Get.snackbar("Error", "Location permissions are permanently denied, we cannot request permissions.");
      return;
    } 

    Position position = await Geolocator.getCurrentPosition();
    initialPosition.value = LatLng(position.latitude, position.longitude);
    
    isLoadingProviders.value = true;
    final response = await ApiClient.getData(
      "${ApiUrl.searchProviders}?skill_id=$skillId&seeker_lat=${position.latitude}&seeker_lng=${position.longitude}&search_radius_km=5"
    );
    isLoadingProviders.value = false;
    
    if (response.statusCode == 200) {
      List data = response.body['providers'] ?? [];
      providers.value = data.map((e) => ProviderModel.fromJson(e)).toList();
      _updateMarkers(position);
    }
  }
  
  void _updateMarkers(Position currentPosition) {
    markers.clear();
    for (int i = 0; i < providers.length; i++) {
      var provider = providers[i];
      // Note: If backend doesn't provide real latitude/longitude in the response,
      // we mock it around the user's current position for demonstration using `distanceKm`.
      double lat = provider.latitude != 0 ? provider.latitude : currentPosition.latitude + (i * 0.001);
      double lng = provider.longitude != 0 ? provider.longitude : currentPosition.longitude + (i * 0.001);
      
      markers.add(
        Marker(
          markerId: MarkerId(provider.userId),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: provider.name, snippet: provider.verificationLevel),
        )
      );
    }
  }
}
