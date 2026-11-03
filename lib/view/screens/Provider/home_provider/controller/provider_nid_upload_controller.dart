import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../../service/api_check.dart';
import '../../../../../../service/api_client.dart';
import '../../../../../../service/api_url.dart';
import '../../../../../../utils/ToastMsg/toast_message.dart';
import '../../../../../../core/app_routes/app_routes.dart';
import '../../../../../../utils/app_colors/app_colors.dart';
import 'provider_home_controller.dart';

class ProviderNidUploadController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  var frontImage = Rxn<File>();
  var backImage = Rxn<File>();

  var isFrontUploading = false.obs;
  var isBackUploading = false.obs;
  var isFrontUploaded = false.obs;
  var isBackUploaded = false.obs;

  var frontSecureUrl = ''.obs;
  var frontPublicId = ''.obs;
  var backSecureUrl = ''.obs;
  var backPublicId = ''.obs;

  var frontUploadError = ''.obs;
  var backUploadError = ''.obs;

  var isSubmitting = false.obs;
  var uploadProgressText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExistingNid();
  }

  void _loadExistingNid() {
    if (Get.isRegistered<ProviderHomeController>()) {
      final homeCtrl = Get.find<ProviderHomeController>();
      final me = homeCtrl.userMeData.value;
      if (me != null) {
        if (me.nidUrlFront != null && me.nidUrlFront!.isNotEmpty) {
          frontSecureUrl.value = me.nidUrlFront!;
          frontPublicId.value = '';
          isFrontUploaded.value = true;
        }
        if (me.nidUrlBack != null && me.nidUrlBack!.isNotEmpty) {
          backSecureUrl.value = me.nidUrlBack!;
          backPublicId.value = '';
          isBackUploaded.value = true;
        }
      }
    }
  }

  /// Clear selected image and reset state so user can re-pick easily
  void clearImage(bool isFront) {
    if (isFront) {
      frontImage.value = null;
      frontSecureUrl.value = '';
      frontPublicId.value = '';
      isFrontUploaded.value = false;
      frontUploadError.value = '';
    } else {
      backImage.value = null;
      backSecureUrl.value = '';
      backPublicId.value = '';
      isBackUploaded.value = false;
      backUploadError.value = '';
    }
  }

  /// Show bottom sheet with Camera & Gallery options
  void showImagePickerOptions({
    required BuildContext context,
    required bool isFront,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isFront ? 'NID Front Side'.tr : 'NID Back Side'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: Text(
                  'Take with Camera'.tr,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  pickNidImage(isFront: isFront, source: ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: Text(
                  'Choose from Gallery'.tr,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  pickNidImage(isFront: isFront, source: ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick image and immediately initiate Cloudinary direct upload
  Future<void> pickNidImage({
    required bool isFront,
    required ImageSource source,
  }) async {
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          showCustomSnackBar("Camera permission is required to capture NID photo".tr);
          if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
          return;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (isFront) {
          frontImage.value = file;
          frontUploadError.value = '';
          await uploadToCloudinary(file: file, side: 'front');
        } else {
          backImage.value = file;
          backUploadError.value = '';
          await uploadToCloudinary(file: file, side: 'back');
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      showCustomSnackBar("Failed to pick image".tr);
    }
  }

  /// Upload single NID side directly to Cloudinary using signed signature endpoint
  Future<Map<String, String>?> uploadToCloudinary({
    required File file,
    required String side,
  }) async {
    try {
      if (side == 'front') {
        isFrontUploading.value = true;
        isFrontUploaded.value = false;
        frontUploadError.value = '';
      } else {
        isBackUploading.value = true;
        isBackUploaded.value = false;
        backUploadError.value = '';
      }

      uploadProgressText.value = side == 'front'
          ? 'Getting signature for Front NID...'.tr
          : 'Getting signature for Back NID...'.tr;

      // 1. Fetch short-lived signature from backend
      // GET /api/v1/uploads/upload-signature/nid?side=front (or back)
      final sigResponse = await ApiClient.getData(ApiUrl.nidUploadSignature(side));

      if (sigResponse.statusCode != 200 || sigResponse.body is! Map<String, dynamic>) {
        final errMsg = "Failed to get upload signature".tr;
        if (side == 'front') {
          frontUploadError.value = errMsg;
        } else {
          backUploadError.value = errMsg;
        }
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
      final String type = (sigData['type'] ?? sigData['access_type'])?.toString() ?? '';

      uploadProgressText.value = side == 'front'
          ? 'Uploading Front NID...'.tr
          : 'Uploading Back NID...'.tr;

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      // Attempt 1: Signed upload matching Cloudinary expected parameters
      final request = http.MultipartRequest('POST', uri);
      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp;
      request.fields['signature'] = signature;
      if (folder.isNotEmpty) request.fields['folder'] = folder;
      if (publicId.isNotEmpty) request.fields['public_id'] = publicId;
      if (uploadPreset.isNotEmpty) request.fields['upload_preset'] = uploadPreset;
      if (type.isNotEmpty) request.fields['type'] = type;
      request.fields['overwrite'] = 'true';

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Attempt 2: If 401 Invalid Signature, try unsigned preset upload fallback
      if (response.statusCode == 401 && uploadPreset.isNotEmpty) {
        debugPrint("Signed upload 401. Trying unsigned preset fallback for $side...");
        try {
          final unsignedReq = http.MultipartRequest('POST', uri);
          unsignedReq.fields['upload_preset'] = uploadPreset;
          if (folder.isNotEmpty) unsignedReq.fields['folder'] = folder;
          if (publicId.isNotEmpty) unsignedReq.fields['public_id'] = publicId;
          unsignedReq.fields['overwrite'] = 'true';
          unsignedReq.files.add(await http.MultipartFile.fromPath('file', file.path));

          final unsignedStreamed = await unsignedReq.send();
          final unsignedResp = await http.Response.fromStream(unsignedStreamed);
          if (unsignedResp.statusCode == 200) {
            response = unsignedResp;
          } else {
            debugPrint("Unsigned fallback response [${unsignedResp.statusCode}]: ${unsignedResp.body}");
          }
        } catch (ex) {
          debugPrint("Unsigned fallback exception: $ex");
        }
      }

      if (response.statusCode == 200) {
        final resJson = jsonDecode(response.body);
        final String secureUrl = resJson['secure_url']?.toString() ?? '';
        final String resPublicId = resJson['public_id']?.toString() ?? publicId;

        debugPrint("====> Cloudinary Upload Success [$side]!");
        debugPrint("====> Cloudinary Image URL: $secureUrl");
        debugPrint("====> Cloudinary Public ID: $resPublicId");

        if (side == 'front') {
          frontSecureUrl.value = secureUrl;
          frontPublicId.value = resPublicId;
          isFrontUploaded.value = true;
          frontUploadError.value = '';
        } else {
          backSecureUrl.value = secureUrl;
          backPublicId.value = resPublicId;
          isBackUploaded.value = true;
          backUploadError.value = '';
        }

        return {
          'secure_url': secureUrl,
          'public_id': resPublicId,
        };
      } else {
        debugPrint("Cloudinary upload failed [${response.statusCode}]: ${response.body}");
        final errMsg = "Failed to upload image to server".tr;
        if (side == 'front') {
          frontUploadError.value = errMsg;
        } else {
          backUploadError.value = errMsg;
        }
        showCustomSnackBar(errMsg);
        return null;
      }
    } catch (e) {
      debugPrint("Error uploading to Cloudinary: $e");
      final errMsg = "Upload error: $e";
      if (side == 'front') {
        frontUploadError.value = errMsg;
      } else {
        backUploadError.value = errMsg;
      }
      showCustomSnackBar(errMsg);
      return null;
    } finally {
      if (side == 'front') {
        isFrontUploading.value = false;
      } else {
        isBackUploading.value = false;
      }
      uploadProgressText.value = '';
    }
  }

  /// Submit NID documents to PATCH /api/v1/provider/me/update_profile
  Future<void> submitNid() async {
    // 1. Verify that front image is ready
    if (frontImage.value == null && frontSecureUrl.value.isEmpty) {
      showCustomSnackBar("Please select both Front and Back NID images".tr);
      return;
    }

    // 2. Verify that back image is ready
    if (backImage.value == null && backSecureUrl.value.isEmpty) {
      showCustomSnackBar("Please select both Front and Back NID images".tr);
      return;
    }

    isSubmitting.value = true;
    try {
      // Upload front if not uploaded yet
      if (!isFrontUploaded.value || frontSecureUrl.value.isEmpty) {
        if (frontImage.value != null) {
          final frontRes = await uploadToCloudinary(file: frontImage.value!, side: 'front');
          if (frontRes == null) {
            showCustomSnackBar("Failed to upload Front NID".tr);
            return;
          }
        }
      }

      // Upload back if not uploaded yet
      if (!isBackUploaded.value || backSecureUrl.value.isEmpty) {
        if (backImage.value != null) {
          final backRes = await uploadToCloudinary(file: backImage.value!, side: 'back');
          if (backRes == null) {
            showCustomSnackBar("Failed to upload Back NID".tr);
            return;
          }
        }
      }

      // 3. Send secure_url + public_id to PATCH /provider/me/update_profile
      uploadProgressText.value = 'Submitting for verification...'.tr;
      final updateBody = {
        "nid_url_front": frontSecureUrl.value,
        "nid_front_public_id": frontPublicId.value,
        "nid_url_back": backSecureUrl.value,
        "nid_back_public_id": backPublicId.value,
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

        // Refresh provider dashboard and profile data
        if (Get.isRegistered<ProviderHomeController>()) {
          Get.find<ProviderHomeController>().getDashboardData(showLoading: false);
        }

        // Return to home screen
        Get.until((route) => route.isFirst || route.settings.name == AppRoutes.providerHomeScreen);
      } else {
        ApiChecker.checkApi(patchResponse);
      }
    } catch (e) {
      debugPrint("Error submitting NID: $e");
      showCustomSnackBar("Something went wrong".tr);
    } finally {
      isSubmitting.value = false;
      uploadProgressText.value = '';
    }
  }
}
