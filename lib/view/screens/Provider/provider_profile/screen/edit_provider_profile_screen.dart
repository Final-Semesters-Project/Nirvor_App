import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../utils/app_colors/app_colors.dart';
import '../../../../../../utils/app_const/app_const.dart';
import '../../../../../../utils/ToastMsg/toast_message.dart';
import '../../../../components/custom_netwrok_image/custom_network_image.dart';
import '../../../auth_screen/setup_details/map_location_picker_screen.dart';
import '../controller/provider_profile_controller.dart';

class EditProviderProfileScreen extends StatefulWidget {
  const EditProviderProfileScreen({super.key});

  @override
  State<EditProviderProfileScreen> createState() =>
      _EditProviderProfileScreenState();
}

class _EditProviderProfileScreenState extends State<EditProviderProfileScreen> {
  final ProviderProfileController controller =
      Get.find<ProviderProfileController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    final me = controller.providerMe.value;
    if (me != null) {
      nameController.text = me.name;
      if (me.baseAddress != null && me.baseAddress!.isNotEmpty) {
        addressController.text = me.baseAddress!;
      }
    } else if (controller.user.value != null) {
      nameController.text = controller.user.value!.name;
      if (controller.user.value!.homeAddress.isNotEmpty) {
        addressController.text = controller.user.value!.homeAddress;
      }
    }

