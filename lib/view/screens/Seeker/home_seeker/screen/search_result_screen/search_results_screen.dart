import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nirbhor/utils/app_colors/app_colors.dart';
import 'package:nirbhor/view/components/custom_netwrok_image/custom_network_image.dart';
import 'package:nirbhor/view/components/custom_text/custom_text.dart';
import 'package:nirbhor/view/screens/Seeker/home_seeker/controller/home_seeker_controller.dart';
import 'package:nirbhor/utils/app_const/app_const.dart';

import '../../../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../seeker_profile/controller/seeker_profile_controller.dart'
    show SeekerProfileController;
import '../provider_details/provider_public_details_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeSeekerController controller = Get.find<HomeSeekerController>();
    final SeekerProfileController seekerProfileController =
        Get.find<SeekerProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomRoyelAppbar(
        titleName: 'Nirbhor'.tr,
        leftIcon: true,
        centerTitleEnable: false,
        rightWidget: Obx(() {
          final profilePic =
              seekerProfileController.user.value?.photoUrl ?? '';
          return CustomNetworkImage(
            imageUrl: profilePic.isNotEmpty
                ? profilePic
                : AppConstants.profileImage,
            height: 40,
            width: 40,
            borderRadius: BorderRadius.circular(12),
          );
        }),
        rightOnTap: () {},
      ),
      body: Column(
        children: [
          // Security Warning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.red.shade50,
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: CustomText(
                    text: 'prioritize_verified_providers'.tr,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    maxLines: 2,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Active Booking Card (Shown whenever seeker has an active initiated booking)
          Obx(() {
            if (!controller.hasActiveBooking.value ||
                controller.activeBookingData.value == null) {
              return const SizedBox.shrink();
            }

            final booking = controller.activeBookingData.value!;
            final providerName = booking['provider_name'] ?? 'Provider';
            final providerPhone = booking['provider_phone'] ?? '';
            final bookingId = booking['booking_id']?.toString() ?? '';
            final status = (booking['status'] ?? 'INITIATED').toString().toUpperCase();

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha:0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header with Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt, color: AppColors.primary, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Active Booking'.tr,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Provider Details Row (Clickable -> Opens ProviderPublicDetailsScreen)
                  InkWell(
                    onTap: () {
                      String pId = booking['provider_id']?.toString() ?? '';
                      if (pId.isEmpty) {
                        final match = controller.providers.firstWhereOrNull(
                          (p) =>
                              p.name == providerName ||
                              (providerPhone.isNotEmpty &&
                                  p.phoneEn == providerPhone),
                        );
                        if (match != null) {
                          pId = match.userId;
                        }
                      }
                      Get.to(() => ProviderPublicDetailsScreen(
                            providerId: pId,
                            providerName: providerName,
                            providerPhone: providerPhone,
                            bookingId: bookingId,
                            hasActiveBooking: true,
                          ));
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        providerName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                if (providerPhone.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(Icons.phone,
                                          size: 14, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        providerPhone,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action Buttons: Cancel and Confirm Hire
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: (controller.isCancellingBooking.value ||
                                  controller.isConfirmingBooking.value)
                              ? null
                              : () => controller.cancelBooking(bookingId),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: controller.isCancellingBooking.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Text(
                                  'Cancel'.tr,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (controller.isCancellingBooking.value ||
                                  controller.isConfirmingBooking.value)
                              ? null
                              : () => controller.showWorkSchedulePicker(
                                    bookingId,
                                    providerName: providerName,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isConfirmingBooking.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Confirm Hire'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // Search Location Context & Switcher
          Obx(() {
            final isHome = controller.selectedLocationMode.value == 'home';
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isHome ? Colors.teal.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isHome ? AppColors.primary : Colors.blue.shade300,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isHome ? Icons.home_rounded : Icons.my_location_rounded,
                    size: 18,
                    color: isHome ? AppColors.primary : Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHome
                              ? 'Searching near Home Address'.tr
                              : 'Searching near Current Location'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isHome ? AppColors.primary : Colors.blue.shade900,
                          ),
                        ),
                        if (controller.selectedLocationAddress.value.isNotEmpty)
                          Text(
                            controller.selectedLocationAddress.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      controller.showLocationSelectionSheet(
                        controller.currentSkillId.value,
                        controller.currentSkillName.value,
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            'Change'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isHome ? AppColors.primary : Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 16,
                            color: isHome ? AppColors.primary : Colors.blue.shade800,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Search Results Header Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Obx(
                () => Text(
                  '${'Search Results'.tr} (${controller.providers.length})',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Provider List (Blurred & Disabled when there is an active booking)
          Expanded(
            child: Obx(() {
              if (controller.providers.isEmpty) {
                return Center(child: Text('no_providers_found'.tr));
              }

              final bool hasActive = controller.hasActiveBooking.value;

              Widget listView = ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: controller.providers.length,
                itemBuilder: (context, index) {
                  final provider = controller.providers[index];
                  final isVerified =
                      provider.verificationLevel.toLowerCase() == 'verified' ||
                          provider.verificationLevel.toLowerCase() == 'trusted';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: index == 0
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: index == 0 ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header: Priority Badge + Availability Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: index == 0
                                    ? AppColors.primary
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    index == 0
                                        ? Icons.workspace_premium
                                        : Icons.format_list_numbered,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${'Priority'.tr} #${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: provider.isAvailable
                                    ? Colors.green.shade50
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: provider.isAvailable
                                      ? Colors.green.shade400
                                      : Colors.grey.shade400,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: provider.isAvailable
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    provider.isAvailable
                                        ? 'Available'.tr
                                        : 'Unavailable'.tr,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: provider.isAvailable
                                          ? Colors.green.shade800
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Middle Content (Clickable -> Opens ProviderPublicDetailsScreen)
                        InkWell(
                          onTap: () {
                            final activeBooking =
                                controller.activeBookingData.value;
                            String? activeBookingId;
                            String? activePhone;
                            if (hasActive && activeBooking != null) {
                              activeBookingId =
                                  activeBooking['booking_id']?.toString();
                              activePhone =
                                  activeBooking['provider_phone']?.toString();
                            }

                            Get.to(() => ProviderPublicDetailsScreen(
                                  providerId: provider.userId,
                                  providerName: provider.name,
                                  providerPhone:
                                      provider.phoneEn ?? activePhone,
                                  photoUrl: provider.photoUrl,
                                  bookingId: activeBookingId,
                                  hasActiveBooking: hasActive,
                                  providerModel: provider,
                                ));
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  CustomNetworkImage(
                                    imageUrl: provider.photoUrl.isNotEmpty
                                        ? provider.photoUrl
                                        : AppConstants.profileImage,
                                    height: 64,
                                    width: 64,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  if (isVerified)
                                    Positioned(
                                      bottom: -2,
                                      right: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.verified,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            provider.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isVerified
                                                ? AppColors.primary
                                                    .withValues(alpha: 0.12)
                                                : Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            (provider.verificationLevel
                                                            .toLowerCase() ==
                                                        'basic' ||
                                                    provider.verificationLevel
                                                        .isEmpty)
                                                ? 'UNVERIFIED'.tr
                                                : provider.verificationLevel
                                                    .toUpperCase()
                                                    .tr,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isVerified
                                                  ? AppColors.primary
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    // Skill Name
                                    Text(
                                      provider.skillNames.isNotEmpty
                                          ? provider.skillNames.join(', ')
                                          : 'General Service'.tr,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),

                                    // Rating & Distance
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 18,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          provider.averageRating > 0
                                              ? provider.averageRating
                                                  .toStringAsFixed(1)
                                              : 'New'.tr,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 15,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${provider.distanceKm} km',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        // Bottom Row: Working Radius & Smartphone
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.radar,
                                    size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  '${'Working Radius'.tr}: ${provider.workingRadiusKm.toInt()} KM',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (provider.hasSmartphone)
                              Row(
                                children: [
                                  Icon(Icons.smartphone,
                                      size: 15, color: Colors.blue.shade700),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Smartphone'.tr,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Action Button: Request to Call
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: hasActive || controller.isInitiatingBooking.value
                                ? null
                                : () => controller.initiateBooking(provider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isInitiatingBooking.value
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'request_to_call'.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: hasActive
                                          ? Colors.grey.shade500
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );

              // If an active booking exists, blur the rest of the list so seeker can't contact others
              if (hasActive) {
                return Stack(
                  children: [
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                      child: IgnorePointer(
                        ignoring: true,
                        child: listView,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha:0.75),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, color: Colors.amber, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'active_booking_blur_warning'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return listView;
            }),
          ),
        ],
      ),
    );
  }
}
