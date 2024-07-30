import 'package:get/get.dart';

class AppService extends GetxService {
  static AppService get to => Get.find();

  static AppService init({String? tag, bool permanent = false}) =>
      Get.put(AppService(), tag: tag, permanent: permanent);

  RxString nickName = ''.obs;

  clear() {
    nickName.value = '';
  }
}