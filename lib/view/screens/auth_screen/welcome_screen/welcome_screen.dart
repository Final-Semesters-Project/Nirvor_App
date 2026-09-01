import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes/app_routes.dart';
import '../../../../utils/app_colors/app_colors.dart';
import '../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../components/custom_text/custom_text.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomRoyelAppbar(
        titleName: 'KajerLok'.tr,
        leftIcon: false,
        centerTitleEnable: false,
        showLanguageSwitcher: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CustomText(
              text: 'Welcome'.tr,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: 'Select how you want to use KajerLok'.tr,
              fontSize: 16,
              color: Colors.black54,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildSelectionCard(
              title: 'Find Help'.tr,
              subtitle: 'Hire skilled workers near you'.tr,
              icon: Icons.search,
              onTap: () {
                Get.toNamed(AppRoutes.registerMethodScreen);
              },
            ),
            const SizedBox(height: 24),
            _buildSelectionCard(
              title: 'Provide Service'.tr,
              subtitle: 'Find work near you'.tr,
              icon: Icons.handshake_outlined,
              isGreyIcon: true,
              onTap: () {
                Get.toNamed(AppRoutes.registerMethodScreen);
              },
            ),
            const SizedBox(height: 48),
            _buildChip(Icons.verified, 'Verified Profiles'.tr),
            const SizedBox(height: 16),
            _buildChip(Icons.star, 'Free to Join'.tr),
            const SizedBox(height: 40),
            CustomText(
              text: 'Empowering communities through trusted skill exchange.'.tr,
              fontSize: 12,
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isGreyIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: isGreyIcon ? Colors.grey.shade300 : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isGreyIcon ? Colors.black54 : Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: subtitle,
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    maxLines: 2,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          CustomText(
            text: label,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}
