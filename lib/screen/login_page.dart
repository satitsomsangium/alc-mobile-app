import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isShowLogo = true;
  bool isLoading = false;
  double logoSize = 150;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
        isKeyboardVisible ? isShowLogo = false : isShowLogo = true;
        return Center(
          child: Column(
            children: [
              const Expanded(
                child: SizedBox(),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Visibility(
                      visible: isShowLogo,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/images/alcmobileiconV6.png',
                          width: logoSize,
                          height: logoSize,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                      child: Visibility(
                        visible: isLoading,
                        child: SizedBox(
                          width: 125,
                          height: 5,
                          child: Column(
                            children: [
                              const LinearProgressIndicator(),
                              Expanded(
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'กรุณาลงชื่อเข้าใช้',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'อีเมล',
                          contentPadding: const EdgeInsets.fromLTRB(15, 8, 15, 12),
                          isDense: true,
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(75),
                            borderSide: const BorderSide(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: const TextStyle(
                              fontWeight: FontWeight.w700, color: Colors.white60),
                        ),
                        controller: emailController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextField(
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          labelText: 'รหัสผ่าน',
                          contentPadding: const EdgeInsets.fromLTRB(15, 8, 15, 12),
                          isDense: true,
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(75),
                            borderSide: const BorderSide(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: const TextStyle(
                              fontWeight: FontWeight.w700, color: Colors.white60),
                        ),
                        controller: passwordController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 10, top: 5),
                      child: ButtonTheme(
                        minWidth: double.infinity,
                        child: ElevatedButton(
                          child: const Text('ลงชื่อเข้าใช้'),
                          onPressed: () => authController.signIn(emailController.text, passwordController.text),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox())
            ],
          ),
        );
      }),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(content, textAlign: TextAlign.center,),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const SizedBox(
                  width: 60,
                  child: Center(
                    child: Text(
                      'ตกลง',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}