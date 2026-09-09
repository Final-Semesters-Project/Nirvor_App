import 'package:get/get.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../../../Seeker/seeker_profile/model/user_model.dart';

class ProviderProfileController extends GetxController {
  var user = Rxn<UserModel>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getUserProfile();
  }

  Future<void> getUserProfile() async {
    isLoading.value = true;
    final response = await ApiClient.getData(ApiUrl.userProfile);
    isLoading.value = false;
    
    if (response.statusCode == 200) {
      user.value = UserModel.fromJson(response.body);
    }
  }

  // Placeholder for missing update API
  Future<void> updateProfile({required String name}) async {
    if (user.value != null) {
      user.value = UserModel(
        userId: user.value!.userId,
        role: user.value!.role,
        phone: user.value!.phone,
        name: name,
        isActive: user.value!.isActive,
        createdAt: user.value!.createdAt,
        photoUrl: user.value!.photoUrl,
      );
      update();
    }
  }
}
