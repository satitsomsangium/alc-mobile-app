import 'package:alc_mobile_app/controller/db_controller.dart';
import 'package:alc_mobile_app/model/bay_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class FlowController extends GetxController {
  static FlowController get to => Get.find();

  static FlowController init({String? tag, bool permanent = false}) =>
      Get.put(FlowController(), tag: tag, permanent: permanent);

  FirebaseDatabase database = FirebaseDatabase.instance;


  static var bayStatus = Rx<BayStatus?>(null);
  static RxList<BayData> bayDataList = <BayData>[].obs;

  static Future<void> fetchBayStatus(String aisle, String bay, String div) async {
    BayStatus? status = await DbController.getBayStatus(aisle, bay, div);
    bayStatus.value = status;
  }

  static Future<void> changeBayStatus(String aisle, String bay, String div, BayStatus status) async {
    await DbController.changeBayStatus(aisle, bay, div, status);
    bayStatus.value = status;
  }

  static Future<void> getBayDataList(String aisle, String bay, String div) async {
    List<BayData> bayList = await DbController.getBayDataList(aisle, bay, div);
    bayDataList.value = bayList;
  }
}