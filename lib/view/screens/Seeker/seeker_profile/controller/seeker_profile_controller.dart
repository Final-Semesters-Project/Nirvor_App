import 'package:get/get.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../model/user_model.dart';

class SeekerProfileController extends GetxController {
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
}
