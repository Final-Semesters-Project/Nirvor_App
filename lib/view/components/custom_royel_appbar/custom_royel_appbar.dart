// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../custom_image/custom_image.dart';
import '../custom_text/custom_text.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomRoyelAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleName;
  final String? rightIcon;
  final String? rightText;
  final Widget? rightWidget;
  final Color? color;
  final Color? leftIconColor;
  //final void Function()? leftOnTap;
  final void Function()? rightOnTap;
  final bool? leftIcon;
  final bool? centerTitleEnable;
  final bool showLanguageSwitcher;
  final void Function()? onLanguageChanged;

  const CustomRoyelAppbar({
    super.key,
    this.titleName,
    this.color,
    this.leftIconColor,
    // this.leftOnTap,
    this.rightIcon,
    this.rightText,
    this.rightWidget,
    this.rightOnTap,
    this.leftIcon = false,
    this.centerTitleEnable = true,
    this.showLanguageSwitcher = false,
    this.onLanguageChanged,
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
        if (showLanguageSwitcher)
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              if (Get.locale?.languageCode == 'en') {
                Get.updateLocale(const Locale('bn', 'BD'));
                await prefs.setString('languageCode', 'bn');
                await prefs.setString('countryCode', 'BD');
              } else {
                Get.updateLocale(const Locale('en', 'US'));
                await prefs.setString('languageCode', 'en');
                await prefs.setString('countryCode', 'US');
              }
              onLanguageChanged?.call();
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'English'.tr,
                    style: TextStyle(
                      color: Get.locale?.languageCode == 'bn'
                          ? Colors.grey
                          : AppColors.primary,
                      fontWeight: Get.locale?.languageCode == 'bn'
                          ? FontWeight.w400
                          : FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                  TextSpan(
                    text: '/',
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                  ),
                  TextSpan(
                    text: 'বাংলা'.tr,
                    style: TextStyle(
                      color: Get.locale?.languageCode == 'bn'
                          ? AppColors.primary
                          : Colors.grey,
                      fontWeight: Get.locale?.languageCode == 'bn'
                          ? FontWeight.w700
                          : FontWeight.w400,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          IconButton(
            onPressed: () {
              if (rightOnTap != null) rightOnTap!();
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: rightWidget != null
                ? rightWidget!
                : rightText != null
                    ? CustomText(
                        text: rightText!,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      )
                    : rightIcon == null
                        ? SizedBox.shrink()
                        : CustomImage(
                            imageSrc: rightIcon!,
                            height: 24,
                            width: 24,
                            imageColor: AppColors.black,
                          ),
          ),
      ],
      backgroundColor: Colors.transparent,
      leading: leftIcon == true
          ? BackButton(color: leftIconColor ?? Colors.black)
          : SizedBox.shrink(),
      leadingWidth: leftIcon == true ? kToolbarHeight : 0,

      title: Align(
        alignment: centerTitleEnable == true
            ? Alignment.center
            : Alignment.centerLeft,
        child: CustomText(
          text: titleName ?? "",
          fontSize: 20.w,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.primary,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey.shade200,
        ),
      ),
    );
  }

  @override
  // TO DO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(61);
}
