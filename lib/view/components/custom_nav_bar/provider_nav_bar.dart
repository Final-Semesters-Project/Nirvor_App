import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../screens/Provider/home_provider/screen/provider_home_screen.dart';

class ProviderNavBar extends StatefulWidget {
  final int currentIndex;

  const ProviderNavBar({required this.currentIndex, super.key});

  @override
  State<ProviderNavBar> createState() => _ProviderNavBarState();
}

class _ProviderNavBarState extends State<ProviderNavBar> {
  late int bottomNavIndex;

  final List<IconData> icons = [
    Icons.dashboard_outlined,
    Icons.receipt_long,
    Icons.notifications_outlined,
    Icons.person_outline,
  ];
  final List<IconData> activeIcons = [
    Icons.dashboard,
    Icons.receipt_long,
    Icons.notifications,
    Icons.person,
  ];

  @override
  void initState() {
    bottomNavIndex = widget.currentIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> labels = [
      'Dashboard'.tr,
      'Bookings'.tr,
      'Notifications'.tr,
      'Profile'.tr,
    ];

    return Container(
      padding: EdgeInsets.only(
        left: 10.w,
        right: 10.w,
        top: 12.h,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 12.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, labels[0]),
          _buildNavItem(1, labels[1]),
          _buildNavItem(2, labels[2]),
          _buildNavItem(3, labels[3]),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label) {
    bool isSelected = index == bottomNavIndex;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(20.r),
      child: SizedBox(
        width: 70.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcons[index] : icons[index],
              size: 26.sp,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void onTap(int index) {
    if (index != bottomNavIndex) {
      setState(() {
        bottomNavIndex = index;
      });

      switch (index) {
        case 0:
          Get.offAll(() => const ProviderHomeScreen());
          break;
        case 1:
          // Get.to(() => BookingsScreen());
          break;
        case 2:
          // Get.to(() => NotificationsScreen());
          break;
        case 3:
          // Get.to(() => ProfileScreen());
          break;
      }
    }
  }
}
