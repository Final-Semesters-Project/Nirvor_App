import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../../../../../utils/ToastMsg/toast_message.dart';
import '../../home_seeker/controller/home_seeker_controller.dart';
import '../model/user_model.dart';

class SeekerProfileController extends GetxController {
  var user = Rxn<UserModel>();
  var isLoading = false.obs;
  var isUpdatingProfile = false.obs;

  // Seeker home address & coordinates
  var homeAddress = ''.obs;
  var homeLatitude = 0.0.obs;
  var homeLongitude = 0.0.obs;

  // Location Autocomplete Search
  var isLocationSearching = false.obs;
  var locationSuggestions = <Map<String, dynamic>>[].obs;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    getUserProfile();
    fetchSeekerAddress();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  /// 1. Fetch user profile from /users/me
  Future<void> getUserProfile() async {
    isLoading.value = true;
    final response = await ApiClient.getData(ApiUrl.userProfile);
    isLoading.value = false;

    if (response.statusCode == 200) {
      user.value = UserModel.fromJson(response.body);
      if (user.value != null) {
        if (user.value!.homeAddress.isNotEmpty && homeAddress.value.isEmpty) {
          homeAddress.value = user.value!.homeAddress;
        }
        if (user.value!.homeLatitude != null && homeLatitude.value == 0.0) {
          homeLatitude.value = user.value!.homeLatitude!;
        }
        if (user.value!.homeLongitude != null && homeLongitude.value == 0.0) {
          homeLongitude.value = user.value!.homeLongitude!;
        }
        if (user.value!.homeAddress.isNotEmpty) {
          await ensureHomeLocationCached(user.value!.homeAddress);
        }
      }
    }
  }

