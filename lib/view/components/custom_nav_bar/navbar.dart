import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../screens/Seeker/home_seeker/home_seeker_screen.dart';

class SeekerNavbar extends StatefulWidget {
  final int currentIndex;

  const SeekerNavbar({required this.currentIndex, super.key});

  @override
  State<SeekerNavbar> createState() => _SeekerNavbarState();
}

class _SeekerNavbarState extends State<SeekerNavbar> {
  late int bottomNavIndex;

  final List<IconData> icons = [Icons.explore, Icons.receipt_long, Icons.person];

  @override
  void initState() {
    bottomNavIndex = widget.currentIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> labels = ['Home'.tr, 'Bookings'.tr, 'Profile'.tr];

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
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
          )
        ],
      ),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, labels[0]),
          _buildNavItem(1, labels[1]),
          _buildNavItem(2, labels[2]),
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
        width: 80.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icons[index],
              size: 26.sp,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade500,
              ),
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
         Get.offAll(() => HomeSeekerScreen());
          break;
        case 1:
          // Get.to(() => BookingsScreen());
          break;
        case 2:
          // Get.to(() => ProfileScreen());
          break;
      }
    }
  }
}
