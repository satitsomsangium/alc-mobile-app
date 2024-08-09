import 'package:alc_mobile_app/component/alc_card.dart';
import 'package:alc_mobile_app/component/alc_textfield.dart';
import 'package:alc_mobile_app/component/button.dart';
import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isShowLogo = true;
  bool isLoading = false;
  double logoSize = 150;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
          isKeyboardVisible ? isShowLogo = false : isShowLogo = true;
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.sp),
              child: Column(
                children: [
                  const Expanded(child: SizedBox()),
                  Visibility(
                    visible: isShowLogo,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.sp),
                      child: Image.asset(
                        'assets/images/ic_launcher.png',
                        width: logoSize,
                        height: logoSize,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.sp),
                  AlcTextField(
                    controller: emailController,
                    labelText: 'อีเมล',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 32.sp),
                  AlcTextField(
                    controller: passwordController,
                    labelText: 'รหัสผ่าน',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 32.sp),
                  AlcMobileButton(
                    text: 'ลงชื่อเข้าใช้',
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      await _authController.login(emailController.text, passwordController.text);
                    },
                  ),
                  const Expanded(child: SizedBox())
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}