import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../model/user_model.dart';

class SeekerProfileController extends GetxController {
  var user = Rxn<UserModel>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getUserProfile();
  }

  Future<void> getUserProfile() async {
    isLoading.value = true;
    final response = await ApiClient.getData(ApiUrl.userProfile);
    isLoading.value = false;
    
    if (response.statusCode == 200) {
      user.value = UserModel.fromJson(response.body);
      if (user.value != null && user.value!.homeAddress.isNotEmpty) {
        await ensureHomeLocationCached(user.value!.homeAddress);
      }
    }
  }

  /// Ensure home address and coordinates are cached in SharedPreferences for seamless search
  Future<void> ensureHomeLocationCached(String address) async {
    try {
      await SharePrefsHelper.setString("seeker_home_address", address);
      String cachedLat = await SharePrefsHelper.getString("seeker_home_lat");
      String cachedLng = await SharePrefsHelper.getString("seeker_home_lng");

      if (cachedLat.isEmpty || cachedLng.isEmpty || cachedLat == '0.0') {
        // Geocode the address using Google Geocoding API
        if (ApiUrl.mapKey.isNotEmpty) {
          final uri = Uri.https(
            'maps.googleapis.com',
            '/maps/api/geocode/json',
            {
              'address': address,
              'key': ApiUrl.mapKey,
            },
          );
          final res = await http.get(uri).timeout(const Duration(seconds: 5));
          if (res.statusCode == 200) {
            final data = json.decode(res.body);
            if (data['status'] == 'OK' &&
                data['results'] != null &&
                (data['results'] as List).isNotEmpty) {
              final loc = data['results'][0]['geometry']?['location'];
              if (loc != null) {
                double lat = double.tryParse(loc['lat'].toString()) ?? 0.0;
                double lng = double.tryParse(loc['lng'].toString()) ?? 0.0;
                if (lat != 0.0 && lng != 0.0) {
                  await SharePrefsHelper.setString("seeker_home_lat", lat.toString());
                  await SharePrefsHelper.setString("seeker_home_lng", lng.toString());
                  debugPrint("Successfully cached home lat/lng: $lat, $lng");
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error ensuring home location cached: $e");
    }
  }

  // Placeholder for missing update API
  Future<void> updateProfile({required String name}) async {
    if (user.value != null) {
      user.value = UserModel(
        userId: user.value!.userId,
        role: user.value!.role,
        phone: user.value!.phone,
        name: name,
        isActive: user.value!.isActive,
        createdAt: user.value!.createdAt,
        photoUrl: user.value!.photoUrl,
        homeAddress: user.value!.homeAddress,
        homeLatitude: user.value!.homeLatitude,
        homeLongitude: user.value!.homeLongitude,
      );
      update();
    }
  }
}
