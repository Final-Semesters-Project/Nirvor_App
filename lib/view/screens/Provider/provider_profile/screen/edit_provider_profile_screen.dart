import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../utils/app_colors/app_colors.dart';
import '../../../../../../utils/app_const/app_const.dart';
import '../../../../components/custom_netwrok_image/custom_network_image.dart';
import '../controller/provider_profile_controller.dart';

class EditProviderProfileScreen extends StatefulWidget {
  const EditProviderProfileScreen({super.key});

  @override
  State<EditProviderProfileScreen> createState() =>
      _EditProviderProfileScreenState();
}

class _EditProviderProfileScreenState extends State<EditProviderProfileScreen> {
  final ProviderProfileController controller =
      Get.find<ProviderProfileController>();

  final TextEditingController nameEnController = TextEditingController();
  final TextEditingController nameBnController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    final me = controller.providerMe.value;
    if (me != null) {
      nameEnController.text = me.name;
      nameBnController.text = me.name;
    } else if (controller.user.value != null) {
      nameEnController.text = controller.user.value!.name;
      nameBnController.text = controller.user.value!.name;
    }
  }

  @override
  void dispose() {
    nameEnController.dispose();
    nameBnController.dispose();
    super.dispose();
  }

  void _showImagePickerSheet({required Function(ImageSource) onSourceSelected}) {
    final bool isBn = Get.locale?.languageCode == 'bn';
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBn ? 'ছবি নির্বাচন করুন' : 'Select Photo Source',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.primary),
              ),
              title: Text(
                isBn ? 'ক্যামেরা দিয়ে ছবি তুলুন' : 'Take a photo with Camera',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Get.back();
                onSourceSelected(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_rounded,
                    color: Color(0xFF0284C7)),
              ),
              title: Text(
                isBn ? 'গ্যালারি থেকে পছন্দ করুন' : 'Choose from Gallery',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Get.back();
                onSourceSelected(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = Get.locale?.languageCode == 'bn';
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Profile / প্রোফাইল এডিট করুন',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Update your verified provider information',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Verification Badge Pill
            Obx(() {
              final level = controller.providerMe.value?.verificationLevel
                      .toUpperCase() ??
                  'BASIC';
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      level,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(width: 14),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          children: [
            // 1. Profile Photo Squircle Slot
            Center(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Obx(() {
                        final picked = controller.pickedProfileImage.value;
                        final remotePhoto =
                            controller.providerMe.value?.photoUrl ??
                                controller.user.value?.photoUrl ??
                                '';

                        return Container(
                          width: 106,
                          height: 106,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(21),
                            child: picked != null
                                ? Image.file(
                                    picked,
                                    fit: BoxFit.cover,
                                    width: 106,
                                    height: 106,
                                  )
                                : CustomNetworkImage(
                                    imageUrl: remotePhoto.isNotEmpty
                                        ? remotePhoto
                                        : AppConstants.profileImage,
                                    width: 106,
                                    height: 106,
                                  ),
                          ),
                        );
                      }),
                      // Circular camera/pencil edit button at bottom-right
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () {
                            _showImagePickerSheet(
                              onSourceSelected: (source) =>
                                  controller.pickProfilePhoto(source),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F766E),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Profile Photo / প্রোফাইল ছবি',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // 2. Personal Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information /\nব্যক্তিগত তথ্য',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Full Name (English)
                  Text(
                    'Full Name (English) / সম্পূর্ণ নাম (ইংরেজি)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameEnController,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter full name in English',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color(0xFF0F766E),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Full Name (Bangla)
                  Text(
                    'সম্পূর্ণ নাম (বাংলা) / Full Name (Bangla)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameBnController,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'সম্পূর্ণ নাম বাংলায় লিখুন',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color(0xFF0F766E),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. NID Verification Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF0F766E).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.badge_outlined,
                          size: 18,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'NID Verification / এনআইডি যাচাইকরণ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // NID Front Box
                  Obx(() {
                    final picked = controller.pickedFrontNid.value;
                    final remoteUrl =
                        controller.providerMe.value?.nidUrlFront ?? '';
                    return _buildNidSlot(
                      title: isBn
                          ? 'এনআইডি সামনের দিক'
                          : 'NID Front Side',
                      subtext: isBn
                          ? 'ক্যামেরা দিয়ে ছবি তুলুন'
                          : 'Take photo with camera',
                      pickedFile: picked,
                      remoteUrl: remoteUrl,
                      onTap: () {
                        controller.pickNidImage(
                          isFront: true,
                          source: ImageSource.camera,
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 14),

                  // NID Back Box
                  Obx(() {
                    final picked = controller.pickedBackNid.value;
                    final remoteUrl =
                        controller.providerMe.value?.nidUrlBack ?? '';
                    return _buildNidSlot(
                      title: isBn
                          ? 'এনআইডি পিছনের দিক'
                          : 'NID Back Side',
                      subtext: isBn
                          ? 'ক্যামেরা দিয়ে ছবি তুলুন'
                          : 'Take photo with camera',
                      pickedFile: picked,
                      remoteUrl: remoteUrl,
                      onTap: () {
                        controller.pickNidImage(
                          isFront: false,
                          source: ImageSource.camera,
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 14),

                  // Encryption Info Note
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Your NID data is encrypted and only used for community trust verification. / আপনার এনআইডি তথ্য এনক্রিপ্টেড এবং শুধুমাত্র কমিউনিটি ট্রাস্ট যাচাইয়ের জন্য ব্যবহৃত হয়।',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey.shade600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 4. Save Changes Button
            Obx(() {
              final isSaving = controller.isSaving.value;
              final statusText = controller.savingStatusText.value;

              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          final success =
                              await controller.saveProfileChanges();
                          if (success && mounted) {
                            navigator.pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF0F766E).withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              statusText.isNotEmpty
                                  ? statusText
                                  : 'সংরক্ষণ করা হচ্ছে...',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined,
                                size: 20, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Save Changes / পরিবর্তন সংরক্ষণ করুন',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNidSlot({
    required String title,
    required String subtext,
    File? pickedFile,
    required String remoteUrl,
    required VoidCallback onTap,
  }) {
    final bool hasImage = pickedFile != null || remoteUrl.isNotEmpty;
    final bool isBn = Get.locale?.languageCode == 'bn';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        painter: DashedRectPainter(
          color: hasImage ? const Color(0xFF0F766E) : const Color(0xFFCBD5E1),
          strokeWidth: 1.3,
          dash: 6,
          gap: 4,
          radius: 12,
        ),
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: hasImage
                ? const Color(0xFF0F766E).withValues(alpha: 0.03)
                : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: hasImage
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: pickedFile != null
                          ? Image.file(
                              pickedFile,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 120,
                            )
                          : CustomNetworkImage(
                              imageUrl: remoteUrl,
                              width: double.infinity,
                              height: 120,
                            ),
                    ),
                    // Semitransparent bottom pill for changing image
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              isBn ? 'পুনরায় তুলুন' : 'Retake',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 26,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtext,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Custom painter for dashed rounded rectangle border
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  DashedRectPainter({
    this.color = const Color(0xFFCBD5E1),
    this.strokeWidth = 1.2,
    this.dash = 5,
    this.gap = 4,
    this.radius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = (distance + dash < metric.length)
            ? dash
            : metric.length - distance;
        dashedPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dash != dash ||
      oldDelegate.gap != gap ||
      oldDelegate.radius != radius;
}
