import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../../../../service/api_check.dart';
import '../../../../../../service/api_client.dart';
import '../../../../../../service/api_url.dart';
import '../../../../../../utils/ToastMsg/toast_message.dart';
import '../../../Seeker/seeker_profile/model/user_model.dart';
import '../../home_provider/controller/provider_home_controller.dart';
import '../../home_provider/model/provider_me_model.dart';

class ProviderProfileController extends GetxController {
  var providerMe = Rxn<ProviderMeModel>();
  var user = Rxn<UserModel>();
  var isLoading = false.obs;
  var isSaving = false.obs;
  var isUpdatingProfile = false.obs;
  var savingStatusText = ''.obs;

  var baseAddress = ''.obs;
  var baseLatitude = 0.0.obs;
  var baseLongitude = 0.0.obs;

  // Selected files for Edit Profile
  var pickedProfileImage = Rxn<File>();
  var pickedFrontNid = Rxn<File>();
  var pickedBackNid = Rxn<File>();

  final ImagePicker _picker = ImagePicker();

  var locationSuggestions = <Map<String, dynamic>>[].obs;
  var isLocationSearching = false.obs;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    getUserProfile();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> getUserProfile() async {
    isLoading.value = true;
    try {
      final response = await ApiClient.getData(ApiUrl.userProfile);
      if (response.statusCode == 200 && response.body is Map<String, dynamic>) {
        final Map<String, dynamic> body =
            Map<String, dynamic>.from(response.body);
        providerMe.value = ProviderMeModel.fromJson(body);

        user.value = UserModel(
          userId: providerMe.value!.userId,
          role: providerMe.value!.role,
          phone: providerMe.value!.phone,
          name: providerMe.value!.name,
          isActive: providerMe.value!.isActive,
          createdAt: providerMe.value!.createdAt ?? '',
          photoUrl: providerMe.value!.photoUrl ?? '',
          homeAddress: providerMe.value!.baseAddress ?? '',
        );

        if (providerMe.value?.baseAddress?.isNotEmpty == true) {
          baseAddress.value = providerMe.value!.baseAddress!;
        }
        if (providerMe.value?.latitude != null && baseLatitude.value == 0.0) {
          baseLatitude.value = providerMe.value!.latitude!;
        }
        if (providerMe.value?.longitude != null && baseLongitude.value == 0.0) {
          baseLongitude.value = providerMe.value!.longitude!;
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint("Error fetching provider user profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Pick profile photo
  Future<void> pickProfilePhoto(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (file != null) {
        pickedProfileImage.value = File(file.path);
      }
    } catch (e) {
      debugPrint("Error picking profile image: $e");
    }
  }

  // Pick NID Front / Back
  Future<void> pickNidImage({
    required bool isFront,
    required ImageSource source,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (file != null) {
        if (isFront) {
          pickedFrontNid.value = File(file.path);
        } else {
          pickedBackNid.value = File(file.path);
        }
      }
    } catch (e) {
      debugPrint("Error picking NID image: $e");
    }
  }

  // Upload single NID side to Cloudinary
  Future<Map<String, String>?> uploadToCloudinary({
    required File file,
    required String side,
  }) async {
    try {
      savingStatusText.value = side == 'front'
          ? 'Getting signature for Front NID...'.tr
          : 'Getting signature for Back NID...'.tr;

      final sigResponse =
          await ApiClient.getData(ApiUrl.nidUploadSignature(side));
      if (sigResponse.statusCode != 200 ||
          sigResponse.body is! Map<String, dynamic>) {
        ApiChecker.checkApi(sigResponse);
        return null;
      }

      final Map<String, dynamic> sigData =
          Map<String, dynamic>.from(sigResponse.body);
      final String cloudName = sigData['cloud_name']?.toString() ?? '';
      final String apiKey = sigData['api_key']?.toString() ?? '';
      final String timestamp = sigData['timestamp']?.toString() ?? '';
      final String signature = sigData['signature']?.toString() ?? '';
      final String folder = sigData['folder']?.toString() ?? '';
      final String publicId = sigData['public_id']?.toString() ?? '';
      final String uploadPreset = sigData['upload_preset']?.toString() ?? '';
      final String type = (sigData['type'] ?? sigData['access_type'])?.toString() ?? '';
      final dynamic overwrite = sigData['overwrite'];

      savingStatusText.value = side == 'front'
          ? 'Uploading Front NID...'.tr
          : 'Uploading Back NID...'.tr;

      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp;
      request.fields['signature'] = signature;
      if (folder.isNotEmpty) request.fields['folder'] = folder;
      if (publicId.isNotEmpty) request.fields['public_id'] = publicId;
      if (uploadPreset.isNotEmpty) request.fields['upload_preset'] = uploadPreset;
      if (type.isNotEmpty) request.fields['type'] = type;
      if (overwrite != null) {
        request.fields['overwrite'] = overwrite.toString();
      }

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final resJson = jsonDecode(response.body);
        return {
          'url': resJson['secure_url']?.toString() ?? '',
          'public_id': resJson['public_id']?.toString() ?? publicId,
        };
      } else {
        debugPrint("Cloudinary upload failed: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error uploading to Cloudinary: $e");
      return null;
    }
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

  // Save changes from Edit Provider Profile screen
  Future<bool> saveProfileChanges({String? newBaseAddress}) async {
    isSaving.value = true;
    savingStatusText.value = 'Saving changes...'.tr;

    try {
      final Map<String, dynamic> updateBody = {};

      // 1. Base Address update
      final cleanAddress = (newBaseAddress ?? baseAddress.value).trim();
      final currentAddress = providerMe.value?.baseAddress ?? '';

      if (cleanAddress.isNotEmpty && cleanAddress != currentAddress) {
        if (cleanAddress.length < 5) {
          showCustomSnackBar("Address must be at least 5 characters".tr,
              isError: true);
          return false;
        }

        double lat = baseLatitude.value;
        double lng = baseLongitude.value;

        if (lat == 0.0 || lng == 0.0) {
          savingStatusText.value = 'Locating address...'.tr;
          final coords = await geocodeAddress(cleanAddress);
          if (coords != null) {
            lat = coords['lat']!;
            lng = coords['lng']!;
            baseLatitude.value = lat;
            baseLongitude.value = lng;
          }
        }

        updateBody['base_address'] = cleanAddress;
        updateBody['latitude'] = (lat != 0.0) ? lat : 23.8103;
        updateBody['longitude'] = (lng != 0.0) ? lng : 90.4125;
      }

      // 2. Check NID verification status gating
      final status = providerMe.value?.verificationStatus.toLowerCase() ??
          'not_initiated';
      final bool canUpdateNid =
          (status == 'not_initiated' || status == 'rejected');

      // 3. Upload Front NID if allowed and picked
      if (canUpdateNid && pickedFrontNid.value != null) {
        final frontRes = await uploadToCloudinary(
          file: pickedFrontNid.value!,
          side: 'front',
        );
        if (frontRes != null) {
          updateBody['nid_url_front'] = frontRes['url'];
          updateBody['nid_front_public_id'] = frontRes['public_id'];
        } else {
          showCustomSnackBar("Failed to upload front NID image".tr);
          return false;
        }
      }

      // 4. Upload Back NID if allowed and picked
      if (canUpdateNid && pickedBackNid.value != null) {
        final backRes = await uploadToCloudinary(
          file: pickedBackNid.value!,
          side: 'back',
        );
        if (backRes != null) {
          updateBody['nid_url_back'] = backRes['url'];
          updateBody['nid_back_public_id'] = backRes['public_id'];
        } else {
          showCustomSnackBar("Failed to upload back NID image".tr);
          return false;
        }
      }

      // If nothing was modified
      if (updateBody.isEmpty) {
        showCustomSnackBar("No new documents or changes to save".tr,
            isError: false);
        return true;
      }

      savingStatusText.value = 'Updating profile...'.tr;
      final response = await ApiClient.patchData(
        ApiUrl.updateProviderProfile,
        updateBody,
      );

      if (response.statusCode == 200) {
        showCustomSnackBar("Profile updated successfully".tr, isError: false);
        pickedFrontNid.value = null;
        pickedBackNid.value = null;
        pickedProfileImage.value = null;
        await getUserProfile();
        if (Get.isRegistered<ProviderHomeController>()) {
          Get.find<ProviderHomeController>()
              .getDashboardData(showLoading: false);
        }
        return true;
      } else {
        ApiChecker.checkApi(response);
        return false;
      }
    } catch (e) {
      debugPrint("Error saving provider profile: $e");
      showCustomSnackBar("Failed to save changes".tr);
      return false;
    } finally {
      isSaving.value = false;
      savingStatusText.value = '';
    }
  }

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

  Future<void> searchLocation(String query) async {
    if (ApiUrl.mapKey.isEmpty) return;
    isLocationSearching.value = true;
    try {
      final lang = Get.locale?.languageCode ?? 'en';
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&components=country:bd'
        '&language=$lang'
        '&key=${ApiUrl.mapKey}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['predictions'] != null) {
          final List predictions = data['predictions'];
          locationSuggestions.value = predictions.map((p) {
            return {
              'name': p['structured_formatting']?['main_text'] ??
                  p['description'] ??
                  '',
              'display_name': p['description'] ?? '',
              'place_id': p['place_id'],
              'secondary_text':
                  p['structured_formatting']?['secondary_text'] ?? '',
            };
          }).toList();
        } else {
          locationSuggestions.clear();
        }
      }
    } catch (e) {
      debugPrint("Error searching location: $e");
    } finally {
      isLocationSearching.value = false;
    }
  }

  Future<String> selectLocationSuggestion(Map<String, dynamic> location) async {
    final String name = location['name']?.toString() ?? '';
    final String displayName = location['display_name']?.toString() ?? '';
    final String chosenAddress = displayName.isNotEmpty ? displayName : name;
    baseAddress.value = chosenAddress;
    locationSuggestions.clear();

    final String? placeId = location['place_id']?.toString();
    if (placeId != null && placeId.isNotEmpty && ApiUrl.mapKey.isNotEmpty) {
      try {
        final lang = Get.locale?.languageCode ?? 'en';
        final detailsUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=geometry,formatted_address'
          '&language=$lang'
          '&key=${ApiUrl.mapKey}',
        );
        final res = await http.get(detailsUrl);
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (data['status'] == 'OK' && data['result'] != null) {
            final loc = data['result']['geometry']?['location'];
            if (loc != null) {
              baseLatitude.value = (loc['lat'] as num).toDouble();
              baseLongitude.value = (loc['lng'] as num).toDouble();
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching place details: $e");
      }
    }
    return chosenAddress;
  }

  void setLocationFromPicker({
    required String address,
    required double latitude,
    required double longitude,
  }) {
    baseAddress.value = address;
    baseLatitude.value = latitude;
    baseLongitude.value = longitude;
    locationSuggestions.clear();
  }

  Future<bool> updateProviderProfile({
    required String name,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    isUpdatingProfile.value = true;
    try {
      final Map<String, dynamic> body = {
        "base_address": address,
      };

      if (latitude != null &&
          longitude != null &&
          latitude != 0.0 &&
          longitude != 0.0) {
        body["latitude"] = latitude;
        body["longitude"] = longitude;
      }

      final response = await ApiClient.patchData(
        ApiUrl.updateProviderProfile,
        body,
      );

      if (response.statusCode == 200) {
        await getUserProfile();
        return true;
      } else {
        ApiChecker.checkApi(response);
        return false;
      }
    } catch (e) {
      debugPrint("Error updating provider profile: $e");
      showCustomSnackBar("Something went wrong".tr);
      return false;
    } finally {
      isUpdatingProfile.value = false;
    }
  }
}
