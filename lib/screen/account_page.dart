import 'package:alc_mobile_app/component/appbar.dart';
import 'package:alc_mobile_app/component/button.dart';
import 'package:alc_mobile_app/component/alc_card.dart';
import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:alc_mobile_app/screen/about_page.dart';
import 'package:alc_mobile_app/screen/privacy_page.dart';
import 'package:alc_mobile_app/service/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AuthController authController = Get.find<AuthController>();
  
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
                Icons.mail_outlined, 
                const SizedBox(),
                () {}
              ),
              menuCard(
                'เปลี่ยนชื่อเล่น', 
                authController.nickname.value == '' ? 'ยังไม่ได้ตั้งชื่อเล่น' : authController.nickname.value, 
                Icons.account_circle_outlined, 
                const SizedBox(),
                () => authController.changeNicknameDialog()
              ),
              menuCard(
                'แสดงรูปภาพในหน้าเช็คราคา', 
                AppService.isShowProductImage.value ? 'เปิด' : 'ปิด', 
                Icons.photo_outlined,
                Switch(
                  value: AppService.to.showImages,
                  onChanged: (value) => AppService.to.toggleImageSetting(value),
                  activeColor: Colors.red,
                  activeTrackColor: Colors.red.withOpacity(0.5),
                  inactiveTrackColor: Colors.grey.withOpacity(0.5),
                ),
                () {
                  AppService.to.toggleImageSetting(!AppService.isShowProductImage.value);
                }
              ),
              menuCard(
                'ALC Mobile', 
                'แอปเวอร์ชัน ${authController.appVersion}',
                Padding(
                  padding: EdgeInsets.all(3.sp),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      'assets/images/ic_launcher.png',
                      width: 28.sp,
                      height: 28.sp,
                    ),
                  ),
                ),
                const SizedBox(),
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                }
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AlcMobileButton(
            text: 'ออกจากระบบ', 
            onPressed: () => authController.logout()
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

  Widget menuCard(String title, String subtitle, dynamic leading, Widget endWidget, VoidCallback ontap) {
    Widget leadingWidget;
    
    if (leading is IconData) {
      leadingWidget = Icon(
        leading,
        color: Colors.red,
        size: 55.sp,
      );
    } else if (leading is Image) {
      leadingWidget = leading;
    } else {
      leadingWidget = leading;
    }

    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.sp),
        child: AlcCard(
          child: SizedBox(
            height: 55.sp,
            child: Row(
              children: [
                SizedBox(
                  width: 50.sp,
                  height: 50.sp,
                  child: leadingWidget,
                ),
                SizedBox(width: 10.sp),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(subtitle),
                  ],
                ),
                const Expanded(child: SizedBox()),
                endWidget
              ],
            ),
          ),
        ),
      ),
    );
  }
}