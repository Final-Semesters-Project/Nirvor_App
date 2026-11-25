import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../model/urgent_history_model.dart';
import '../../../../../utils/app_colors/app_colors.dart';
import '../../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../controller/provider_urgent_history_controller.dart';
import '../../urgent_alert/model/urgent_broadcast_model.dart';
import '../../urgent_alert/screen/provider_active_urgent_job_screen.dart';

class ProviderUrgentHistoryScreen extends StatelessWidget {
  const ProviderUrgentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProviderUrgentHistoryController>()
        ? Get.find<ProviderUrgentHistoryController>()
        : Get.put(ProviderUrgentHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomRoyelAppbar(
        titleName: 'Urgent Jobs History'.tr,
        leftIcon: true,
        centerTitleEnable: true,
      ),
      body: Column(
        children: [
          // Filter Bar
          _buildFilterBar(controller),

          // Broadcasts List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.broadcasts.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.broadcasts.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => controller.fetchBroadcasts(refresh: true),
                child: ListView.builder(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: controller.broadcasts.length +
                      (controller.hasNext.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.broadcasts.length) {
                      return controller.isLoadingMore.value
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    }

                    final item = controller.broadcasts[index];
                    return _buildBroadcastCard(context, controller, item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ProviderUrgentHistoryController controller) {
    final filters = [
      {'key': 'all', 'label': 'All'.tr},
      {'key': 'claimed', 'label': 'Claimed / Active'.tr},
      {'key': 'cancelled', 'label': 'Cancelled'.tr},
      {'key': 'expired', 'label': 'Expired'.tr},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Obx(
          () => Row(
            children: filters.map((f) {
              final isSelected = controller.selectedFilter.value == f['key'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    f['label']!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0F766E),
                  backgroundColor: const Color(0xFFF1F5F9),
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  onSelected: (_) => controller.changeFilter(f['key']!),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBroadcastCard(
    BuildContext context,
    ProviderUrgentHistoryController controller,
    ProviderUrgentBroadcastItemModel item,
  ) {
    Color statusBgColor;
    Color statusTextColor;
    String statusText;
    IconData statusIcon;

    if (item.isClaimed) {
      statusBgColor = const Color(0xFFDCFCE7);
      statusTextColor = const Color(0xFF15803D);
      statusText = 'Claimed / Active'.tr;
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (item.isCancelled) {
      statusBgColor = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFB91C1C);
      statusText = 'Cancelled'.tr;
      statusIcon = Icons.cancel_outlined;
    } else {
      statusBgColor = const Color(0xFFF1F5F9);
      statusTextColor = const Color(0xFF64748B);
      statusText = 'Expired'.tr;
      statusIcon = Icons.timer_off_outlined;
    }

    final dateFormatted =
        DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isClaimed
              ? const Color(0xFF0F766E).withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Skill Icon & Name + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.electric_bolt_rounded,
                  color: Color(0xFF0F766E),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.skillName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateFormatted,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 13, color: statusTextColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: statusTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Seeker Info
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seeker Name'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        item.seekerName.isNotEmpty
                            ? item.seekerName
                            : 'Seeker'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.seekerPhone != null && item.seekerPhone!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.phone_in_talk_rounded,
                        color: Color(0xFF16A34A)),
                    onPressed: () {
                      launchUrl(Uri.parse('tel:${item.seekerPhone}'));
                    },
                    tooltip: 'Call Seeker'.tr,
                  ),
              ],
            ),
          ),

          // Action buttons for Claimed job
          if (item.isClaimed) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final activeJob = ActiveUrgentJobModel(
                        broadcastId: item.broadcastId,
                        status: item.status,
                        seekerName: item.seekerName,
                        seekerPhone: item.seekerPhone ?? '',
                        skillName: item.skillName,
                        seekerLatitude: item.seekerLatitude ?? 0.0,
                        seekerLongitude: item.seekerLongitude ?? 0.0,
                        distanceKm: 0.0,
                        claimedAt: item.createdAt,
                      );
                      Get.to(() => ProviderActiveUrgentJobScreen(job: activeJob));
                    },
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 16),
                    label: Text(
                      'Open Active Job'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _confirmCancelDialog(context, controller, item),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cancel Job'.tr,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _confirmCancelDialog(
    BuildContext context,
    ProviderUrgentHistoryController controller,
    ProviderUrgentBroadcastItemModel item,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('Cancel Urgent Job?'.tr),
        content: Text(
          'Are you sure you want to cancel this urgent job? The seeker will be notified.'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelUrgentJob(item.broadcastId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Yes, Cancel'.tr,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No urgent jobs history found'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
