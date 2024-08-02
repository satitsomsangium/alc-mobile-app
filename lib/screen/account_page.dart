import 'package:alc_mobile_app/component/appbar.dart';
import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:alc_mobile_app/screen/about_page.dart';
import 'package:alc_mobile_app/screen/privacy_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AuthController authController = Get.find();
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: const MyAppBar(
        title: 'จัดการบัญชี', 
        popupMenu: SizedBox.shrink(), 
        color1: Color(0xFF21E8AC),
        color2: Color(0xFF376DF6)
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              menuCard(
                'อีเมล', 
                '${authController.user.value?.email}', 
                Icons.email, 
                () {}
              ),
              menuCard(
                'เปลี่ยนชื่อเล่น', 
                authController.nickname.value, 
                Icons.change_circle_outlined, 
                () => authController.changeNickname()
              ),
              menuCard(
                'ALC Mobile', 
                'แอปเวอร์ชัน ${authController.appVersion}', 
                Image.asset('assets/images/android-icon-72x72.png'), 
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                }
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(75),
                        side: const BorderSide(color: Colors.red)))),
            onPressed: () => authController.signOut(),
            child: const Text(
              'ออกจากระบบ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PrivacyPage()));
            },
            child: const Text(
              'นโยบายความเป็นส่วนตัว',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    ));
  }

  Widget menuCard(String title, String subtitle, dynamic leading, VoidCallback ontap) {
    Widget leadingWidget;
    
    if (leading is IconData) {
      leadingWidget = Icon(
        leading,
        color: Colors.red,
        size: 55,
      );
    } else if (leading is Image) {
      leadingWidget = leading;
    } else {
      throw ArgumentError('leading must be either IconData or Image');
    }

    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 55,
              child: leadingWidget,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}