  /// 2. Fetch seeker address from GET /api/v1/seeker/me/address
  Future<void> fetchSeekerAddress() async {
    try {
      final response = await ApiClient.getData(ApiUrl.seekerAddress);
      if (response.statusCode == 200) {
        final data = response.body is Map ? response.body : jsonDecode(response.body);
        if (data != null) {
          final String? addr = data['home_address']?.toString();
          final double? lat = data['latitude'] != null
              ? double.tryParse(data['latitude'].toString())
              : null;
          final double? lng = data['longitude'] != null
              ? double.tryParse(data['longitude'].toString())
              : null;

          if (addr != null && addr.isNotEmpty) {
            homeAddress.value = addr;
            await SharePrefsHelper.setString("seeker_home_address", addr);
          }
          if (lat != null && lat != 0.0) {
            homeLatitude.value = lat;
            await SharePrefsHelper.setString("seeker_home_lat", lat.toString());
          }
          if (lng != null && lng != 0.0) {
            homeLongitude.value = lng;
            await SharePrefsHelper.setString("seeker_home_lng", lng.toString());
          }

          if (user.value != null && (addr != null || lat != null || lng != null)) {
            user.value = UserModel(
              userId: user.value!.userId,
              role: user.value!.role,
              phone: user.value!.phone,
              name: user.value!.name,
              isActive: user.value!.isActive,
              createdAt: user.value!.createdAt,
              photoUrl: user.value!.photoUrl,
              homeAddress: addr ?? user.value!.homeAddress,
              homeLatitude: lat ?? user.value!.homeLatitude,
              homeLongitude: lng ?? user.value!.homeLongitude,
            );
            update();
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching seeker address: $e");
    }
  }

  /// Location query debounced search (matching provider setup pattern)
  void onLocationQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        searchLocation(query.trim());
      } else {
        locationSuggestions.clear();
      }
    });
  }

  /// Search places via Google Places Autocomplete API with Nominatim fallback
  Future<void> searchLocation(String query) async {
    isLocationSearching.value = true;
    try {
      final lang = Get.locale?.languageCode ?? 'en';
      final cleanQuery = query.replaceAll(',', ', ').replaceAll(RegExp(r'\s+'), ' ').trim();

      // 1. Google Places Autocomplete API
      if (ApiUrl.mapKey.isNotEmpty) {
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/place/autocomplete/json',
          {
            'input': cleanQuery,
            'key': ApiUrl.mapKey,
            'components': 'country:bd',
            'language': lang,
          },
        );
        final response = await http.get(uri).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' && data['predictions'] != null) {
            final List predictions = data['predictions'];
            locationSuggestions.value = predictions.map((p) {
              final sf = p['structured_formatting'];
              return {
                'place_id': p['place_id'],
                'name': sf?['main_text'] ?? p['description'] ?? '',
                'display_name': p['description'] ?? '',
                'secondary_text': sf?['secondary_text'] ?? '',
              };
            }).toList();
            isLocationSearching.value = false;
            return;
          }
        }
      }

      // 2. Fallback: OpenStreetMap Nominatim
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': cleanQuery,
          'format': 'json',
          'addressdetails': '1',
          'countrycodes': 'bd',
          'limit': '10',
          'accept-language': lang,
        },
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'NirbhorApp/1.0',
        'Accept-Language': lang,
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        locationSuggestions.value = data.map((item) => {
          'lat': item['lat'],
          'lon': item['lon'],
          'name': item['name'] ?? '',
          'display_name': item['display_name'] ?? '',
          'secondary_text': item['display_name'] ?? '',
        }).toList();
      } else {
        locationSuggestions.clear();
      }
    } catch (e) {
      debugPrint("Location search error: $e");
      locationSuggestions.clear();
    } finally {
      isLocationSearching.value = false;
    }
  }

  /// Select location from suggestions and resolve exact coordinates
  Future<String> selectLocationSuggestion(Map<String, dynamic> location) async {
    final String name = location['name']?.toString() ?? '';
    final String displayName = location['display_name']?.toString() ?? '';
    final String chosenAddress = displayName.isNotEmpty ? displayName : name;
    homeAddress.value = chosenAddress;
    locationSuggestions.clear();

    final String? placeId = location['place_id']?.toString();
    if (placeId != null && placeId.isNotEmpty && ApiUrl.mapKey.isNotEmpty) {
      try {
        final lang = Get.locale?.languageCode ?? 'en';
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/place/details/json',
          {
            'place_id': placeId,
            'key': ApiUrl.mapKey,
            'fields': 'geometry,formatted_address,name',
            'language': lang,
          },
        );
        final response = await http.get(uri).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' && data['result'] != null) {
            final geom = data['result']['geometry']?['location'];
            if (geom != null) {
              homeLatitude.value = double.tryParse(geom['lat']?.toString() ?? '0') ?? 0.0;
              homeLongitude.value = double.tryParse(geom['lng']?.toString() ?? '0') ?? 0.0;
            }
            final String? formatted = data['result']['formatted_address'];
            if (formatted != null && formatted.isNotEmpty) {
              homeAddress.value = formatted;
              return formatted;
            }
          }
        }
      } catch (e) {
        debugPrint("Place details error: $e");
      }
    } else {
      homeLatitude.value = double.tryParse(location['lat']?.toString() ?? '0') ?? 0.0;
      homeLongitude.value = double.tryParse(location['lon']?.toString() ?? '0') ?? 0.0;
    }

    // Fallback if Place Details did not resolve coordinates
    if (homeLatitude.value == 0.0 || homeLongitude.value == 0.0) {
      final coords = await geocodeAddress(chosenAddress);
      if (coords != null) {
        homeLatitude.value = coords['lat'] ?? 0.0;
        homeLongitude.value = coords['lng'] ?? 0.0;
      }
    }

    return chosenAddress;
  }

  /// Set location returned from MapLocationPickerScreen
  void setLocationFromPicker({
    required String address,
    required double latitude,
    required double longitude,
  }) {
    homeAddress.value = address;
    homeLatitude.value = latitude;
    homeLongitude.value = longitude;
    locationSuggestions.clear();
  }

  /// Geocode address if user typed manually without selecting suggestion or map
  Future<Map<String, double>?> geocodeAddress(String address) async {
    try {
      if (ApiUrl.mapKey.isNotEmpty) {
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/geocode/json',
          {
            'address': address,
            'key': ApiUrl.mapKey,
            'components': 'country:bd',
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
                return {'lat': lat, 'lng': lng};
              }
            }
          }
        }
      }

      // Nominatim Fallback
      final encodedQuery = Uri.encodeComponent(address);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&countrycodes=bd&limit=1',
      );
      final res = await http.get(url, headers: {
        'User-Agent': 'NirbhorApp/1.0',
      }).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat']?.toString() ?? '0') ?? 0.0;
          final lon = double.tryParse(data[0]['lon']?.toString() ?? '0') ?? 0.0;
          if (lat != 0.0 && lon != 0.0) {
            return {'lat': lat, 'lng': lon};
          }
        }
      }
    } catch (e) {
      debugPrint("Error geocoding address: $e");
    }
    return null;
  }

  /// 3. Update Seeker Address & Profile via PATCH /api/v1/seeker/me/address
  Future<bool> updateSeekerAddressAndProfile({
    required String name,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    final cleanName = name.trim();
    final cleanAddress = address.trim();

    if (cleanName.isEmpty) {
      showCustomSnackBar("Please enter your name".tr, isError: true);
      return false;
    }

    if (cleanAddress.isEmpty) {
      showCustomSnackBar("Please enter an address".tr, isError: true);
      return false;
    }

    if (cleanAddress.length < 5) {
      showCustomSnackBar("Address must be at least 5 characters".tr, isError: true);
      return false;
    }

    isUpdatingProfile.value = true;
    try {
      double finalLat = latitude ?? homeLatitude.value;
      double finalLng = longitude ?? homeLongitude.value;

      // If the address text was changed and coordinates were not freshly set via picker or suggestions,
      // re-geocode the address so that old coordinates are not kept.
      final bool addressChanged = homeAddress.value.isNotEmpty && cleanAddress != homeAddress.value;
      if (addressChanged || finalLat == 0.0 || finalLng == 0.0) {
        debugPrint("Re-geocoding address: $cleanAddress");
        final coords = await geocodeAddress(cleanAddress);
        if (coords != null && coords['lat'] != 0.0 && coords['lng'] != 0.0) {
          finalLat = coords['lat']!;
          finalLng = coords['lng']!;
        } else if (finalLat == 0.0 || finalLng == 0.0) {
          // If geocoding failed and no coords available, try device GPS
          try {
            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (serviceEnabled) {
              LocationPermission permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
              }
              if (permission == LocationPermission.whileInUse ||
                  permission == LocationPermission.always) {
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                  timeLimit: const Duration(seconds: 4),
                );
                finalLat = position.latitude;
                finalLng = position.longitude;
              }
            }
          } catch (e) {
            debugPrint("GPS fallback error: $e");
          }
        }
      }

      // Check if we still have no coordinates
      if (finalLat == 0.0 || finalLng == 0.0) {
        showCustomSnackBar(
          "Please pin your location on the map to get accurate coordinates".tr,
          isError: true,
        );
        isUpdatingProfile.value = false;
        return false;
      }

      final body = {
        "latitude": finalLat,
        "longitude": finalLng,
        "home_address": cleanAddress,
      };

      debugPrint("====> PATCH Seeker Address Body: $body");
      final response = await ApiClient.patchData(
        ApiUrl.seekerAddress,
        body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        homeAddress.value = cleanAddress;
        homeLatitude.value = finalLat;
        homeLongitude.value = finalLng;

        await SharePrefsHelper.setString("seeker_home_address", cleanAddress);
        await SharePrefsHelper.setString("seeker_home_lat", finalLat.toString());
        await SharePrefsHelper.setString("seeker_home_lng", finalLng.toString());

        // Refresh user profile and seeker address from server
        await getUserProfile();
        await fetchSeekerAddress();

        // Keep HomeSeekerController synced
        if (Get.isRegistered<HomeSeekerController>()) {
          Get.find<HomeSeekerController>().loadHomeLocationData();
        }

        return true;
      } else {
        String errMsg = "Failed to update address".tr;
        if (response.body != null && response.body is Map && response.body['detail'] != null) {
          errMsg = response.body['detail'].toString();
        }
        showCustomSnackBar(errMsg, isError: true);
        return false;
      }
    } catch (e) {
      debugPrint("Error updating seeker address: $e");
      showCustomSnackBar("An error occurred while updating address".tr, isError: true);
      return false;
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  /// Ensure home address and coordinates are cached in SharedPreferences
  Future<void> ensureHomeLocationCached(String address) async {
    try {
      await SharePrefsHelper.setString("seeker_home_address", address);
      String cachedLat = await SharePrefsHelper.getString("seeker_home_lat");
      String cachedLng = await SharePrefsHelper.getString("seeker_home_lng");

      if (cachedLat.isEmpty || cachedLng.isEmpty || cachedLat == '0.0') {
        final coords = await geocodeAddress(address);
        if (coords != null) {
          await SharePrefsHelper.setString("seeker_home_lat", coords['lat'].toString());
          await SharePrefsHelper.setString("seeker_home_lng", coords['lng'].toString());
          homeLatitude.value = coords['lat']!;
          homeLongitude.value = coords['lng']!;
          debugPrint("Successfully cached home lat/lng: ${coords['lat']}, ${coords['lng']}");
        }
      }
    } catch (e) {
      debugPrint("Error ensuring home location cached: $e");
    }
  }

  // Placeholder for updating name only
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
