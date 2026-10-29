import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:nirbhor/utils/app_colors/app_colors.dart';
import 'package:nirbhor/utils/app_const/app_const.dart';
import 'package:nirbhor/view/components/custom_nav_bar/navbar.dart';
import 'package:nirbhor/view/components/custom_netwrok_image/custom_network_image.dart';
import 'package:nirbhor/view/components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../seeker_profile/controller/seeker_profile_controller.dart';
import '../../controller/home_seeker_controller.dart';
import '../search_result_screen/search_results_screen.dart';

class HomeSeekerScreen extends StatelessWidget {
  HomeSeekerScreen({super.key});

  final HomeSeekerController controller = Get.find<HomeSeekerController>();
  final SeekerProfileController seekerProfileController =
      Get.find<SeekerProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: CustomRoyelAppbar(
        titleName: 'KajerLok'.tr,
        leftIcon: false,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Obx(
              () => Text(
                '${'Hello'.tr}, ${seekerProfileController.user.value?.name ?? ''}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          
          
          SizedBox(
            height: 50,
            child: Obx(() {
              if (controller.isLoadingCategories.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              
            
              final selectedIndex = controller.selectedCategoryIndex.value;
              
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;
                  final category = controller.categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      showCheckmark: false,
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        if (selected) {
                          controller.selectCategory(index);
                        }
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Obx(
              () => GoogleMap(
                onMapCreated: (GoogleMapController mapController) {
                  controller.customInfoWindowController.googleMapController = mapController;
                },
                initialCameraPosition: CameraPosition(
                  target: controller.initialPosition.value,
                  zoom: 14,
                ),
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                markers: controller.markers.toSet(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
        if (controller.providers.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: FloatingActionButton.extended(
            onPressed: () {
              Get.to(() => const SearchResultsScreen());
            },
            backgroundColor: AppColors.primary,
            elevation: 6,
            icon: const Icon(Icons.format_list_numbered, color: Colors.white),
            label: Text(
              '${'View All Providers'.tr} (${controller.providers.length})',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: const SeekerNavbar(currentIndex: 0),
    );
  }
}
