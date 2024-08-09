import 'package:alc_mobile_app/component/alc_textfield.dart';
import 'package:alc_mobile_app/component/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alc_mobile_app/controller/auth_controller.dart';

class SetNicknamePage extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _nicknameController = TextEditingController();

  SetNicknamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('ตั้งชื่อเล่น')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AlcTextField(
                controller: _nicknameController,
                labelText: 'ชื่อเล่น',
              ),
              const SizedBox(height: 24),
              AlcMobileButton(
                text: 'บันทึก', 
                onPressed: () => _authController.setNickname(_nicknameController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}