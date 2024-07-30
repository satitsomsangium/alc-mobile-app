import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class FlowController extends GetxController {
  static FlowController get to => Get.find();

  static FlowController init({String? tag, bool permanent = false}) =>
      Get.put(FlowController(), tag: tag, permanent: permanent);

  FirebaseDatabase database = FirebaseDatabase.instance;


  /* Future<bool> isAlcStaff() async {
    
  } */
}