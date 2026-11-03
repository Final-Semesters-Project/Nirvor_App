import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nirbhor/utils/app_colors/app_colors.dart';
import 'package:nirbhor/utils/ToastMsg/toast_message.dart';
import 'package:nirbhor/view/components/custom_text/custom_text.dart';
import 'package:nirbhor/view/components/custom_text_field/custom_text_field.dart';
import 'package:nirbhor/view/screens/auth_screen/setup_details/map_location_picker_screen.dart';
import '../controller/seeker_profile_controller.dart';
import '../model/user_model.dart';

class EditSeekerProfileScreen extends StatefulWidget {
  const EditSeekerProfileScreen({super.key});

  @override
  State<EditSeekerProfileScreen> createState() => _EditSeekerProfileScreenState();
}

class _EditSeekerProfileScreenState extends State<EditSeekerProfileScreen> {
  final SeekerProfileController controller = Get.find<SeekerProfileController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String _initialName = '';
  String _initialAddress = '';
  bool _nameManuallyChanged = false;
  bool _addressManuallyChanged = false;
  Worker? _userWorker;

  @override
  void initState() {
    super.initState();
    _populateFields();
    _userWorker = ever(controller.user, (UserModel? u) {
      if (mounted && u != null && !_nameManuallyChanged) {
        _populateNameField(u);
        if (addressController.text.isEmpty && u.homeAddress.isNotEmpty && !_addressManuallyChanged) {
          addressController.text = u.homeAddress;
          _initialAddress = u.homeAddress.trim();
        }
        setState(() {});
      }
    });

    // 2. Fetch fresh user profile if not yet loaded or to ensure latest
    controller.getUserProfile(showLoading: controller.user.value == null).then((_) {
      if (mounted && controller.user.value != null && !_nameManuallyChanged) {
        _populateNameField(controller.user.value!);
        setState(() {});
      }
    });

    // 3. Refresh address from backend GET /api/v1/seeker/me/address
    controller.fetchSeekerAddress().then((_) {
      if (mounted && addressController.text.isEmpty && controller.homeAddress.value.isNotEmpty && !_addressManuallyChanged) {
        setState(() {
          addressController.text = controller.homeAddress.value;
          _initialAddress = controller.homeAddress.value.trim();
        });
      }
    });
  }

  void _populateFields() {
    final u = controller.user.value;
    if (u != null) {
      _populateNameField(u);
    }

    if (controller.homeAddress.value.isNotEmpty) {
      addressController.text = controller.homeAddress.value;
    } else if (u != null && u.homeAddress.isNotEmpty) {
      addressController.text = u.homeAddress;
      controller.homeAddress.value = u.homeAddress;
      if (u.homeLatitude != null) {
        controller.homeLatitude.value = u.homeLatitude!;
      }
      if (u.homeLongitude != null) {
        controller.homeLongitude.value = u.homeLongitude!;
      }
    }

    _initialName = nameController.text.trim();
    _initialAddress = addressController.text.trim();
  }

  void _populateNameField(UserModel u) {
    final bool isBn = Get.locale?.languageCode == 'bn';
    String resolvedName = '';
    if (isBn && u.nameBn != null && u.nameBn!.isNotEmpty) {
      resolvedName = u.nameBn!;
    } else if (!isBn && u.nameEn != null && u.nameEn!.isNotEmpty) {
      resolvedName = u.nameEn!;
    } else if (u.name.isNotEmpty) {
      resolvedName = u.name;
    } else if (u.nameEn != null && u.nameEn!.isNotEmpty) {
      resolvedName = u.nameEn!;
    } else if (u.nameBn != null && u.nameBn!.isNotEmpty) {
      resolvedName = u.nameBn!;
    }
    nameController.text = resolvedName;
    _initialName = resolvedName.trim();
  }

