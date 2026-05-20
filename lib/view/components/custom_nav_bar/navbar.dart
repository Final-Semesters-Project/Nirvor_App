import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/app_colors/app_colors.dart';

class HostNavbar extends StatefulWidget {
  final int currentIndex;

  const HostNavbar({required this.currentIndex, super.key});

  @override
  State<HostNavbar> createState() => _HostNavBarState();
}

class _HostNavBarState extends State<HostNavbar> {
  late int bottomNavIndex;

  final List<IconData> icons = [Icons.home, Icons.settings];

  final List<String> labels = ['SetUp_Profile_Screen', 'Settings'];

  @override
  void initState() {
    bottomNavIndex = widget.currentIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.zero,
            ),
            height: 80.h,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0),
                SizedBox(width: 60.w),
                _buildNavItem(1),
              ],
            ),
          ),
        ),
        // Floating Add Button
        Positioned(
          top: -20.h,
          left: MediaQuery.of(context).size.width / 2 - 28.w,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  // Get.toNamed(AppRoutes.addDocument);
                },
                child: Container(
                  width: 60.w,
                  height: 60.h, // increased height
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 26.sp),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Add",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index) {
    bool isSelected = index == bottomNavIndex;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(20.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 13.h),
          Icon(
            icons[index],
            size: 25.sp,
            color: isSelected ? AppColors.primary : Colors.grey,
          ),
          SizedBox(height: 4.h),
          Text(
            labels[index],
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
          ),
        ],
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
          // Get.offAll(() => HomeScreen());
          break;
        case 1:
          // Get.to(() => ProfileScreen());
          break;
      }
    }
  }
}
