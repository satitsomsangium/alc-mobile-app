import 'package:alc_mobile_app/model/product_data_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class FirebaseController extends GetxController {
  static FirebaseController get to => Get.find();

  static FirebaseController init({String? tag, bool permanent = false}) =>
      Get.put(FirebaseController(), tag: tag, permanent: permanent);

  static final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;

  static RxString productDateModify = ''.obs;

  static Rx<Product> product = Product(art: 'XXXXXX', dscr: 'xxxxxxxx', price: 'XXX').obs;

  static Future<Product?> getProduct(String article) async {
    final DataSnapshot snapshot = await firebaseDatabase.ref().child('0').child(article).child('0').get();
    if (snapshot.exists && snapshot.value != null) {
      var data = Map<String, dynamic>.from(snapshot.value as Map);
      product.value = Product(
        art: data['art'].toString(),
        dscr: data['dscr'].toString(),
        price: data['price'].toStringAsFixed(2)
      );
      return product.value;
    } else {
      product.value = Product(art: 'XXXXXX', dscr: 'xxxxxxxx', price: 'XXX');
    }
    return null;
  }

  static Future<void> getDateModify() async {
    final DataSnapshot snapshot = await firebaseDatabase.ref().child('1').child('datemodified').get();
    if (snapshot.exists && snapshot.value != null) {
      productDateModify.value = snapshot.value.toString();
    } else {
      productDateModify.value = '';
    }
  }
}