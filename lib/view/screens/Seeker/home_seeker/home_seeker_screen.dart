import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nirbhor/utils/app_colors/app_colors.dart';
import 'package:nirbhor/utils/app_const/app_const.dart';
import 'package:nirbhor/view/components/custom_nav_bar/navbar.dart';
import 'package:nirbhor/view/components/custom_netwrok_image/custom_network_image.dart';
import 'package:nirbhor/view/components/custom_royel_appbar/custom_royel_appbar.dart';
import 'home_seeker_controller.dart';

class HomeSeekerScreen extends StatelessWidget {
  HomeSeekerScreen({super.key});

  final HomeSeekerController controller = Get.put(HomeSeekerController());

  final List<String> categories = [
    'Manual Labor'.tr,
    'Home Repair'.tr,
    'Cleaning'.tr, // extra if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, 
      appBar: CustomRoyelAppbar(
        titleName: 'KajerLok'.tr,
        leftIcon: false,
        centerTitleEnable: false,
        rightWidget: CustomNetworkImage(
          imageUrl: AppConstants.profileImage2,
          height: 40,
          width: 40,
          borderRadius: BorderRadius.circular(12),
        ),
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
            child: Text(
              '${'Hello'.tr}, Rahim',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for a skill...'.tr,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Obx(() {
                  final isSelected = controller.selectedCategoryIndex.value == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      showCheckmark: false,
                      label: Text(categories[index]),
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
                });
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(23.7947, 90.4010),
                zoom: 14,
              ),
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              markers: {
                const Marker(
                  markerId: MarkerId('1'),
                  position: LatLng(23.7947, 90.4010),
                  infoWindow: InfoWindow(title: 'Rahim'),
                ),
                const Marker(
                  markerId: MarkerId('2'),
                  position: LatLng(23.7960, 90.4030),
                  infoWindow: InfoWindow(title: 'Karim'),
                ),
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SeekerNavbar(currentIndex: 0),
    );
  }
}