    if (addressController.text.isEmpty &&
        controller.baseAddress.value.isNotEmpty) {
      addressController.text = controller.baseAddress.value;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _showImagePickerSheet(
      {required Function(ImageSource) onSourceSelected}) {
    final bool isBn = Get.locale?.languageCode == 'bn';
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBn ? 'ছবি নির্বাচন করুন' : 'Select Photo Source',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary),
                ),
                title: Text(
                  isBn ? 'ক্যামেরা দিয়ে ছবি তুলুন' : 'Take photo with camera',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Get.back();
                  onSourceSelected(ImageSource.camera);
                },
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: Color(0xFF0284C7)),
                ),
                title: Text(
                  isBn ? 'গ্যালারি থেকে পছন্দ করুন' : 'Choose from gallery',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Get.back();
                  onSourceSelected(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = Get.locale?.languageCode == 'bn';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: Color(0xFF0F172A)),
        titleSpacing: 0,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isBn ? 'প্রোফাইল এডিট করুন' : 'Edit Profile',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    isBn
                        ? 'আপনার ব্যক্তিগত ও সেবার তথ্য আপডেট করুন'
                        : 'Update your personal & service information',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          children: [
            // 1. Profile Photo Squircle Slot
            Center(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Obx(() {
                        final picked = controller.pickedProfileImage.value;
                        final isUpdatingPhoto =
                            controller.isUpdatingProfilePhoto.value;
                        final remotePhoto =
                            controller.providerMe.value?.photoUrl ??
                                controller.user.value?.photoUrl ??
                                '';

                        return InkWell(
                          onTap: isUpdatingPhoto
                              ? null
                              : () {
                                  _showImagePickerSheet(
                                    onSourceSelected: (source) =>
                                        controller.pickProfilePhoto(source),
                                  );
                                },
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            width: 106,
                            height: 106,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(21),
                                  child: picked != null
                                      ? Image.file(
                                          picked,
                                          fit: BoxFit.cover,
                                          width: 106,
                                          height: 106,
                                        )
                                      : CustomNetworkImage(
                                          imageUrl: remotePhoto.isNotEmpty
                                              ? remotePhoto
                                              : AppConstants.profileImage,
                                          width: 106,
                                          height: 106,
                                        ),
                                ),
                                if (isUpdatingPhoto)
                                  Container(
                                    width: 106,
                                    height: 106,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(21),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      // Circular camera/edit button at bottom-right (always available for provider)
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Obx(() {
                          final isUpdatingPhoto =
                              controller.isUpdatingProfilePhoto.value;
                          return GestureDetector(
                            onTap: isUpdatingPhoto
                                ? null
                                : () {
                                    _showImagePickerSheet(
                                      onSourceSelected: (source) =>
                                          controller.pickProfilePhoto(source),
                                    );
                                  },
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isBn ? 'প্রোফাইল ছবি' : 'Profile Photo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Personal Information Card (Name fields)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'ব্যক্তিগত তথ্য' : 'Personal Information',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Full Name Field (dynamically localized)
                  Text(
                    isBn ? 'সম্পূর্ণ নাম (বাংলা)' : 'Full Name (English)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: isBn
                          ? 'বাংলায় সম্পূর্ণ নাম লিখুন'
                          : 'Enter full name in English',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF0F766E),
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color(0xFF0F766E),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. Work Address (Base Address) Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF0F766E).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBn ? 'কাজের ঠিকানা (বেস অ্যাড্রেস)' : 'Work Address (Base Address)',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isBn
                        ? 'এই ঠিকানার ওপর ভিত্তি করে নিকটবর্তী কাজের অফার পাঠানো হবে'
                        : 'Nearby job requests are sent based on this base address',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Base Address Input with Map Button & Autocomplete
                  TextField(
                    controller: addressController,
                    onChanged: (val) {
                      controller.baseAddress.value = val;
                      controller.onLocationQueryChanged(val);
                    },
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: isBn ? 'বেস অ্যাড্রেস' : 'Base Address',
                      labelStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      hintText: isBn
                          ? 'যেমন: মিরপুর ১০, ঢাকা'
                          : 'e.g. Mirpur 10, Dhaka',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF0F766E),
                        size: 20,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (addressController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  size: 18, color: Colors.grey),
                              onPressed: () {
                                addressController.clear();
                                controller.baseAddress.value = '';
                                controller.locationSuggestions.clear();
                                setState(() {});
                              },
                            ),
                          // Map Picker Icon Button
                          IconButton(
                            icon: const Icon(Icons.map_rounded,
                                color: Color(0xFF0F766E), size: 22),
                            tooltip: isBn ? 'ম্যাপ থেকে পছন্দ করুন' : 'Pick from map',
                            onPressed: () async {
                              final result = await Get.to(() => MapLocationPickerScreen(
                                initialLatitude: controller.baseLatitude.value != 0.0
                                    ? controller.baseLatitude.value
                                    : null,
                                initialLongitude: controller.baseLongitude.value != 0.0
                                    ? controller.baseLongitude.value
                                    : null,
                                initialAddress: addressController.text.trim().isNotEmpty
                                    ? addressController.text.trim()
                                    : null,
                              ));

                              if (result != null && result is Map<String, dynamic>) {
                                final String addr = result['address'] ?? '';
                                final double lat = result['latitude'] ?? 0.0;
                                final double lng = result['longitude'] ?? 0.0;
                                addressController.text = addr;
                                controller.setLocationFromPicker(
                                  address: addr,
                                  latitude: lat,
                                  longitude: lng,
                                );
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color(0xFF0F766E),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // Location search suggestions dropdown
                  Obx(() {
                    if (controller.isLocationSearching.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    }
                    if (controller.locationSuggestions.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: controller.locationSuggestions.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final item = controller.locationSuggestions[index];
                          final name = item['name'] ?? '';
                          final secondary = item['secondary_text'] ?? '';

                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.place_outlined,
                                size: 18, color: Color(0xFF0F766E)),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: secondary.isNotEmpty
                                ? Text(
                                    secondary,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  )
                                : null,
                            onTap: () async {
                              final chosen = await controller
                                  .selectLocationSuggestion(item);
                              addressController.text = chosen;
                              setState(() {});
                              if (context.mounted) {
                                FocusScope.of(context).unfocus();
                              }
                            },
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 4. NID Verification Card (Gated strictly by verification_status)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF0F766E).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.badge_outlined,
                          size: 18,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBn ? 'এনআইডি যাচাইকরণ' : 'NID Verification',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      // Status Pill
                      Obx(() {
                        final status = controller.providerMe.value
                                ?.verificationStatus
                                .toLowerCase() ??
                            'not_initiated';

                        Color badgeColor;
                        String badgeLabel;

                        if (status == 'approved') {
                          badgeColor = Colors.green.shade700;
                          badgeLabel = isBn ? 'অনুমোদিত' : 'Approved';
                        } else if (status == 'pending') {
                          badgeColor = Colors.amber.shade800;
                          badgeLabel = isBn ? 'পর্যালোচনাধীন' : 'Pending';
                        } else if (status == 'rejected') {
                          badgeColor = Colors.red.shade700;
                          badgeLabel = isBn ? 'প্রত্যাখ্যাত' : 'Rejected';
                        } else {
                          badgeColor = Colors.grey.shade600;
                          badgeLabel = isBn ? 'অযাচাইকৃত' : 'Not Uploaded';
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            badgeLabel,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // NID Front Box
                  Obx(() {
                    final status = controller.providerMe.value
                            ?.verificationStatus
                            .toLowerCase() ??
                        'not_initiated';
                    final bool canUpdateNid =
                        (status == 'not_initiated' || status == 'rejected');
                    final picked = controller.pickedFrontNid.value;
                    final remoteUrl =
                        controller.providerMe.value?.nidUrlFront ?? '';

                    return _buildNidSlot(
                      title: isBn ? 'এনআইডি সামনের দিক' : 'NID Front Side',
                      subtext: canUpdateNid
                          ? (isBn
                              ? 'ক্যামেরা দিয়ে ছবি তুলুন'
                              : 'Take photo with camera')
                          : (status == 'approved'
                              ? (isBn ? 'যাচাইকৃত (লক করা)' : 'Verified (Locked)')
                              : (isBn
                                  ? 'পর্যালোচনাধীন (লক করা)'
                                  : 'Under Review (Locked)')),
                      pickedFile: picked,
                      remoteUrl: remoteUrl,
                      canUpdate: canUpdateNid,
                      status: status,
                      isBn: isBn,
                      onTap: () {
                        if (!canUpdateNid) {
                          showCustomSnackBar(
                            status == 'approved'
                                ? (isBn
                                    ? 'আপনার এনআইডি ইতিমধ্যে অনুমোদিত এবং লক করা।'
                                    : 'Your NID is already approved and locked.')
                                : (isBn
                                    ? 'আপনার এনআইডি পর্যালোচনাধীন রয়েছে, পরিবর্তন করা যাবে না।'
                                    : 'Your NID is under review and cannot be modified.'),
                            isError: false,
                          );
                          return;
                        }
                        controller.pickNidImage(
                          isFront: true,
                          source: ImageSource.camera,
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 14),

                  // NID Back Box
                  Obx(() {
                    final status = controller.providerMe.value
                            ?.verificationStatus
                            .toLowerCase() ??
                        'not_initiated';
                    final bool canUpdateNid =
                        (status == 'not_initiated' || status == 'rejected');
                    final picked = controller.pickedBackNid.value;
                    final remoteUrl =
                        controller.providerMe.value?.nidUrlBack ?? '';

                    return _buildNidSlot(
                      title: isBn ? 'এনআইডি পিছনের দিক' : 'NID Back Side',
                      subtext: canUpdateNid
                          ? (isBn
                              ? 'ক্যামেরা দিয়ে ছবি তুলুন'
                              : 'Take photo with camera')
                          : (status == 'approved'
                              ? (isBn ? 'যাচাইকৃত (লক করা)' : 'Verified (Locked)')
                              : (isBn
                                  ? 'পর্যালোচনাধীন (লক করা)'
                                  : 'Under Review (Locked)')),
                      pickedFile: picked,
                      remoteUrl: remoteUrl,
                      canUpdate: canUpdateNid,
                      status: status,
                      isBn: isBn,
                      onTap: () {
                        if (!canUpdateNid) {
                          showCustomSnackBar(
                            status == 'approved'
                                ? (isBn
                                    ? 'আপনার এনআইডি ইতিমধ্যে অনুমোদিত এবং লক করা।'
                                    : 'Your NID is already approved and locked.')
                                : (isBn
                                    ? 'আপনার এনআইডি পর্যালোচনাধীন রয়েছে, পরিবর্তন করা যাবে না।'
                                    : 'Your NID is under review and cannot be modified.'),
                            isError: false,
                          );
                          return;
                        }
                        controller.pickNidImage(
                          isFront: false,
                          source: ImageSource.camera,
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 14),

                  // Encryption Info Note
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            isBn
                                ? 'আপনার এনআইডি তথ্য এনক্রিপ্টেড এবং শুধুমাত্র বিশ্বস্ততা যাচাইয়ের জন্য ব্যবহৃত হয়।'
                                : 'Your NID data is encrypted and only used for identity and community trust verification.',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey.shade600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 5. Save Changes Button
            Obx(() {
              final isSaving = controller.isSaving.value;
              final statusText = controller.savingStatusText.value;

              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          final success = await controller.saveProfileChanges(
                            newBaseAddress: addressController.text.trim(),
                            newName: nameController.text.trim(),
                          );
                          if (success && mounted) {
                            navigator.pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF0F766E).withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              statusText.isNotEmpty
                                  ? statusText
                                  : (isBn
                                      ? 'সংরক্ষণ করা হচ্ছে...'
                                      : 'Saving changes...'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save_outlined,
                                size: 20, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              isBn
                                  ? 'পরিবর্তন সংরক্ষণ করুন'
                                  : 'Save Changes',
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNidSlot({
    required String title,
    required String subtext,
    File? pickedFile,
    required String remoteUrl,
    required bool canUpdate,
    required String status,
    required bool isBn,
    required VoidCallback onTap,
  }) {
    final bool hasImage = pickedFile != null || remoteUrl.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: hasImage
              ? const Color(0xFF0F766E).withValues(alpha: 0.03)
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage
                ? const Color(0xFF0F766E)
                : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
        ),
        child: hasImage
            ? Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: pickedFile != null
                        ? Image.file(
                            pickedFile,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 120,
                          )
                        : CustomNetworkImage(
                            imageUrl: remoteUrl,
                            width: double.infinity,
                            height: 120,
                          ),
                  ),
                  // If update is NOT allowed, show lock badge and NO camera icon
                  if (!canUpdate)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'approved'
                              ? Colors.green.shade800.withValues(alpha: 0.9)
                              : Colors.amber.shade900.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_rounded,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              status == 'approved'
                                  ? (isBn ? 'যাচাইকৃত' : 'Verified')
                                  : (isBn ? 'পর্যালোচনাধীন' : 'Under Review'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // If update is allowed, show camera/retake pill
                  if (canUpdate)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              isBn ? 'পুনরায় তুলুন' : 'Retake',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: canUpdate
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      canUpdate ? Icons.camera_alt_outlined : Icons.lock_outline_rounded,
                      color: canUpdate ? AppColors.primary : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: canUpdate
                          ? const Color(0xFF1E293B)
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtext,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
