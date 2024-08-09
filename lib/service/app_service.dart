import 'package:alc_mobile_app/controller/api_controller.dart';
import 'package:alc_mobile_app/model/check_price_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppService extends GetxController {
  static AppService get to => Get.find();

  static AppService init({String? tag, bool permanent = false}) =>
      Get.put(AppService(), tag: tag, permanent: permanent);
      
  final _storage = GetStorage();
  static RxBool isShowProductImage = true.obs;

  bool get showImages => isShowProductImage.value;

  @override
  void onInit() {
    super.onInit();
    _loadImageSetting();
  }

  void _loadImageSetting() {
    isShowProductImage.value = _storage.read('showImages') ?? true;
  }

  void toggleImageSetting(bool value) {
    if (!value) {
      ApiController.productWithImage.value = CheckPriceResponse(art: '', dscr: '', price: '', image: []);
    }
    isShowProductImage.value = value;
    _storage.write('showImages', value);
  }
}