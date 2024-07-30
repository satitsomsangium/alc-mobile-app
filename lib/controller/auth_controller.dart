import 'package:alc_mobile_app/screen/home_page.dart';
import 'package:alc_mobile_app/screen/login_page.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:package_info/package_info.dart';

class AuthController extends GetxController {
      
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;
  var isSignedIn = false.obs;
  var user = Rxn<User>();
  var deviceId = ''.obs;
  var nickname = ''.obs;
  var appVersion = 'Unknown'.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(auth.authStateChanges());
    ever(user, _setInitialScreen);
    _initPackageInfo();
  }

  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const LoginPage());
    } else {
      isSignedIn.value = true;
      _getDeviceId();
      Get.offAll(() => HomePage(page: 0));
    }
  }

  void clearAuth() {
    user.value = null;
    isSignedIn.value = false;
    nickname.value = '';
    deviceId.value = '';
  }

  Future<void> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showDialog('อีเมลหรือรหัสผ่านไม่ถูกต้อง', 'อีเมลและรหัสผ่านต้องไม่เว้นว่าง');
      return;
    }
    if (!email.endsWith('@siammakro.co.th')) {
      _showDialog('รูปแบบอีเมลไม่ถูกต้อง', 'อีเมลต้องมี @siammakro.co.th ต่อท้ายเสมอ');
      return;
    }
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _showDialog('อีเมลหรือรหัสผ่านไม่ถูกต้อง', 'กรุณาลองใหม่อีกครั้ง');
    }
  }

  Future<void> signOut() async {
    await auth.signOut().then((_) {
      clearAuth();
    });
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  Future<void> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceId.value = androidInfo.androidId;
    _checkNickname();
  }

  void _checkNickname() async {
    DatabaseReference ref = database.ref().child('devices').child(deviceId.value);
    DataSnapshot snapshot = await ref.get();
    if (snapshot.exists && snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      nickname.value = data['nickname'] ?? '';
    } else {
      _showNicknameDialog();
    }
  }

  void _showNicknameDialog() {
    TextEditingController nicknameController = TextEditingController();
    RxString errorMessage = ''.obs;
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('กรอกชื่อเล่น'),
          content: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'ชื่อเล่น',
                  contentPadding: const EdgeInsets.fromLTRB(15, 8, 15, 12),
                  isDense: true,
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(75),
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey[800]!,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white60),
                  errorText: errorMessage.value.isEmpty ? null : errorMessage.value,
                  errorStyle: const TextStyle(color: Colors.red),
                  errorMaxLines: 5,
                ),
                controller: nicknameController,
              ),
            ],
          )),
          actions: [
            /* TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                nicknameController.text = '';
                Navigator.pop(context);
              },
            ), */
            TextButton(
              child: const Text('บันทึก'),
              onPressed: () {
                _validateAndSetNickname(nicknameController.text, errorMessage);
              },
            ),
          ],
        );
      },
    );
  }

  void _validateAndSetNickname(String nickname, RxString errorMessage) {
    if (nickname.isEmpty) {
      errorMessage.value = 'ชื่อเล่นต้องมีอย่างน้อย 1 ตัวอักษร';
    } else if (nickname.contains(RegExp(r'[\[\]\{\}," ]'))) {
      errorMessage.value = 'ชื่อเล่นต้องไม่มีตัวอักษร "[", "]", "{", "}", ",", " " และช่องว่าง';
    } else {
      _setNickname(nickname);
      Get.back();
    }
  }

  Future<bool> isNicknameDuplicate(String newNickname) async {
    DataSnapshot snapshot = await database.ref().child('devices').get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> devices = snapshot.value as Map<dynamic, dynamic>;
      for (var device in devices.values) {
        if (device['nickname'] == newNickname) {
          return true; // พบ nickname ซ้ำ
        }
      }
    }
    return false; // ไม่พบ nickname ซ้ำ
  }

  void _setNickname(String newNickname) async {
    bool isDuplicate = await isNicknameDuplicate(newNickname);
    if (!isDuplicate) {
      nickname.value = newNickname;
      database.ref().child('devices').child(deviceId.value).set({
        'nickname': nickname.value,
      });
    } else {
      await showDialog(
        context: Get.context!, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('เกิดข้อผิดพลาด')),
            content: const Text('ไม่สามารถตั้งชื่อนี้ได้\nเนื่องจากมีชื่อนี้อยู่แล้ว', textAlign: TextAlign.center,),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () => Get.back(), 
                  child: const Text('ตกลง'),
                ),
              )
            ],
          );
        }
      );
    }
  }

  void changeNickname() {
    TextEditingController nicknameController = TextEditingController();
    RxString errorMessage = ''.obs;
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เปลี่ยนชื่อเล่น'),
          content: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'ชื่อเล่นใหม่',
                  contentPadding: const EdgeInsets.fromLTRB(15, 8, 15, 12),
                  isDense: true,
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(75),
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey[800]!,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white60),
                  errorText: errorMessage.value.isEmpty ? null : errorMessage.value,
                  errorStyle: const TextStyle(color: Colors.red),
                  errorMaxLines: 5
                ),
                controller: nicknameController,
              ),
            ],
          )),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                nicknameController.text = '';
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('บันทึก'),
              onPressed: () {
                savechangename(nicknameController.text, errorMessage);
              },
            ),
          ],
        );
      },
    );
  }

  void savechangename(String nickname, RxString errorMessage) {
    if (nickname.isEmpty) {
      errorMessage.value = 'ชื่อเล่นต้องมีอย่างน้อย 1 ตัวอักษร';
    } else if (nickname.contains(RegExp(r'[\[\]\{\}," ]'))) {
      errorMessage.value = 'ชื่อเล่นต้องไม่มีตัวอักษร "[", "]", "{", "}", ",", " " และช่องว่าง';
    } else {
      _setNickname(nickname);
      Get.back();
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: Get.context!,
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