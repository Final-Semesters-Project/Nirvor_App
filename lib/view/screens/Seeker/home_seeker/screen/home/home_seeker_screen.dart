import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nirbhor/utils/app_colors/app_colors.dart';
import 'package:nirbhor/utils/app_const/app_const.dart';
import 'package:nirbhor/view/components/custom_nav_bar/navbar.dart';
import 'package:nirbhor/view/components/custom_netwrok_image/custom_network_image.dart';
import 'package:nirbhor/view/components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../seeker_profile/controller/seeker_profile_controller.dart';
import '../../controller/home_seeker_controller.dart';
import '../search_result_screen/search_results_screen.dart';
import 'package:nirbhor/view/screens/urgent_request_flow/urgent_request_flow_screen.dart';
import 'package:nirbhor/view/screens/urgent_request_flow/controller/urgent_request_controller.dart';

class HomeSeekerScreen extends StatelessWidget {
  HomeSeekerScreen({super.key});

  final HomeSeekerController controller = Get.find<HomeSeekerController>();
  final SeekerProfileController seekerProfileController =
      Get.find<SeekerProfileController>();
  final UrgentRequestController urgentCtrl =
      Get.isRegistered<UrgentRequestController>()
          ? Get.find<UrgentRequestController>()
          : Get.put(UrgentRequestController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomRoyelAppbar(
        titleName: 'Nirbhor'.tr,
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
          
          // Active Booking Banner on Home Screen (if any)
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
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt, color: AppColors.primary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Active Booking / সক্রিয় বুকিং'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$providerName (${providerPhone.isNotEmpty ? providerPhone : ""})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: controller.isCancellingBooking.value
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Text(
                                  'Cancel / বাতিল'.tr,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 0,
                          ),
                          child: controller.isConfirmingBooking.value
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Confirm / নিশ্চিত'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
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

          // Active Search Location Bar (Allows Seeker to switch between Home & Current Location anytime)
          Obx(() {
            if (controller.currentSkillId.value == 0) return const SizedBox.shrink();
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
            child: Stack(
              children: [
                Obx(
                  () => GoogleMap(
                    onMapCreated: (GoogleMapController mapController) {
                      controller.customInfoWindowController.googleMapController =
                          mapController;
                    },
                    initialCameraPosition: CameraPosition(
                      target: controller.initialPosition.value,
                      zoom: 14,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    markers: controller.markers.toSet(),
                  ),
                ),
                // Floating Urgent SOS Badge on Map (top-right)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Obx(() {
                    final isBroadcasting =
                        urgentCtrl.flowState.value == UrgentFlowState.broadcasting;
                    final timeText = urgentCtrl.localizedFormattedTime;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.to(() => const UrgentRequestFlowScreen());
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE53935), Color(0xFFFF6F00)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE53935).withValues(
                                  alpha: isBroadcasting ? 0.55 : 0.4,
                                ),
                                blurRadius: isBroadcasting ? 14 : 10,
                                spreadRadius: isBroadcasting ? 1.5 : 0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isBroadcasting
                                    ? '${'Urgent'.tr} ($timeText)'
                                    : 'Urgent'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
        if (controller.providers.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton.extended(
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
        );
      }),
      bottomNavigationBar: const SeekerNavbar(currentIndex: 0),
    );
  }
}
