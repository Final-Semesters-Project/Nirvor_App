import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nirbhor/utils/app_colors/app_colors.dart';
import 'package:nirbhor/view/components/custom_royel_appbar/custom_royel_appbar.dart';
import 'package:nirbhor/view/screens/Seeker/home_seeker/screen/home/home_seeker_screen.dart';
import 'package:nirbhor/view/screens/urgent_request_flow/controller/urgent_request_controller.dart';

class UrgentRequestFlowScreen extends StatefulWidget {
  const UrgentRequestFlowScreen({super.key});

  @override
  State<UrgentRequestFlowScreen> createState() => _UrgentRequestFlowScreenState();
}

class _UrgentRequestFlowScreenState extends State<UrgentRequestFlowScreen>
    with TickerProviderStateMixin {
  late final UrgentRequestController controller;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<UrgentRequestController>()
        ? Get.find<UrgentRequestController>()
        : Get.put(UrgentRequestController(), permanent: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: CustomRoyelAppbar(
          titleName: 'Urgent Request'.tr,
          leftIcon: true,
          centerTitleEnable: false,
          leftOnTap: () {
            Get.back();
          },
        ),
        body: Obx(() {
          switch (controller.flowState.value) {
            case UrgentFlowState.configuring:
              return _buildConfiguringState();
            case UrgentFlowState.broadcasting:
              return _buildBroadcastingState();
            case UrgentFlowState.claimed:
              return _buildClaimedState();
            case UrgentFlowState.expired:
              return _buildExpiredState();
          }
        }),
      ),
    );
  }

  /// =========================================================================
  /// STATE 1: CONFIGURING (Category, Skill, Location & Send)
  /// =========================================================================
  Widget _buildConfiguringState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency Header Card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE53935).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '5 MINUTE URGENT ALERT'.tr,
                              style: const TextStyle(
                                color: Color(0xFFE53935),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Need urgent help? Verified providers near you will be alerted immediately.'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Step 1: Select Category
          _buildSectionLabel('1. ${'Select Category'.tr}', Icons.grid_view_rounded),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.isLoadingCategories.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            if (controller.categories.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Text('No categories available'.tr),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: controller.selectedCategory.value?.id,
                  hint: Text('Please choose a category'.tr),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  items: controller.categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (catId) {
                    if (catId != null) {
                      final match = controller.categories
                          .firstWhereOrNull((c) => c.id == catId);
                      if (match != null) {
                        controller.selectCategory(match);
                      }
                    }
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 18),

          // Step 2: Select Skill
          _buildSectionLabel('2. ${'Select Skill'.tr}', Icons.handyman_rounded),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.isLoadingSkills.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            if (controller.skills.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  'Please select a category first'.tr,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: controller.selectedSkill.value?.id,
                  hint: Text('Please choose a skill'.tr),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  items: controller.skills.map((skill) {
                    return DropdownMenuItem<int>(
                      value: skill.id,
                      child: Text(
                        skill.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (skillId) {
                    if (skillId != null) {
                      final match = controller.skills
                          .firstWhereOrNull((s) => s.id == skillId);
                      if (match != null) {
                        controller.selectSkill(match);
                      }
                    }
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 18),

          // Step 3: Location Mode (Current GPS vs Saved Home)
          _buildSectionLabel('3. ${'Service Location'.tr}', Icons.location_on_rounded),
          const SizedBox(height: 8),
          Obx(() {
            final isCurrent = controller.selectedLocationMode.value == 'current';
            final isHome = controller.selectedLocationMode.value == 'home';

            return Column(
              children: [
                // Current GPS Option
                InkWell(
                  onTap: () => controller.setLocationMode('current'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrent ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent ? Colors.blue.shade400 : Colors.grey.shade300,
                        width: isCurrent ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.my_location_rounded,
                          color: isCurrent ? Colors.blue.shade700 : Colors.grey,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current GPS Location'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isCurrent
                                      ? Colors.blue.shade900
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.currentLatitude.value != 0.0
                                    ? '${controller.currentLatitude.value.toStringAsFixed(4)}, ${controller.currentLongitude.value.toStringAsFixed(4)}'
                                    : 'GPS coordinates will be captured'.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrent)
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 18),
                            color: Colors.blue.shade700,
                            tooltip: 'Refresh Location',
                            onPressed: () => controller.detectCurrentLocation(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Saved Home Option
                InkWell(
                  onTap: () => controller.setLocationMode('home'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isHome ? Colors.teal.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isHome ? AppColors.primary : Colors.grey.shade300,
                        width: isHome ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.home_rounded,
                          color: isHome ? AppColors.primary : Colors.grey,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saved Home Address'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isHome ? AppColors.primary : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.homeAddress.value.isNotEmpty
                                    ? controller.homeAddress.value
                                    : 'No saved home address. Uses GPS by default.'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isHome)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Broadcast Action Button
          Obx(() {
            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.triggerUrgentBroadcast(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFFE53935).withValues(alpha: 0.4),
                ),
                child: controller.isSubmitting.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sending request...'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Request Urgent Help'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }),
          const SizedBox(height: 14),

          // Footnote
          Center(
            child: Text(
              'Expires in 5 minutes if no one claims. Alerts verified providers within 5-10 km.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// =========================================================================
  /// STATE 2: BROADCASTING (Radar Pulse & 5-minute Countdown)
  /// =========================================================================
  Widget _buildBroadcastingState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Radar pulse animation
            _buildRadarPulse(),
            const SizedBox(height: 24),

            // Live status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE53935).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Searching for nearby providers...'.tr,
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Countdown Timer Display
            Obx(() => Text(
                  controller.formattedTime,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.black87,
                  ),
                )),
            Text(
              'Time Remaining'.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Requested Skill details card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.handyman_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.selectedSkill.value?.name ?? 'Skill',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              controller.selectedCategory.value?.name ?? 'Category',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.effectiveAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Nearby providers with smartphones are receiving your request'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Radar Pulse animation widget
  Widget _buildRadarPulse() {
    return SizedBox(
      width: 180,
      height: 180,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Wave 3
              Container(
                width: 180 * _pulseAnimation.value,
                height: 180 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE53935).withValues(
                    alpha: (1.0 - _pulseAnimation.value) * 0.25,
                  ),
                ),
              ),
              // Wave 2
              Container(
                width: 130 * _pulseAnimation.value,
                height: 130 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF7043).withValues(
                    alpha: (1.0 - _pulseAnimation.value) * 0.35,
                  ),
                ),
              ),
              // Center circle
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE53935).withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// =========================================================================
  /// STATE 3: CLAIMED (Provider Accepted!)
  /// =========================================================================
  Widget _buildClaimedState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon with glow
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade400, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 54,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Provider Found!'.tr,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'has accepted your urgent request!'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),

            // Provider Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        child: Text(
                          controller.claimedByName.value.isNotEmpty
                              ? controller.claimedByName.value[0].toUpperCase()
                              : 'P',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                                  controller.claimedByName.value,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                )),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Claimed & Calling You Now'.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.phone_in_talk_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'The provider has received your phone number and address, and will call you immediately.'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.offAll(() => HomeSeekerScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Go to Home'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================================================================
  /// STATE 4: EXPIRED (5-minute Timeout)
  /// =========================================================================
  Widget _buildExpiredState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade300, width: 2),
              ),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                color: Colors.orange,
                size: 46,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'No Response Within 5 Minutes'.tr,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              'No nearby providers were available right now. You can try sending the request again or search manually on the map.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Retry Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => controller.retryBroadcast(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Try Again'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Manual Search Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Get.offAll(() => HomeSeekerScreen());
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Search Manually'.tr,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey.shade800),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade900,
          ),
        ),
      ],
    );
  }
}
