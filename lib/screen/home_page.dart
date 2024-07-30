import 'package:alc_mobile_app/component/bottom_navigation.dart';
import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  final int page;
  HomePage({super.key, required this.page });

  final AuthController authController = Get.find();
  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'กดกลับอีกครั้งเพื่อออกจากแอป');
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (authController.user.value == null) {
        return const Center(child: CircularProgressIndicator());
      } else {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: onWillPop,
          child: Bottomnavigation(page),
        );
      }
    });
  }
}

