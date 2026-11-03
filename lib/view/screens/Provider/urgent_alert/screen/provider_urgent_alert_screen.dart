import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/provider_urgent_alert_controller.dart';

class ProviderUrgentAlertScreen extends StatelessWidget {
  final String broadcastId;
  final String? skillName;

  const ProviderUrgentAlertScreen({
    super.key,
    required this.broadcastId,
    this.skillName,
  });

  @override
  Widget build(BuildContext context) {
    // Set status bar to transparent with white icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final controller = Get.put(
      ProviderUrgentAlertController(
        broadcastId: broadcastId,
        initialSkillName: skillName,
      ),
      tag: broadcastId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF900C0C), // Deep crimson red background
      body: SafeArea(
        child: Obx(() {
          final currentSkill = controller.skillName;
          final isClaiming = controller.isClaiming.value;
          final isExpired = controller.isExpiredOrClaimed.value;
          final timerText = controller.formattedTimer;
          final distanceStr = controller.distanceText;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 12.h),

                // Top Bar: "Nirbhor" on left, "Expires in MM:SS" pill on right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Nirbhor",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14.sp,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            isExpired ? "Expired" : "Expires in $timerText",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // Red Rounded Square with White Lightning Bolt Icon
                Container(
                  width: 86.w,
                  height: 86.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB91C1C),
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.bolt_rounded,
                      size: 54.sp,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Bangla Headline
                Text(
                  "কেউ এখনই একজন $currentSkill খুঁজছেন!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: 8.h),

                // English Subtitle
                Text(
                  "Someone needs an $currentSkill RIGHT NOW!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(flex: 2),

                // Radar Map Dark Card
                Container(
                  height: 210.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.r),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Custom Painted Radar Map Canvas
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _RadarMapPainter(),
                          ),
                        ),

                        // Center Map Pin & Distance Pill
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pin Icon
                            Icon(
                              Icons.location_on,
                              color: const Color(0xFF14B8A6),
                              size: 26.sp,
                            ),
                            SizedBox(height: 2.h),

                            // Distance Badge Pill
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E).withOpacity(0.95),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: const Color(0xFF2DD4BF).withOpacity(0.4),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.near_me_outlined,
                                    size: 13.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    distanceStr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                if (isExpired) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      controller.statusMessage.value.isNotEmpty
                          ? controller.statusMessage.value
                          : "এই জরুরি অনুরোধটির সময় শেষ হয়ে গেছে।",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.amber.shade200,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const Spacer(flex: 3),

                // Big Green Accept Button
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: (isClaiming || isExpired)
                        ? null
                        : () => controller.claimBroadcast(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      disabledBackgroundColor:
                          const Color(0xFF16A34A).withOpacity(0.4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      shadowColor: Colors.black38,
                    ),
                    child: isClaiming
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 22.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Accept / গ্রহণ করুন",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Decline Link
                GestureDetector(
                  onTap: () => controller.decline(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      "Decline / প্রত্যাখ্যান করুন",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Custom painter to draw the dark stylized radar/map grid
class _RadarMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Draw subtle isometric / street grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Diagonal grid lines (streets simulation)
    const step = 28.0;
    for (double i = -size.height; i < size.width + size.height; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height * 0.7, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height * 0.7, 0),
        gridPaint,
      );
    }

    // 2. Concentric radar circles
    final radarPaint = Paint()
      ..color = const Color(0xFF14B8A6).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, 35, radarPaint);
    canvas.drawCircle(center, 65, dashPaint);
    canvas.drawCircle(center, 95, radarPaint);
    canvas.drawCircle(center, 130, dashPaint);

    // 3. Subtle radar crosshairs
    final crossPaint = Paint()
      ..color = const Color(0xFF14B8A6).withOpacity(0.12)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(center.dx - 120, center.dy),
      Offset(center.dx + 120, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 85),
      Offset(center.dx, center.dy + 85),
      crossPaint,
    );

    // 4. Center glow pulse
    final glowPaint = Paint()
      ..color = const Color(0xFF14B8A6).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center, 20, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

