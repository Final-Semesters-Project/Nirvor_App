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
                      provider.verificationLevel == 'verified' ||
                      provider.verificationLevel == 'trusted';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius
                          .zero, // Based on design, looks very square
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CustomNetworkImage(
                                  imageUrl: provider.photoUrl.isNotEmpty
                                      ? provider.photoUrl
                                      : AppConstants.profileImage,
                                  height: 60,
                                  width: 60,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                if (isVerified)
                                  Positioned(
                                    bottom: -4,
                                    right: -4,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
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
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isVerified
                                              ? AppColors.primary.withValues(
                                                  alpha: 0.15,
                                                )
                                              : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isVerified)
                                              const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: AppColors.primary,
                                              ),
                                            if (isVerified)
                                              const SizedBox(width: 2),
                                            Text(
                                              isVerified
                                                  ? 'verified'.tr
                                                  : 'unverified'.tr,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isVerified
                                                    ? AppColors.primary
                                                    : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_border,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        provider.averageRating.toStringAsFixed(
                                          1,
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '•',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${provider.distanceKm} km',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    provider.skillNames.join(', '),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
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
                                        'Error',
                                        'Could not launch phone app',
                                      );
                                    }
                                  } else {
                                    Get.snackbar(
                                      'Error',
                                      'Phone number not available',
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
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
                            const SizedBox(width: 8),
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  // View Details Action
                                },
                                icon: const Icon(Icons.info_outline),
                                color: Colors.black87,
                              ),
                            ),
                          ],
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
