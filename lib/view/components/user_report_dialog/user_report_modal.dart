import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../service/api_check.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../utils/ToastMsg/toast_message.dart';
import '../../screens/Seeker/seeker_bookings/controller/seeker_bookings_controller.dart';
import '../../screens/Provider/provider_bookings/controller/provider_bookings_controller.dart';

class UserReportModal {
  static Future<void> show({
    required BuildContext context,
    required String bookingId,
    required String reportedUserId,
    required String reportedUserName,
    required bool isReportingProvider,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UserReportBottomSheet(
        bookingId: bookingId,
        reportedUserId: reportedUserId,
        reportedUserName: reportedUserName,
        isReportingProvider: isReportingProvider,
      ),
    );
  }
}

class _UserReportBottomSheet extends StatefulWidget {
  final String bookingId;
  final String reportedUserId;
  final String reportedUserName;
  final bool isReportingProvider;

  const _UserReportBottomSheet({
    required this.bookingId,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.isReportingProvider,
  });

  @override
  State<_UserReportBottomSheet> createState() => _UserReportBottomSheetState();
}

class _UserReportBottomSheetState extends State<_UserReportBottomSheet> {
  final TextEditingController _detailsController = TextEditingController();
  String? _selectedReasonPreset;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getPresets(bool isBn) {
    if (widget.isReportingProvider) {
      return [
        {
          'key': 'Unprofessional behavior',
          'label': isBn ? 'অপেশাদার আচরণ' : 'Unprofessional behavior',
        },
        {
          'key': 'Demanded extra payment',
          'label': isBn ? 'অতিরিক্ত টাকা দাবি' : 'Demanded extra payment',
        },
        {
          'key': 'Poor work quality',
          'label': isBn ? 'কাজের অত্যন্ত নিম্নমান' : 'Poor work quality',
        },
        {
          'key': 'Did not show up on time',
          'label': isBn ? 'সময়ে উপস্থিত হয়নি' : 'Did not show up on time',
        },
        {
          'key': 'Safety or harassment concern',
          'label': isBn ? 'নিরাপত্তা বা হয়রানি' : 'Safety or harassment concern',
        },
        {
          'key': 'Other',
          'label': isBn ? 'অন্যান্য কারণ' : 'Other reason',
        },
      ];
    } else {
      return [
        {
          'key': 'Payment refusal or dispute',
          'label': isBn ? 'পেমেন্ট দিতে অস্বীকৃতি' : 'Payment refusal or dispute',
        },
        {
          'key': 'Abusive language or behavior',
          'label': isBn ? 'খারাপ ব্যবহার / গালিগালাজ' : 'Abusive language / behavior',
        },
        {
          'key': 'Misleading job requirements',
          'label': isBn ? 'কাজের বিবরণ অসত্য ছিল' : 'Misleading job requirements',
        },
        {
          'key': 'Safety or harassment concern',
          'label': isBn ? 'নিরাপত্তাজনিত উদ্বেগ' : 'Safety or harassment concern',
        },
        {
          'key': 'Other',
          'label': isBn ? 'অন্যান্য কারণ' : 'Other reason',
        },
      ];
    }
  }

