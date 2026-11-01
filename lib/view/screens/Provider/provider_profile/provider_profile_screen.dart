import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nirbhor/utils/app_colors/app_colors.dart';
import 'package:nirbhor/utils/app_const/app_const.dart';
import 'package:nirbhor/view/components/custom_nav_bar/provider_nav_bar.dart';
import 'package:nirbhor/view/components/custom_netwrok_image/custom_network_image.dart';
import 'package:nirbhor/view/components/custom_text/custom_text.dart';
import '../../auth_screen/controller/auth_controller.dart';
import 'controller/provider_profile_controller.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderProfileController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: CustomText(
          text: 'Profile'.tr,
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final user = controller.user.value;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Could not load profile.".tr),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => controller.getUserProfile(),
                  child: Text("Retry".tr),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: CustomNetworkImage(
                  imageUrl: user.photoUrl.isNotEmpty ? user.photoUrl : AppConstants.profileImage,
                  height: 100,
                  width: 100,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.phone,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final auth = Get.isRegistered<AuthController>()
                      ? Get.find<AuthController>()
                      : Get.put(AuthController());
                  final isLoading = auth.isAuthLoading.value;
                  return ElevatedButton.icon(
                    onPressed: isLoading ? null : () => auth.logout(),
                    icon: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      isLoading ? 'Logging out...'.tr : 'Logout'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: const ProviderNavBar(currentIndex: 3),
    );
  }
}