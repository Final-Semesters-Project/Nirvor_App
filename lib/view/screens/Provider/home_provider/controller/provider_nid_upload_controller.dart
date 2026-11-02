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
import 'provider_home_controller.dart';

class ProviderNidUploadController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  var frontImage = Rxn<File>();
  var backImage = Rxn<File>();

  var isUploading = false.obs;
  var uploadProgressText = ''.obs;

  /// Pick image from camera or gallery
  Future<void> pickNidImage({
    required bool isFront,
    required ImageSource source,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        if (isFront) {
          frontImage.value = File(pickedFile.path);
        } else {
          backImage.value = File(pickedFile.path);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      showCustomSnackBar("Failed to pick image".tr);
    }
  }

  /// Upload a single image directly to Cloudinary using signed upload parameters
  Future<Map<String, String>?> _uploadToCloudinary({
    required File file,
    required String side,
  }) async {
    try {
      uploadProgressText.value =
          side == 'front' ? 'Getting signature for Front NID...'.tr : 'Getting signature for Back NID...'.tr;

      // 1. Fetch short-lived signature from backend
      final sigResponse = await ApiClient.getData(ApiUrl.nidUploadSignature(side));

      if (sigResponse.statusCode != 200 || sigResponse.body is! Map<String, dynamic>) {
        ApiChecker.checkApi(sigResponse);
        return null;
      }

      final Map<String, dynamic> sigData = Map<String, dynamic>.from(sigResponse.body);
      final String cloudName = sigData['cloud_name']?.toString() ?? '';
      final String apiKey = sigData['api_key']?.toString() ?? '';
      final String timestamp = sigData['timestamp']?.toString() ?? '';
      final String signature = sigData['signature']?.toString() ?? '';
      final String folder = sigData['folder']?.toString() ?? '';
      final String publicId = sigData['public_id']?.toString() ?? '';
      final String uploadPreset = sigData['upload_preset']?.toString() ?? '';
      final String accessType = sigData['access_type']?.toString() ?? '';

      uploadProgressText.value =
          side == 'front' ? 'Uploading Front NID...'.tr : 'Uploading Back NID...'.tr;

      // 2. Direct upload to Cloudinary API
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp;
      request.fields['signature'] = signature;
      if (folder.isNotEmpty) request.fields['folder'] = folder;
      if (publicId.isNotEmpty) request.fields['public_id'] = publicId;
      if (uploadPreset.isNotEmpty) request.fields['upload_preset'] = uploadPreset;
      if (accessType.isNotEmpty) request.fields['access_type'] = accessType;

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final resJson = jsonDecode(response.body);
        final String secureUrl = resJson['secure_url']?.toString() ?? '';
        final String resPublicId = resJson['public_id']?.toString() ?? publicId;

        return {
          'secure_url': secureUrl,
          'public_id': resPublicId,
        };
      } else {
        debugPrint("Cloudinary upload failed [${response.statusCode}]: ${response.body}");
        showCustomSnackBar("Failed to upload image to server".tr);
        return null;
      }
    } catch (e) {
      debugPrint("Error uploading to Cloudinary: $e");
      showCustomSnackBar("Upload error: $e");
      return null;
    }
  }

  /// Submit NID documents
  Future<void> submitNid() async {
    if (frontImage.value == null || backImage.value == null) {
      showCustomSnackBar("Please select both Front and Back NID images".tr);
      return;
    }

    isUploading.value = true;
    try {
      // 1. Upload Front NID
      final frontResult = await _uploadToCloudinary(
        file: frontImage.value!,
        side: 'front',
      );
      if (frontResult == null) {
        return;
      }

      // 2. Upload Back NID
      final backResult = await _uploadToCloudinary(
        file: backImage.value!,
        side: 'back',
      );
      if (backResult == null) {
        return;
      }

      // 3. Update provider profile with NID URLs and Public IDs
      uploadProgressText.value = 'Submitting for verification...'.tr;
      final updateBody = {
        "nid_url_front": frontResult['secure_url'],
        "nid_front_public_id": frontResult['public_id'],
        "nid_url_back": backResult['secure_url'],
        "nid_back_public_id": backResult['public_id'],
      };

      final patchResponse = await ApiClient.patchData(
        ApiUrl.updateProviderProfile,
        updateBody,
      );

      if (patchResponse.statusCode == 200) {
        showCustomSnackBar(
          "NID submitted successfully. Verification pending approval.".tr,
          isError: false,
        );

        // Refresh provider dashboard and profile
        if (Get.isRegistered<ProviderHomeController>()) {
          Get.find<ProviderHomeController>().getDashboardData(showLoading: false);
        }

        Get.back();
      } else {
        ApiChecker.checkApi(patchResponse);
      }
    } catch (e) {
      debugPrint("Error submitting NID: $e");
      showCustomSnackBar("Something went wrong".tr);
    } finally {
      isUploading.value = false;
      uploadProgressText.value = '';
    }
  }
}

