import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../model/urgent_history_model.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../../../../../utils/ToastMsg/toast_message.dart' show showCustomSnackBar;

class SeekerUrgentHistoryController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var broadcasts = <SeekerUrgentBroadcastItemModel>[].obs;

  var selectedFilter = 'all'.obs; // 'all', 'broadcasting', 'claimed', 'cancelled', 'expired'
  var activeOnly = false.obs;

  int currentPage = 1;
  final int pageSize = 10;
  var hasNext = false.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchBroadcasts(refresh: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        hasNext.value) {
      fetchBroadcasts(refresh: false);
    }
  }

  void changeFilter(String filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    fetchBroadcasts(refresh: true);
  }

  Future<void> fetchBroadcasts({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      hasNext.value = false;
      isLoading.value = true;
    } else {
      if (isLoadingMore.value || !hasNext.value) return;
      isLoadingMore.value = true;
    }

    try {
      String? statusParam;
      bool activeOnlyParam = false;

      if (selectedFilter.value == 'active') {
        activeOnlyParam = true;
      } else if (selectedFilter.value != 'all') {
        statusParam = selectedFilter.value;
      }

      final url = ApiUrl.seekerUrgentBroadcasts(
        page: currentPage,
        pageSize: pageSize,
        status: statusParam,
        activeOnly: activeOnlyParam,
      );

      final response = await ApiClient.getData(url);

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        final List<dynamic> itemsJson = body['items'] is List ? body['items'] : [];

        final List<SeekerUrgentBroadcastItemModel> fetched = itemsJson
            .map((item) => SeekerUrgentBroadcastItemModel.fromJson(
                item is Map<String, dynamic>
                    ? item
                    : Map<String, dynamic>.from(item as Map)))
            .toList();

        if (refresh) {
          broadcasts.assignAll(fetched);
        } else {
          broadcasts.addAll(fetched);
        }

        hasNext.value = body['has_next'] ?? false;
        if (hasNext.value) {
          currentPage++;
        }
      }
    } catch (e) {
      debugPrint("Error fetching seeker urgent broadcasts: $e");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> cancelBroadcast(String broadcastId) async {
    final bool isBn = Get.locale?.languageCode == 'bn';
    try {
      final response = await ApiClient.patchData(
        ApiUrl.cancelUrgentBroadcast(broadcastId),
        {},
      );

      if (response.statusCode == 200) {
        showCustomSnackBar(
          isBn
              ? 'জরুরি অনুরোধটি বাতিল করা হয়েছে।'
              : 'Urgent request cancelled.',
          isError: false,
        );
        fetchBroadcasts(refresh: true);
      } else {
        final msg = response.body is Map && response.body['detail'] != null
            ? response.body['detail'].toString()
            : (isBn ? 'বাতিল করা সম্ভব হয়নি।' : 'Failed to cancel.');
        showCustomSnackBar(msg, isError: true);
      }
    } catch (e) {
      showCustomSnackBar('Network error occurred.', isError: true);
    }
  }
}