  Future<void> _submitReport(bool isBn) async {
    final customDetails = _detailsController.text.trim();
    final presets = _getPresets(isBn);

    String finalReason = '';
    if (_selectedReasonPreset != null && _selectedReasonPreset!.isNotEmpty) {
      final selectedItem = presets.firstWhere(
        (p) => p['key'] == _selectedReasonPreset,
        orElse: () => {'key': _selectedReasonPreset!, 'label': _selectedReasonPreset!},
      );
      final String presetText = isBn ? (selectedItem['label'] ?? _selectedReasonPreset!) : (selectedItem['key'] ?? _selectedReasonPreset!);
      if (customDetails.isNotEmpty) {
        finalReason = "$presetText: $customDetails";
      } else {
        finalReason = presetText;
      }
    } else {
      finalReason = customDetails;
    }

    if (finalReason.trim().isEmpty) {
      showCustomSnackBar(
        isBn
            ? 'অনুগ্রহ করে রিপোর্টের একটি কারণ নির্বাচন করুন অথবা লিখুন'
            : 'Please select or describe a reason for the report',
        isError: true,
      );
      return;
    }

    if (finalReason.trim().length < 5) {
      showCustomSnackBar(
        isBn
            ? 'রিপোর্টের কারণ কমপক্ষে ৫ অক্ষরের হতে হবে'
            : 'Reason must be at least 5 characters',
        isError: true,
      );
      return;
    }

    String targetUserId = widget.reportedUserId.trim();

    // 1. In-memory check from controllers
    if (targetUserId.isEmpty && widget.bookingId.isNotEmpty) {
      if (Get.isRegistered<SeekerBookingsController>()) {
        final sc = Get.find<SeekerBookingsController>();
        final b = sc.bookings.firstWhereOrNull((item) => item.bookingId == widget.bookingId);
        if (b != null) {
          targetUserId = (b.providerId?.isNotEmpty == true
                  ? b.providerId!
                  : (b.otherPartyId?.isNotEmpty == true ? b.otherPartyId! : ''))
              .trim();
        }
      }
      if (targetUserId.isEmpty && Get.isRegistered<ProviderBookingsController>()) {
        final pc = Get.find<ProviderBookingsController>();
        final b = pc.completedBookings.firstWhereOrNull((item) => item.bookingId == widget.bookingId) ??
            pc.activeBookings.firstWhereOrNull((item) => item.bookingId == widget.bookingId);
        if (b != null) {
          targetUserId = (b.seekerId?.isNotEmpty == true
                  ? b.seekerId!
                  : (b.otherPartyId?.isNotEmpty == true ? b.otherPartyId! : ''))
              .trim();
        }
      }
    }

    // 2. Fetch booking detail endpoint if targetUserId still not resolved (as backend updates it)
    if (targetUserId.isEmpty && widget.bookingId.isNotEmpty) {
      setState(() => _isSubmitting = true);
      try {
        final res = await ApiClient.getData(ApiUrl.singleBookingDetail(widget.bookingId));
        if (res.statusCode == 200 && res.body != null) {
          final data = res.body is Map ? res.body : Map<String, dynamic>.from(res.body);
          targetUserId = (widget.isReportingProvider
                  ? (data['provider_id'] ?? data['other_party_id'])
                  : (data['seeker_id'] ?? data['other_party_id']))
              ?.toString() ??
              data['other_party_id']?.toString() ??
              data['provider_id']?.toString() ??
              data['user_id']?.toString() ??
              '';
        }
      } catch (e) {
        debugPrint("Error fetching booking detail for user ID: $e");
      }
    }

    if (targetUserId.isEmpty) {
      if (mounted) setState(() => _isSubmitting = false);
      showCustomSnackBar(
        isBn
            ? 'ব্যবহারকারীর আইডি পাওয়া যায়নি। ব্যাকএন্ডে বুকিং এ ইউজার আইডি যুক্ত হলে রিপোর্ট করা যাবে।'
            : 'Reported user ID not found. Backend update on booking is required.',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final body = {
        "reported_user_id": targetUserId,
        "booking_id": widget.bookingId,
        "reason": finalReason.trim(),
      };

      debugPrint("====> Calling POST ${ApiUrl.userReports} with: $body");
      final response = await ApiClient.postData(ApiUrl.userReports, body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        showCustomSnackBar(
          isBn
              ? 'রিপোর্ট সফলভাবে জমা দেওয়া হয়েছে। আমাদের টিম পর্যালোচনা করবে।'
              : 'Report submitted successfully. Our team will review it.',
          isError: false,
        );
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint("Error submitting user report: $e");
      showCustomSnackBar(
        isBn ? 'রিপোর্ট জমা দিতে ব্যর্থ হয়েছে' : 'Failed to submit report',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = Get.locale?.languageCode == 'bn';
    final presets = _getPresets(isBn);

    final title = widget.isReportingProvider
        ? (isBn ? 'প্রোভাইডারকে রিপোর্ট করুন' : 'Report Provider')
        : (isBn ? 'গ্রাহককে রিপোর্ট করুন' : 'Report Seeker');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row (Icon + Title + Close)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.report_problem_rounded,
                    color: Colors.red.shade700,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (widget.reportedUserName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          isBn
                              ? 'ব্যবহারকারী: ${widget.reportedUserName}'
                              : 'User: ${widget.reportedUserName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  splashRadius: 20,
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Subtitle
            Text(
              isBn
                  ? 'কী সমস্যা হয়েছিল তা নির্বাচন করুন অথবা বিস্তারিত লিখুন:'
                  : 'Select what went wrong or describe the issue:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 10),

            // Preset Reason Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((item) {
                final bool isSelected = _selectedReasonPreset == item['key'];
                return ChoiceChip(
                  label: Text(item['label'] ?? ''),
                  selected: isSelected,
                  selectedColor: Colors.red.shade50,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.red.shade800 : Colors.grey.shade800,
                  ),
                  side: BorderSide(
                    color: isSelected ? Colors.red.shade400 : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedReasonPreset = selected ? item['key'] : null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Detailed input field
            Text(
              isBn ? 'বিস্তারিত কারণ (অপশনাল):' : 'Additional Details (Optional):',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _detailsController,
              maxLines: 4,
              minLines: 3,
              style: const TextStyle(fontSize: 13.5),
              decoration: InputDecoration(
                hintText: isBn
                    ? 'সমস্যার বিস্তারিত বিবরণ এখানে লিখুন...'
                    : 'Describe what happened in detail here...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
                ),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
              ),
            ),

            const SizedBox(height: 12),

            // Trust note
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isBn
                        ? 'আপনার রিপোর্টটি আমাদের মডারেশন টিম সতর্কতার সাথে খতিয়ে দেখবে এবং প্ল্যাটফর্মের নীতিমালা রক্ষায় প্রয়োজনীয় পদক্ষেপ নেবে।'
                        : 'Your report will be reviewed by our moderation team to ensure safety and quality standards on Nirbhor.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isBn ? 'বাতিল' : 'Cancel',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitReport(isBn),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.red.shade300,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.flag_rounded, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                isBn ? 'রিপোর্ট জমা দিন' : 'Submit Report',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
