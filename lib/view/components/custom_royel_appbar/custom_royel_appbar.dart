// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../custom_image/custom_image.dart';
import '../custom_text/custom_text.dart';

class CustomRoyelAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleName;
  final String? rightIcon;
  final Color? color;
  final Color? leftIconColor;
  //final void Function()? leftOnTap;
  final void Function()? rightOnTap;
  final bool? leftIcon;
  final bool? centerTitleEnable;

  const CustomRoyelAppbar({
    super.key,
    this.titleName,
    this.color,
    this.leftIconColor,
    // this.leftOnTap,
    this.rightIcon,
    this.rightOnTap,
    this.leftIcon = false,
    this.centerTitleEnable = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
        toolbarHeight: 80,
        elevation: 0,
        foregroundColor: Colors.transparent,
        centerTitle: centerTitleEnable,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                rightOnTap!();
              },
              icon: rightIcon == null
                  ? SizedBox()
                  : CustomImage(
                imageSrc: rightIcon!,
                height: 24,
                width: 24,
                imageColor: AppColors.black,
              )),
        ],
        backgroundColor: Colors.transparent,
        leading: leftIcon == true ? BackButton(color: leftIconColor ?? Colors.black,) : SizedBox.shrink(),
        leadingWidth: leftIcon == true ? kToolbarHeight : 0,

      title: Align(
        alignment: centerTitleEnable == true
            ? Alignment.center
            : Alignment.centerLeft,
        child: CustomText(
          text: titleName ?? "",
          fontSize: 20.w,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.black,
        ),
      ),
    );
  }

  @override
  // TO DO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(60);
}
