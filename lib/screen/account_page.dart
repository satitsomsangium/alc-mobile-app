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
  String offlineDBversion = '';
  String tick = '';

  /* var curday = DateTime.now();
  var curd = DateTime.now().day;
  var curm = DateTime.now().month;
  var cury = DateTime.now().year; */

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

    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(subtitle),
        leading: leadingWidget,
        onTap: ontap,
      ),
    );
  }

  Future<String> getversion() async {
    int databaseversion = /* await ManageDB().databaseversion(); */1111;
    offlineDBversion = 'เวอร์ชัน $databaseversion';
    return 'เวอร์ชัน $databaseversion';
  }

  @override
  void initState() {
    super.initState();
    getversion();
  }
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: const MyAppBar(
        title: 'จัดการบัญชี', 
        popupMenu: SizedBox.shrink(), 
        color1: Color(0xFF21E8AC),
        color2: Color(0xFF376DF6)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(7),
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
                'อัปเดตฐานข้อมูลออฟไลน์', 
                offlineDBversion,
                Icons.save_alt_outlined, 
                /* updatedatabase */() {}),
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

  /* Future<void> updatedatabase() async {
    _showLoadingDialog('เช็คเวอร์ชัน');

    int offlinedatabaseversion = await ManageDB().databaseversion();
    final snapshot = await fb.ref().child('Stockcount').child('3').child('0').child('databaseversion').get();

    if (snapshot.value != null) {
      int databaseversion = snapshot.value;
      if (databaseversion > offlinedatabaseversion) {
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);

        _showLoadingDialog('กรุณารอสักครู่');

        print('Offline database version : $offlinedatabaseversion');
        print('Must Update');
        await ManageDB().deleteStore('DataMain');
        await ManageDB().deleteStore('DataMutation');
        await ManageDB().deleteStore('DataMainBarcode');
        await ManageDB().getfirebase();
        await ManageDB().getfirebaseBarcode();
        await ManageDB().getMutationfirebase();
        await Future.delayed(const Duration(seconds: 25));
        Navigator.pop(context);
        _showAlertDialog('อัปเดตฐานข้อมูลออฟไลน์', 'ฐานข้อมูลออฟไลน์เป็นเวอร์ชันล่าสุดแล้ว');
      } else {
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
        _showAlertDialog('อัปเดตฐานข้อมูลออฟไลน์', 'ฐานข้อมูลยังไม่มีเวอร์ชันใหม่');
      }
    }
  } */

  void _showLoadingDialog(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  Future<String> getpercentage() async {
    /* String data = await ManageJson().updateItemlookup();
    setState(() {
      tick = data;
    });
    return data; */ return '10';
  }

  Future<void> loadtodatabase(BuildContext context) async {
    bool running = true;
    Stream<String> mystream() async* {
      getpercentage();
      while (running) {
        yield tick;
      }
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<String>(
          stream: mystream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return AlertDialog(
              content: Container(
                width: 150,
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      snapshot.data ?? '',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}