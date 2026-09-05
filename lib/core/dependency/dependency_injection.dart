import 'package:get/get.dart';
import 'package:nirbhor/view/screens/Seeker/home_seeker/controller/home_seeker_controller.dart';
import 'package:nirbhor/view/screens/Seeker/seeker_profile/controller/seeker_profile_controller.dart';
import '../../view/screens/auth_screen/controller/auth_controller.dart';

class DependencyInjection extends Bindings {
  @override
  void dependencies() {
    ///========================== Default Custom Controller ==================

    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => HomeSeekerController(), fenix: true);
    Get.lazyPut(() => SeekerProfileController(), fenix: true);
 
    // ///========================== DM Part Controller ==================
    // Get.lazyPut(() => DmSocialController(), fenix: true);
  }
}
