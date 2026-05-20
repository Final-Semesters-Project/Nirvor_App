import 'package:get/get.dart';
class DependencyInjection extends Bindings {
  @override
  void dependencies() {
    ///========================== Default Custom Controller ==================

     //Get.lazyPut(() => AuthController(), fenix: true);
    // Get.lazyPut(() => ProfileController(), fenix: true);
    // Get.lazyPut(() => SocialController(), fenix: true);
    // Get.lazyPut(() => HomeController(), fenix: true);
    // ///========================== Event Part Controller ==================
    // Get.lazyPut(() => EventService(), fenix: true);
    // Get.lazyPut(() => EventController(), fenix: true);
    //
    // ///========================== DM Part Controller ==================
    // Get.lazyPut(() => DmSocialController(), fenix: true);
  }
}