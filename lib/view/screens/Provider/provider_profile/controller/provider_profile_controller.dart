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
  var isUpdatingProfilePhoto = false.obs;
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

        if (providerMe.value?.latitude != null && baseLatitude.value == 0.0) {
          baseLatitude.value = providerMe.value!.latitude!;
        }
        if (providerMe.value?.longitude != null && baseLongitude.value == 0.0) {
          baseLongitude.value = providerMe.value!.longitude!;
        }

        if (providerMe.value?.baseAddress?.isNotEmpty == true) {
          baseAddress.value = providerMe.value!.baseAddress!;
        } else if (baseLatitude.value != 0.0 && baseLongitude.value != 0.0) {
          reverseGeocode(baseLatitude.value, baseLongitude.value).then((addr) {
            if (addr != null && addr.isNotEmpty && baseAddress.value.isEmpty) {
              baseAddress.value = addr;
            }
          });
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

  // Pick and immediately upload profile photo to Cloudinary & update backend
  Future<void> pickProfilePhoto(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (file == null) return;

      final selectedFile = File(file.path);
      pickedProfileImage.value = selectedFile;
      isUpdatingProfilePhoto.value = true;
      savingStatusText.value = 'Uploading profile photo...'.tr;

      final photoRes = await uploadProfilePhotoToCloudinary(selectedFile);
      if (photoRes == null || (photoRes['url'] ?? '').isEmpty) {
        showCustomSnackBar("Failed to upload profile photo".tr, isError: true);
        return;
      }

      final String photoUrl = photoRes['url']!;
      final String photoPublicId = photoRes['public_id'] ?? '';

      savingStatusText.value = 'Saving profile photo...'.tr;
      final updateBody = <String, dynamic>{
        'photo_url': photoUrl,
        if (photoPublicId.isNotEmpty) 'photo_public_id': photoPublicId,
      };

      debugPrint("====> Calling PATCH ${ApiUrl.updateProviderProfile} with: $updateBody");
      final response = await ApiClient.patchData(
        ApiUrl.updateProviderProfile,
        updateBody,
      );

      if (response.statusCode == 200) {
        showCustomSnackBar("Profile photo updated successfully".tr, isError: false);
        if (user.value != null) {
          user.value = UserModel(
            userId: user.value!.userId,
            role: user.value!.role,
            phone: user.value!.phone,
            name: user.value!.name,
            isActive: user.value!.isActive,
            createdAt: user.value!.createdAt,
            photoUrl: photoUrl,
            homeAddress: user.value!.homeAddress,
          );
        }
        await getUserProfile();
        if (Get.isRegistered<ProviderHomeController>()) {
          Get.find<ProviderHomeController>().getDashboardData(showLoading: false);
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint("Error picking/updating profile photo: $e");
      showCustomSnackBar("Failed to update profile photo".tr, isError: true);
    } finally {
      isUpdatingProfilePhoto.value = false;
      savingStatusText.value = '';
    }
  }

  // Pick NID Front / Back
  Future<void> pickNidImage({
    required bool isFront,
    required ImageSource source,
  }) async {
    final status = providerMe.value?.verificationStatus.toLowerCase() ??
        'not_initiated';
    final bool canUpdateVerification =
        (status == 'not_initiated' || status == 'rejected');
    if (!canUpdateVerification) {
      showCustomSnackBar(
        status == 'approved'
            ? 'Your NID is already approved and locked.'.tr
            : 'Your NID is under review and cannot be modified.'.tr,
        isError: false,
      );
      return;
    }

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

  /// Reverse geocode coordinates to human-readable address string
  Future<String?> reverseGeocode(double lat, double lng) async {
    final lang = Get.locale?.languageCode ?? 'en';
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
        final response =
            await http.get(uri).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' &&
              data['results'] != null &&
              (data['results'] as List).isNotEmpty) {
            final formatted =
                data['results'][0]['formatted_address']?.toString();
            if (formatted != null && formatted.isNotEmpty) {
              return formatted;
            }
          }
        }
      } catch (e) {
        debugPrint("Google reverse geocode error: $e");
      }
    }

    // Nominatim fallback
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&accept-language=$lang',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'NirbhorApp/1.0',
      }).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name']?.toString();
      }
    } catch (e) {
      debugPrint("Nominatim reverse geocode error: $e");
    }
    return null;
  }

  /// Direct upload profile photo to Cloudinary without backend signature
  Future<Map<String, String>?> uploadProfilePhotoToCloudinary(File file) async {
    try {
      savingStatusText.value = 'Uploading profile photo...'.tr;

      const String cloudName = ApiUrl.cloudinaryCloudName;
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      // Presets to try for direct unsigned upload
      final presetsToTry = [
        ApiUrl.cloudinaryUploadPreset,
        'nirbhor_profile',
        'ml_default',
      ];

      for (final preset in presetsToTry) {
        try {
          debugPrint("====> Trying direct Cloudinary upload with preset: $preset");
          final request = http.MultipartRequest('POST', uri);
          request.fields['upload_preset'] = preset;
          request.files
              .add(await http.MultipartFile.fromPath('file', file.path));

          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);

          debugPrint(
              "====> Cloudinary upload response [$preset] [${response.statusCode}]: ${response.body}");

          if (response.statusCode == 200) {
            final resJson = jsonDecode(response.body);
            final String secureUrl = resJson['secure_url']?.toString() ?? '';
            final String resPublicId = resJson['public_id']?.toString() ?? '';
            debugPrint("====> Direct Cloudinary upload success!");
            debugPrint("====> Photo URL: $secureUrl");
            debugPrint("====> Public ID: $resPublicId");
            return {
              'url': secureUrl,
              'public_id': resPublicId,
            };
          }
        } catch (ex) {
          debugPrint("Error trying preset $preset: $ex");
        }
      }

      return null;
    } catch (e) {
      debugPrint("Error uploading profile photo to Cloudinary: $e");
      return null;
    }
  }

  // Save changes from Edit Provider Profile screen
  Future<bool> saveProfileChanges({
    String? newBaseAddress,
    String? newName,
  }) async {
    isSaving.value = true;
    savingStatusText.value = 'Saving changes...'.tr;

    try {
      final Map<String, dynamic> updateBody = {};

      // 1. Name update
      final cleanName = newName?.trim() ?? '';
      final currentName = providerMe.value?.name ?? user.value?.name ?? '';
      if (cleanName.isNotEmpty && cleanName != currentName) {
        updateBody['name'] = cleanName;
      }

      // 2. Base Address update
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

      // 3. Check verification status gating for photos
      final status = providerMe.value?.verificationStatus.toLowerCase() ??
          'not_initiated';
      final bool canUpdateVerification =
          (status == 'not_initiated' || status == 'rejected');

      // 4. Upload Profile Image if picked (can change anytime)
      if (pickedProfileImage.value != null) {
        final photoRes =
            await uploadProfilePhotoToCloudinary(pickedProfileImage.value!);
        if (photoRes != null) {
          updateBody['photo_url'] = photoRes['url'];
          updateBody['photo_public_id'] = photoRes['public_id'];
        } else {
          showCustomSnackBar("Failed to upload profile photo".tr,
              isError: true);
          return false;
        }
      }

      // 5. Upload Front NID if allowed and picked
      if (canUpdateVerification && pickedFrontNid.value != null) {
        final frontRes = await uploadToCloudinary(
          file: pickedFrontNid.value!,
          side: 'front',
        );
        if (frontRes != null) {
          updateBody['nid_url_front'] = frontRes['url'];
          updateBody['nid_front_public_id'] = frontRes['public_id'];
        } else {
          showCustomSnackBar("Failed to upload front NID image".tr,
              isError: true);
          return false;
        }
      }

      // 6. Upload Back NID if allowed and picked
      if (canUpdateVerification && pickedBackNid.value != null) {
        final backRes = await uploadToCloudinary(
          file: pickedBackNid.value!,
          side: 'back',
        );
        if (backRes != null) {
          updateBody['nid_url_back'] = backRes['url'];
          updateBody['nid_back_public_id'] = backRes['public_id'];
        } else {
          showCustomSnackBar("Failed to upload back NID image".tr,
              isError: true);
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
      debugPrint(
          "====> Calling PATCH ${ApiUrl.updateProviderProfile} with: $updateBody");
      final response = await ApiClient.patchData(
        ApiUrl.updateProviderProfile,
        updateBody,
      );

      if (response.statusCode == 200) {
        showCustomSnackBar("Profile updated successfully".tr, isError: false);
        pickedFrontNid.value = null;
        pickedBackNid.value = null;
        pickedProfileImage.value = null;

        // Immediately update local name/photo/address if changed
        if (user.value != null) {
          user.value = UserModel(
            userId: user.value!.userId,
            role: user.value!.role,
            phone: user.value!.phone,
            name: cleanName.isNotEmpty ? cleanName : user.value!.name,
            isActive: user.value!.isActive,
            createdAt: user.value!.createdAt,
            photoUrl: updateBody['photo_url'] ?? user.value!.photoUrl,
            homeAddress:
                updateBody['base_address'] ?? user.value!.homeAddress,
          );
        }

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
      showCustomSnackBar("Failed to save changes".tr, isError: true);
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