  @override
  void dispose() {
    _userWorker?.dispose();
    controller.pickedProfileImage.value = null;
    controller.pickedProfileImageBytes.value = null;
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _showImagePickerSheet({required Function(ImageSource) onSourceSelected}) {
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
                GestureDetector(
                  onTap: () {
                    _showImagePickerSheet(
                      onSourceSelected: (source) {
                        controller.pickProfilePhoto(source);
                      },
                    );
                  },
                  child: Obx(() {
                    final bytes = controller.pickedProfileImageBytes.value;
                    final picked = controller.pickedProfileImage.value;
                    final user = controller.user.value;
                    final remoteUrl = user?.photoUrl ?? '';

                    ImageProvider? imageProvider;
                    if (bytes != null && bytes.isNotEmpty) {
                      imageProvider = MemoryImage(bytes);
                    } else if (picked != null && picked.existsSync()) {
                      imageProvider = FileImage(picked);
                    } else if (remoteUrl.isNotEmpty) {
                      imageProvider = NetworkImage(remoteUrl);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage: imageProvider,
                        child: (imageProvider == null)
                            ? const Icon(Icons.person, size: 54, color: Colors.grey)
                            : null,
                      ),
                    );
                  }),
                ),
                GestureDetector(
                  onTap: () {
                    _showImagePickerSheet(
                      onSourceSelected: (source) {
                        controller.pickProfilePhoto(source);
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
            const SizedBox(height: 10),
            CustomText(
              text: isBn
                  ? "ছবি পরিবর্তন করতে ক্যামেরা আইকনে চাপ দিন"
                  : "Tap camera icon to change profile photo",
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 28),

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
              onChanged: (val) {
                _nameManuallyChanged = true;
                setState(() {});
              },
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
                          _addressManuallyChanged = true;
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
                        _addressManuallyChanged = true;
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
                _addressManuallyChanged = true;
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
                            _addressManuallyChanged = true;
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
              final bool isSynced = hasCoords && addressController.text.trim() == controller.homeAddress.value;
              if (!hasCoords && addressController.text.trim().isEmpty) return const SizedBox();
              return Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isSynced ? AppColors.primary : Colors.amber.shade700).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: (isSynced ? AppColors.primary : Colors.amber.shade700).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSynced ? Icons.check_circle : Icons.info_outline,
                          size: 14,
                          color: isSynced ? AppColors.primary : Colors.amber.shade800,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isSynced
                              ? "Location pinned on map".tr
                              : "Auto-detecting GPS or tap map to pin".tr,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSynced ? AppColors.primary : Colors.amber.shade900,
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
              final isSaving = controller.isSaving.value;
              final statusText = controller.savingStatusText.value;

              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          final currentName = nameController.text.trim();
                          final currentAddress = addressController.text.trim();

                          if (currentName.isEmpty) {
                            showCustomSnackBar("Please enter your name".tr, isError: true);
                            return;
                          }

                          if (currentAddress.isEmpty) {
                            showCustomSnackBar("Please enter an address".tr, isError: true);
                            return;
                          }

                          if (currentAddress.length < 5) {
                            showCustomSnackBar("Address must be at least 5 characters".tr, isError: true);
                            return;
                          }

                          final bool nameChanged = _nameManuallyChanged &&
                              currentName.isNotEmpty &&
                              currentName != _initialName;

                          final bool addressChanged = _addressManuallyChanged &&
                              currentAddress.isNotEmpty &&
                              currentAddress != _initialAddress;

                          final bool photoChanged =
                              controller.pickedProfileImageBytes.value != null ||
                              controller.pickedProfileImage.value != null;

                          if (!nameChanged && !addressChanged && !photoChanged) {
                            showCustomSnackBar("No changes to save".tr, isError: false);
                            return;
                          }

                          final success = await controller.saveProfileAndAddressChanges(
                            newName: nameChanged ? currentName : null,
                            newNameBn: (nameChanged && isBn) ? currentName : null,
                            newNameEn: (nameChanged && !isBn) ? currentName : null,
                            newAddress: addressChanged ? currentAddress : null,
                            newLatitude: addressChanged ? controller.homeLatitude.value : null,
                            newLongitude: addressChanged ? controller.homeLongitude.value : null,
                            addressChanged: addressChanged,
                          );

                          if (success && mounted) {
                            navigator.pop(true);
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
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              statusText.isNotEmpty
                                  ? statusText
                                  : (isBn ? 'সংরক্ষণ করা হচ্ছে...' : 'Saving changes...'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save_outlined, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Save Changes'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
