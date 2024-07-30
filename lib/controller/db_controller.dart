import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class DbController extends GetxController {
  static DbController get to => Get.find();

  static DbController init({String? tag, bool permanent = false}) =>
      Get.put(DbController(), tag: tag, permanent: permanent);

  FirebaseDatabase database = FirebaseDatabase.instance;

  /* Future<String> getPriceDateModify(String article) async {
    DatabaseReference ref = database.ref().child("1").child('datemodified');
    DataSnapshot snapshot = await ref.get();
  } */

}