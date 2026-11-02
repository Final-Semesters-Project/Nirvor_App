import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nirbhor/utils/app_colors/app_colors.dart';
import 'package:nirbhor/utils/ToastMsg/toast_message.dart';
import 'package:nirbhor/view/components/custom_text/custom_text.dart';
import 'package:nirbhor/view/components/custom_text_field/custom_text_field.dart';
import 'package:nirbhor/view/screens/auth_screen/setup_details/map_location_picker_screen.dart';
import '../controller/seeker_profile_controller.dart';

class EditSeekerProfileScreen extends StatefulWidget {
  const EditSeekerProfileScreen({super.key});

  @override
  State<EditSeekerProfileScreen> createState() => _EditSeekerProfileScreenState();
}

class _EditSeekerProfileScreenState extends State<EditSeekerProfileScreen> {
  final SeekerProfileController controller = Get.find<SeekerProfileController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (controller.user.value != null) {
      nameController.text = controller.user.value!.name;
    }

    if (controller.homeAddress.value.isNotEmpty) {
      addressController.text = controller.homeAddress.value;
    } else if (controller.user.value != null && controller.user.value!.homeAddress.isNotEmpty) {
      addressController.text = controller.user.value!.homeAddress;
      controller.homeAddress.value = controller.user.value!.homeAddress;
      if (controller.user.value!.homeLatitude != null) {
        controller.homeLatitude.value = controller.user.value!.homeLatitude!;
      }
      if (controller.user.value!.homeLongitude != null) {
        controller.homeLongitude.value = controller.user.value!.homeLongitude!;
      }
    }

    // Refresh address from backend GET /api/v1/seeker/me/address
    controller.fetchSeekerAddress().then((_) {
      if (mounted && addressController.text.isEmpty && controller.homeAddress.value.isNotEmpty) {
        setState(() {
          addressController.text = controller.homeAddress.value;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CustomText(
          text: 'Edit Profile'.tr,
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Photo Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Obx(() {
                  final user = controller.user.value;
                  return CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: (user != null && user.photoUrl.isNotEmpty)
                        ? NetworkImage(user.photoUrl)
                        : null,
                    child: (user == null || user.photoUrl.isEmpty)
                        ? const Icon(Icons.person, size: 54, color: Colors.grey)
                        : null,
                  );
                }),
                GestureDetector(
                  onTap: () {
                    showCustomSnackBar("Update Profile Picture not available yet.".tr, isError: false);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomText(
              text: "Tap the camera to change photo separately".tr,
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 32),

            // 2. Basic Information Section
            Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                text: "Basic Information".tr,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),

            // 3. Full Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name'.tr,
                labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Home Address Section Title
            Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                text: "Home Address".tr,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // 5. Address Search Field with Autocomplete & Map Pin
            CustomTextField(
              textEditingController: addressController,
              hintText: 'Search address or select from map...'.tr,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              fillColor: Colors.white,
              fieldBorderColor: Colors.grey.shade300,
              fieldBorderRadius: 12,
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    if (controller.homeAddress.value.isNotEmpty ||
                        addressController.text.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                        onPressed: () {
                          addressController.clear();
                          controller.homeAddress.value = '';
                          controller.locationSuggestions.clear();
                          controller.homeLatitude.value = 0.0;
                          controller.homeLongitude.value = 0.0;
                          setState(() {});
                        },
                      );
                    }
                    return const SizedBox();
                  }),
                  GestureDetector(
                    onTap: () async {
                      final result = await Get.to(() => MapLocationPickerScreen(
                        initialLatitude: controller.homeLatitude.value != 0.0
                            ? controller.homeLatitude.value
                            : null,
                        initialLongitude: controller.homeLongitude.value != 0.0
                            ? controller.homeLongitude.value
                            : null,
                        initialAddress: addressController.text.trim().isNotEmpty
                            ? addressController.text.trim()
                            : null,
                      ));
                      if (result != null && result is Map<String, dynamic>) {
                        final lat = double.tryParse(result['latitude']?.toString() ?? '0') ?? 0.0;
                        final lng = double.tryParse(result['longitude']?.toString() ?? '0') ?? 0.0;
                        final addr = result['address']?.toString() ?? '';
                        if (addr.isNotEmpty) {
                          addressController.text = addr;
                          controller.setLocationFromPicker(
                            address: addr,
                            latitude: lat,
                            longitude: lng,
                          );
                          setState(() {});
                        }
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              onChanged: (val) {
                setState(() {});
                controller.onLocationQueryChanged(val);
              },
            ),

            // 6. Location Autocomplete Suggestions Dropdown
            Obx(() {
              if (controller.isLocationSearching.value) {
                return const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                );
              }
              if (controller.locationSuggestions.isEmpty) {
                return const SizedBox();
              }
              return Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: controller.locationSuggestions.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, thickness: 0.5),
                      itemBuilder: (context, index) {
                        final suggestion = controller.locationSuggestions[index];
                        final String name = suggestion['name']?.toString() ?? '';
                        final String displayName = suggestion['display_name']?.toString() ?? '';
                        final String secondaryText = suggestion['secondary_text']?.toString() ?? '';
                        final String sub = secondaryText.isNotEmpty
                            ? secondaryText
                            : (displayName != name ? displayName : '');
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            name.isNotEmpty ? name : displayName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: sub.isNotEmpty
                              ? Text(
                                  sub,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () async {
                            final chosen = await controller.selectLocationSuggestion(suggestion);
                            if (chosen.isNotEmpty) {
                              addressController.text = chosen;
                              setState(() {});
                            }
                            if (context.mounted) {
                              FocusScope.of(context).unfocus();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            }),

            // 7. Visual Confirmation when coordinates are pinned
            Obx(() {
              final hasCoords = controller.homeLatitude.value != 0.0 && controller.homeLongitude.value != 0.0;
              if (!hasCoords) return const SizedBox();
              return Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          "Location pinned on map".tr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 36),

            // 8. Save Changes Button
            Obx(() {
              final isSaving = controller.isUpdatingProfile.value;
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final address = addressController.text.trim();

                          if (name.isEmpty) {
                            showCustomSnackBar("Please enter your name".tr, isError: true);
                            return;
                          }

                          if (address.isEmpty) {
                            showCustomSnackBar("Please enter an address".tr, isError: true);
                            return;
                          }

                          if (address.length < 5) {
                            showCustomSnackBar("Address must be at least 5 characters".tr, isError: true);
                            return;
                          }

                          final success = await controller.updateSeekerAddressAndProfile(
                            name: name,
                            address: address,
                            latitude: controller.homeLatitude.value,
                            longitude: controller.homeLongitude.value,
                          );

                          if (success) {
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            showCustomSnackBar("Profile updated successfully".tr, isError: false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Save Changes'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
