import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nirbhor/utils/ToastMsg/toast_message.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../core/app_routes/app_routes.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../utils/app_const/app_const.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  // Category & Skills State
  RxList<dynamic> categories = <dynamic>[].obs;
  RxList<String> selectedCategories = <String>[].obs;
  RxMap<String, List<dynamic>> categorySkills = <String, List<dynamic>>{}.obs;
  RxList<String> selectedSkills = <String>[].obs;

  // Setup Details State
  RxDouble workRadius = 1.0.obs;
  RxBool hasSmartphone = false.obs;

  // Location State
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  RxString locationAddress = ''.obs;
  RxList<dynamic> locationSuggestions = <dynamic>[].obs;
  RxBool isLocationSearching = false.obs;
  Timer? _debounce;
  TextEditingController locationController = TextEditingController();

  // Loading States
  RxBool isCategoryLoading = false.obs;
  RxBool isSkillsLoading = false.obs;
  RxBool isAuthLoading = false.obs;

  @override
  void onClose() {
    _debounce?.cancel();
    locationController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isCategoryLoading.value = true;
    try {
      final response = await ApiClient.getData(ApiUrl.categoryList);
      debugPrint("fetchCategories status: ${response.statusCode}, body: ${response.body}");
      if (response.statusCode == 200) {
        if (response.body != null && response.body is List) {
          categories.value = response.body;
        } else if (response.body != null && response.body is String) {
          final decoded = json.decode(response.body);
          if (decoded is List) {
            categories.value = decoded;
          }
        }
      } else {
        debugPrint("Failed to fetch categories: [${response.statusCode}] ${response.statusText}");
      }
    } catch (e) {
      debugPrint("Fetch categories error: $e");
    } finally {
      isCategoryLoading.value = false;
    }
  }

  Future<void> fetchSkills(String categoryId) async {
    if (categorySkills.containsKey(categoryId)) return;
    
    isSkillsLoading.value = true;
    final response = await ApiClient.getData(ApiUrl.skillList(categoryId));
    if (response.statusCode == 200) {
      if (response.body != null && response.body is List) {
        categorySkills[categoryId] = response.body;
      }
    } else {
      debugPrint("Failed to fetch skills for $categoryId: ${response.statusText}");
    }
    isSkillsLoading.value = false;
  }

  Future<void> toggleCategory(String categoryId) async {
    if (selectedCategories.contains(categoryId)) {
      selectedCategories.remove(categoryId);
      // Optional: remove selected skills for this category
      if (categorySkills.containsKey(categoryId)) {
        for (var skill in categorySkills[categoryId]!) {
          selectedSkills.remove(skill['id'].toString());
        }
      }
    } else {
      selectedCategories.add(categoryId);
      await fetchSkills(categoryId);
    }
  }

  void toggleSkill(String skillId) {
    if (selectedSkills.contains(skillId)) {
      selectedSkills.remove(skillId);
    } else {
      selectedSkills.add(skillId);
    }
  }

  void onLocationChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        searchLocation(query);
      } else {
        locationSuggestions.clear();
      }
    });
  }

  Future<void> searchLocation(String query) async {
    isLocationSearching.value = true;
    try {
      final lang = Get.locale?.languageCode ?? 'en';
      final cleanQuery = query.replaceAll(',', ', ').replaceAll(RegExp(r'\s+'), ' ').trim();

      // 1. Primary: Use Google Places Autocomplete API with mapKey (Instant, accurate, no DNS/Socket issues)
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

        data.sort((a, b) {
          final String nameA = (a['name'] ?? '').toString().toLowerCase();
          final String nameB = (b['name'] ?? '').toString().toLowerCase();
          final String q = cleanQuery.toLowerCase();
          final String firstToken = q.split(',').first.trim();

          final bool aExact = nameA == q || nameA == firstToken;
          final bool bExact = nameB == q || nameB == firstToken;
          if (aExact && !bExact) return -1;
          if (!aExact && bExact) return 1;

          final bool aStarts = nameA.startsWith(firstToken);
          final bool bStarts = nameB.startsWith(firstToken);
          if (aStarts && !bStarts) return -1;
          if (!aStarts && bStarts) return 1;

          final double impA = double.tryParse(a['importance']?.toString() ?? '0') ?? 0.0;
          final double impB = double.tryParse(b['importance']?.toString() ?? '0') ?? 0.0;
          return impB.compareTo(impA);
        });

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
    }
    isLocationSearching.value = false;
  }

  Future<void> selectLocation(Map<String, dynamic> location) async {
    final String name = location['name']?.toString() ?? '';
    final String displayName = location['display_name']?.toString() ?? '';
    locationAddress.value = displayName.isNotEmpty ? displayName : name;
    locationController.text = displayName.isNotEmpty ? displayName : name;
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
              latitude.value = double.tryParse(geom['lat']?.toString() ?? '0') ?? 0.0;
              longitude.value = double.tryParse(geom['lng']?.toString() ?? '0') ?? 0.0;
            }
            final String? formatted = data['result']['formatted_address'];
            if (formatted != null && formatted.isNotEmpty) {
              locationAddress.value = formatted;
              locationController.text = formatted;
            }
          }
        }
      } catch (e) {
        debugPrint("Place details error: $e");
      }
    } else {
      latitude.value = double.tryParse(location['lat'].toString()) ?? 0.0;
      longitude.value = double.tryParse(location['lon'].toString()) ?? 0.0;
    }
  }

  Future<String?> reverseGeocode(double lat, double lng) async {
    final lang = Get.locale?.languageCode ?? 'en';

    // 1. Google Geocoding API with ApiUrl.mapKey
    if (ApiUrl.mapKey.isNotEmpty) {
      try {
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/geocode/json',
          {
            'latlng': '$lat,$lng',
            'key': ApiUrl.mapKey,
            'language': lang,
          },
        );
        final response = await http.get(uri).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' &&
              data['results'] != null &&
              (data['results'] as List).isNotEmpty) {
            final formatted = data['results'][0]['formatted_address']?.toString();
            if (formatted != null && formatted.isNotEmpty) {
              return formatted;
            }
          }
        }
      } catch (e) {
        debugPrint("Google reverse geocode error: $e");
      }
    }

    // 2. Nominatim fallback
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'lat': lat.toString(),
          'lon': lng.toString(),
          'format': 'json',
          'accept-language': lang,
        },
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'NirbhorApp/1.0',
        'Accept-Language': lang,
      }).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayName = data['display_name']?.toString();
        if (displayName != null && displayName.isNotEmpty) {
          return displayName;
        }
      }
    } catch (e) {
      debugPrint("Nominatim reverse geocode error: $e");
    }

    return null;
  }

  Future<void> login(String phone, String password) async {
    isAuthLoading.value = true;
    Map<String, String> body = {"username": phone, "password": password};
    final response = await ApiClient.postData(
      ApiUrl.signIn,
      body,
      isContentType: false,
    );

    if (response.statusCode == 200) {
      if (response.body != null && response.body['access_token'] != null) {
        await SharePrefsHelper.setString(
          AppConstants.bearerToken,
          "Bearer ${response.body['access_token']}",
        );
        if (response.body['refresh_token'] != null) {
          await SharePrefsHelper.setString(
            AppConstants.refreshToken,
            response.body['refresh_token'],
          );
        }
        if (response.body['role'] != null) {
          await SharePrefsHelper.setString(
            AppConstants.role,
            response.body['role'],
          );
        }
      }
      showCustomSnackBar("Login successful".tr, isError: false);
      await sendFcmToken();
      // Navigate to home depending on role. Example:
      if(response.body['role'] == 'provider'){
        Get.offAllNamed(AppRoutes.providerHomeScreen);
      }else{
        Get.offAllNamed(AppRoutes.homeSeekerScreen);
      }
    } 
    else {
      String errorMsg = "Login failed".tr;
      if (response.body != null && response.body is Map) {
        if (response.body['message'] != null) {
          errorMsg = response.body['message'];
        } else if (response.body['detail'] != null) {
          var detail = response.body['detail'];
          if (detail is String) {
            errorMsg = detail;
          } else if (detail is List && detail.isNotEmpty) {
            if (detail[0] is Map && detail[0]['msg'] != null) {
              errorMsg = detail[0]['msg'];
            } else {
              errorMsg = detail[0].toString();
            }
          } else {
            errorMsg = detail.toString();
          }
        }
      } else if (response.statusText != null) {
        errorMsg = response.statusText!;
      }
      showCustomSnackBar(errorMsg, isError: true);
    }
    isAuthLoading.value = false;
  }

  Future<void> register({
    required String phone,
    required String nameEn,
    required String nameBn,
    required String password,
    required String role,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    isAuthLoading.value = true;

    Map<String, dynamic> body = {
      "phone": phone,
      "name_en": nameEn,
      "name_bn": nameBn,
      "password": password,
      "preferred_lang": Get.locale?.languageCode ?? 'en',
    };

    String endpoint = ApiUrl.signUpSeeker;

    if (role.toLowerCase() == "provider") {
      endpoint = ApiUrl.signUpProvider;
      body["skill_ids"] = selectedSkills.map((e) => int.parse(e)).toList();

      double lat = latitude ?? this.latitude.value;
      double lng = longitude ?? this.longitude.value;
      String baseAddr = address ?? locationAddress.value.trim();
      if (baseAddr.isEmpty && locationController.text.trim().isNotEmpty) {
        baseAddr = locationController.text.trim();
      }

      if (lat == 0.0 || lng == 0.0) {
        lat = 23.8103;
        lng = 90.4125;
      }
      if (baseAddr.length < 5) {
        baseAddr = await reverseGeocode(lat, lng) ?? "Dhaka, Bangladesh";
        if (baseAddr.length < 5) {
          baseAddr = "Dhaka, Bangladesh";
        }
      }

      body["latitude"] = lat;
      body["longitude"] = lng;
      body["working_radius_km"] = workRadius.value.toInt();
      body["has_smartphone"] = hasSmartphone.value;
      body["base_address"] = baseAddr;
    } else {
      double homeLat = latitude ?? this.latitude.value;
      double homeLng = longitude ?? this.longitude.value;
      String homeAddr = address ?? locationAddress.value.trim();

      if (homeLat == 0.0 || homeLng == 0.0) {
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
                desiredAccuracy: LocationAccuracy.medium,
                timeLimit: const Duration(seconds: 3),
              );
              homeLat = position.latitude;
              homeLng = position.longitude;
            }
          }
        } catch (e) {
          debugPrint("Seeker location fetch error: $e");
        }
      }

      if (homeLat == 0.0 || homeLng == 0.0) {
        homeLat = 23.8103;
        homeLng = 90.4125;
      }

      if (homeAddr.length < 5) {
        homeAddr = await reverseGeocode(homeLat, homeLng) ?? "Dhaka, Bangladesh";
        if (homeAddr.length < 5) {
          homeAddr = "Dhaka, Bangladesh";
        }
      }

      body["home_latitude"] = homeLat;
      body["home_longitude"] = homeLng;
      body["home_address"] = homeAddr;
    }

    final response = await ApiClient.postData(endpoint, body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body != null && response.body['access_token'] != null) {
        await SharePrefsHelper.setString(
          AppConstants.bearerToken,
          "Bearer ${response.body['access_token']}",
        );
        if (response.body['refresh_token'] != null) {
          await SharePrefsHelper.setString(
            AppConstants.refreshToken,
            response.body['refresh_token'],
          );
        }
        await SharePrefsHelper.setString(
          AppConstants.role,
          role.toLowerCase(),
        );
      }
      showCustomSnackBar("Registration successful".tr, isError: false);
      await sendFcmToken();
      if (role.toLowerCase() == 'seeker') {
        Get.offAllNamed(AppRoutes.homeSeekerScreen);
      } else {
        Get.offAllNamed(AppRoutes.loginScreen); // Or provider home
      }
    } else {
      String errorMsg = "Registration failed".tr;
      if (response.body != null && response.body is Map) {
        if (response.body['message'] != null) {
          errorMsg = response.body['message'];
        } else if (response.body['detail'] != null) {
          var detail = response.body['detail'];
          if (detail is String) {
            errorMsg = detail;
          } else if (detail is List && detail.isNotEmpty) {
            if (detail[0] is Map && detail[0]['msg'] != null) {
              errorMsg = detail[0]['msg'];
            } else {
              errorMsg = detail[0].toString();
            }
          } else {
            errorMsg = detail.toString();
          }
        }
      } else if (response.statusText != null) {
        errorMsg = response.statusText!;
      }
      showCustomSnackBar(errorMsg, isError: true);
    }
    isAuthLoading.value = false;
  }

  Future<void> sendFcmToken() async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint("Error fetching FCM token: $e");
    }
    
    // Fallback if token is null for any reason
    String finalToken = fcmToken ?? "dummy_token_fallback";

    String deviceType = "unknown";
    if (Platform.isAndroid) {
      deviceType = "android";
    } else if (Platform.isIOS) {
      deviceType = "ios";
    }

    Map<String, String> body = {"token": finalToken, "device_type": deviceType};
    await ApiClient.postData("${ApiUrl.fcmToken}?token=$finalToken", body);
  }

  Future<void> logout() async {
    isAuthLoading.value = true;

    String refreshToken = await SharePrefsHelper.getString(AppConstants.refreshToken);
    String fcmToken = "";
    try {
      fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      debugPrint("Error fetching FCM token for logout: $e");
    }

    Map<String, dynamic> body = {
      "refresh_token": refreshToken,
    };
    if (fcmToken.isNotEmpty) {
      body["fcm_token"] = fcmToken;
    }

    try {
      if (refreshToken.isNotEmpty) {
        final response = await ApiClient.postData(ApiUrl.signOut, body);
        debugPrint("Logout API response: [${response.statusCode}] ${response.body}");
      }
    } catch (e) {
      debugPrint("Logout API error: $e");
    }

    // Clear local data
    await SharePrefsHelper.remove(AppConstants.bearerToken);
    await SharePrefsHelper.remove(AppConstants.refreshToken);
    await SharePrefsHelper.remove(AppConstants.role);

    // Clear memory token in ApiClient
    ApiClient.bearerToken = "";

    isAuthLoading.value = false;

    // Route to Login screen
    Get.offAllNamed(AppRoutes.loginScreen);
    Future.delayed(const Duration(milliseconds: 250), () {
      showCustomSnackBar("Logged out successfully".tr, isError: false);
    });
  }
}
