import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../model/urgent_history_model.dart';
import '../../../../../utils/app_colors/app_colors.dart';
import '../../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../controller/seeker_urgent_history_controller.dart';

class SeekerUrgentHistoryScreen extends StatelessWidget {
  const SeekerUrgentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<SeekerUrgentHistoryController>()
        ? Get.find<SeekerUrgentHistoryController>()
        : Get.put(SeekerUrgentHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomRoyelAppbar(
        titleName: 'Urgent Requests History'.tr,
        leftIcon: true,
        centerTitleEnable: true,
      ),
      body: Column(
        children: [
          // Filter Tabs
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

  Widget _buildFilterBar(SeekerUrgentHistoryController controller) {
    final filters = [
      {'key': 'all', 'label': 'All'.tr},
      {'key': 'active', 'label': 'Active'.tr},
      {'key': 'claimed', 'label': 'Claimed'.tr},
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
                  selectedColor: AppColors.primary,
                  backgroundColor: const Color(0xFFF1F5F9),
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
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
    SeekerUrgentHistoryController controller,
    SeekerUrgentBroadcastItemModel item,
  ) {
    Color statusBgColor;
    Color statusTextColor;
    String statusText;
    IconData statusIcon;

    if (item.isBroadcasting) {
      statusBgColor = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFB45309);
      statusText = 'Broadcasting'.tr;
      statusIcon = Icons.radar_rounded;
    } else if (item.isClaimed) {
      statusBgColor = const Color(0xFFDCFCE7);
      statusTextColor = const Color(0xFF15803D);
      statusText = 'Claimed'.tr;
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
              ? AppColors.primary.withValues(alpha: 0.3)
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
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.primary,
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

          // Provider Info if claimed
          if (item.isClaimed && item.providerName != null) ...[
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
                    Icons.person_pin_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assigned Provider'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          item.providerName!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.providerPhone != null &&
                      item.providerPhone!.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.phone_in_talk_rounded,
                          color: Color(0xFF16A34A)),
                      onPressed: () {
                        launchUrl(Uri.parse('tel:${item.providerPhone}'));
                      },
                      tooltip: 'Call Provider'.tr,
                    ),
                ],
              ),
            ),
          ],

          // Cancel button if broadcasting
          if (item.isBroadcasting) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton.icon(
                onPressed: () => _confirmCancelDialog(context, controller, item),
                icon: const Icon(Icons.close_rounded,
                    color: Colors.redAccent, size: 16),
                label: Text(
                  'Cancel Request'.tr,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmCancelDialog(
    BuildContext context,
    SeekerUrgentHistoryController controller,
    SeekerUrgentBroadcastItemModel item,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('Cancel Request?'.tr),
        content: Text('Are you sure you want to cancel this urgent broadcast?'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelBroadcast(item.broadcastId);
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
            'No urgent requests found'.tr,
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
