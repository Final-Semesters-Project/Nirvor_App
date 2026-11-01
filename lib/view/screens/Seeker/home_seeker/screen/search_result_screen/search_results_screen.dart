import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nirbhor/utils/app_colors/app_colors.dart';
import 'package:nirbhor/view/components/custom_netwrok_image/custom_network_image.dart';
import 'package:nirbhor/view/components/custom_text/custom_text.dart';
import 'package:nirbhor/view/screens/Seeker/home_seeker/controller/home_seeker_controller.dart';
import 'package:nirbhor/utils/app_const/app_const.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../seeker_profile/controller/seeker_profile_controller.dart' show SeekerProfileController;

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeSeekerController controller = Get.find<HomeSeekerController>();
    final SeekerProfileController seekerProfileController = Get.find<SeekerProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomRoyelAppbar(
        titleName: 'KajerLok'.tr,
        leftIcon: true,
        centerTitleEnable: false,
        rightWidget: Obx(() {
          final profilePic = seekerProfileController.user.value?.photoUrl ?? '';
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Obx(
                () => Text(
                  'showing_providers'.trParams({'count': controller.providers.length.toString()}),
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.providers.isEmpty) {
                return Center(child: Text('no_providers_found'.tr));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                        color: index == 0 ? AppColors.primary : Colors.grey.shade300,
                        width: index == 0 ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
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
                            // Priority Badge (1, 2, 3...)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: index == 0 ? AppColors.primary : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    index == 0 ? Icons.workspace_premium : Icons.format_list_numbered,
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

                            // Availability Status
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
                                    provider.isAvailable ? 'Available'.tr : 'Unavailable'.tr,
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

                        // Middle Content: Photo, Name, Verification Level, Skills, Rating, Distance
                        Row(
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
                                              ? AppColors.primary.withOpacity(0.12)
                                              : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          provider.verificationLevel.isNotEmpty
                                              ? provider.verificationLevel.toUpperCase().tr
                                              : 'BASIC'.tr,
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
                                            ? provider.averageRating.toStringAsFixed(1)
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

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        // Bottom Row: Working Radius & Smartphone
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.radar, size: 16, color: Colors.grey.shade600),
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
                                  Icon(Icons.smartphone, size: 15, color: Colors.blue.shade700),
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

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (provider.phoneEn != null &&
                                  provider.phoneEn!.isNotEmpty) {
                                final Uri launchUri = Uri(
                                  scheme: 'tel',
                                  path: provider.phoneEn,
                                );
                                if (await canLaunchUrl(launchUri)) {
                                  await launchUrl(launchUri);
                                } else {
                                  Get.snackbar(
                                    'Error'.tr,
                                    'Could not launch phone app'.tr,
                                  );
                                }
                              } else {
                                Get.snackbar(
                                  'Notice'.tr,
                                  'Contact information will be available upon booking confirmation.'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'request_to_call'.tr,
                              textAlign: TextAlign.center,
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
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
