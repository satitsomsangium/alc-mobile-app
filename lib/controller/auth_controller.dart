/* import 'dart:async';
import 'dart:io';

import 'package:alc_mobile_app/component/button.dart';
import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:alc_mobile_app/controller/signage_controller.dart';
import 'package:alc_mobile_app/service/firebase_cloud_messaging_service.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  static AuthController init({String? tag, bool permanent = false}) =>
      Get.put(AuthController(), tag: tag, permanent: permanent);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GetStorage _storage = GetStorage();
  
  static var isConnected = false.obs;
  var isLoggedIn = false.obs;
  var nickname = ''.obs;
  var deviceId = ''.obs;
  var isLoading = false.obs;
  var user = Rxn<User>();
  var appVersion = 'Unknown'.obs;

  @override
  void onInit() {
    super.onInit();
    checkInternetConnection();
    ever(isConnected, (_) => handleConnectionChange());
    _initializeAuthState();
    _listenToAuthChanges();
    _initPackageInfo();
  }

  void _listenToAuthChanges() {
    _auth.authStateChanges().listen((User? firebaseUser) {
      user.value = firebaseUser;
      isLoggedIn.value = firebaseUser != null;
    });
  }

  Future<void> _initializeAuthState() async {
    final savedDeviceId = _storage.read('device_id');
    
    if (savedDeviceId != null) {
      deviceId.value = savedDeviceId;
      final fcmService = FCMService();
      await fcmService.initialize();
      String? token = await fcmService.getToken();
      print('token = $token');
      if (token != null) {
        await SignageController.saveFCMToken(user.value!.uid, token);
      }
      await _checkNicknameFromDatabase();
    } else {
      isLoggedIn.value = false;
    }
  }

  Future<void> _checkNicknameFromDatabase() async {
    try {
      final snapshot = await _database.ref('devices/${deviceId.value}').get();
      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map) {
          nickname.value = data['nickname'] as String? ?? '';
          if (nickname.value.isNotEmpty) {
            isLoggedIn.value = true;
            _storage.write('nickname', nickname.value);
          } else {
            isLoggedIn.value = false;
            Get.offAllNamed('/set_nickname');
          }
        } else {
          isLoggedIn.value = false;
          Get.offAllNamed('/set_nickname');
        }
      } else {
        isLoggedIn.value = false;
        Get.offAllNamed('/set_nickname');
      }
    } catch (e) {
      debugPrint('Error checking nickname from database: $e');
      isLoggedIn.value = false;
      Get.snackbar('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการตรวจสอบชื่อเล่น');
      Get.offAllNamed('/set_nickname');
    }
  }

  static Future<void> checkInternetConnection() async {
    try {
      final result = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
      isConnected.value = result.statusCode == 200;
    } catch (_) {
      isConnected.value = false;
    }
  }

  static void handleConnectionChange() {
    if (!isConnected.value) {
      Get.dialog(
        // ignore: deprecated_member_use
        WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('ไม่มีการเชื่อมต่ออินเทอร์เน็ต'),
            content: const Text('กรุณาตรวจสอบการเชื่อมต่อของคุณแล้วลองใหม่อีกครั้ง'),
            actions: [
              AlcMobileButton(
                text: 'ลองใหม่', 
                onPressed: () async {
                  await checkInternetConnection();
                  if (isConnected.value) {
                    Get.back();
                  } else {
                    Fluttertoast.showToast(
                      msg: 'ยังไม่มีการเชื่อมต่อ\nกรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณ', 
                      gravity: ToastGravity.TOP
                    );
                  }
                }
              ),
              AlcMobileButton(
                text: 'ออกจากแอป', 
                onPressed: () => exit(0)
              )
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  Future<void> login(String email, String password) async {
    if (!isConnected.value) {
      _showErrorDialog('ไม่มีการเชื่อมต่ออินเทอร์เน็ต');
      return;
    }
    if (email.isEmpty || password.isEmpty) {
      MyAlertDialog.showDefaultDialog(
        title: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
        content: 'อีเมลและรหัสผ่านต้องไม่เว้นว่าง'
      );
      return;
    }
    if (!email.endsWith('@siammakro.co.th')) {
      MyAlertDialog.showDefaultDialog(
        title: 'รูปแบบอีเมลไม่ถูกต้อง',
        content: 'อีเมลต้องมี @siammakro.co.th ต่อท้ายเสมอ'
      );
      return;
    }
    
    isLoading.value = true;
    try {
      Get.overlayContext?.loaderOverlay.show();
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      user.value = userCredential.user;
      await _checkDeviceId();
      await _updateLastLogin();
      isLoggedIn.value = true;
      _saveAuthState();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showErrorDialog('อีเมลหรือรหัสผ่านไม่ถูกต้อง');
      } else {
        _showErrorDialog('เกิดข้อผิดพลาดในการเข้าสู่ระบบ');
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      _showErrorDialog('เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้ง');
    } finally {
      isLoading.value = false;
      Get.overlayContext?.loaderOverlay.hide();
    }
  }

  void _saveAuthState() {
    _storage.write('device_id', deviceId.value);
    _storage.write('nickname', nickname.value);
  }

  Future<void> _checkDeviceId() async {
    debugPrint('Checking device ID');
    try {
      deviceId.value = await _getDeviceId();
      debugPrint('Device ID: ${deviceId.value}');
      final snapshot = await _database.ref('devices/${deviceId.value}').get();
      debugPrint('Database snapshot: ${snapshot.value}');

      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map) {
          await _checkNickname();
        } else {
          debugPrint('Invalid data format in database');
          Get.offAllNamed('/set_nickname');
        }
      } else {
        debugPrint('Device not found in database');
        Get.offAllNamed('/set_nickname');
      }
    } catch (e) {
      debugPrint('Error checking device ID: $e');
      Get.snackbar('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการตรวจสอบอุปกรณ์');
      Get.offAllNamed('/set_nickname');
    }
  }

  Future<void> _checkNickname() async {
    try {
      final snapshot = await _database.ref('devices/${deviceId.value}').get();
      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map) {
          nickname.value = data['nickname'] as String? ?? '';
          debugPrint('Nickname found: ${nickname.value}');

          if (nickname.value.isNotEmpty) {
            _storage.write('nickname', nickname.value);
            Get.offAllNamed('/home');
          } else {
            debugPrint('Nickname is empty');
            Get.offAllNamed('/set_nickname');
          }
        } else {
          debugPrint('Invalid data format in database');
          Get.offAllNamed('/set_nickname');
        }
      } else {
        debugPrint('Device not found in database');
        Get.offAllNamed('/set_nickname');
      }
    } catch (e) {
      debugPrint('Error checking nickname: $e');
      Get.snackbar('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการตรวจสอบชื่อเล่น');
      Get.offAllNamed('/set_nickname');
    }
  }

  Future<void> _updateLastLogin() async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await _database.ref('devices/${deviceId.value}').update({
        'last_login': now
      });
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (GetPlatform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.androidId;
    } else if (GetPlatform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }
    return '';
  }

  Future<void> setNickname(String newNickname) async {
    isLoading.value = true;
    try {
      // Validate nickname
      if (newNickname.isEmpty) {
        _showErrorDialog('ชื่อเล่นต้องมีอย่างน้อย 1 ตัวอักษร');
        return;
      }
      if (newNickname.contains(RegExp(r'[\[\]\{\}," ]'))) {
        _showErrorDialog('ชื่อเล่นต้องไม่มีตัวอักษร "[", "]", "{", "}", ",", " " และช่องว่าง');
        return;
      }

      Get.overlayContext?.loaderOverlay.show();
      final snapshot = await _database.ref('devices').get();
      Map<String, dynamic> devices = {};
      
      if (snapshot.value != null && snapshot.value is Map) {
        devices = Map<String, dynamic>.from(snapshot.value as Map);
      }

      if (devices.values.any((device) => device is Map && device['nickname'] == newNickname)) {
        Get.overlayContext?.loaderOverlay.hide();
        _showErrorDialog('ชื่อเล่นนี้ถูกใช้ไปแล้ว');
        return;
      }

      if (deviceId.value.isEmpty) {
        await _getDeviceId();
      }

      if (deviceId.value.isNotEmpty) {
        final now = DateTime.now().toUtc().toIso8601String();
        await _database.ref('devices/${deviceId.value}').set({
          'device_id': deviceId.value,
          'nickname': newNickname,
          'created': now,
          'last_login': now,
        });

        nickname.value = newNickname;
        Get.overlayContext?.loaderOverlay.hide();
        Get.offAllNamed('/home');
      } else {
        Get.overlayContext?.loaderOverlay.hide();
        _showErrorDialog('ไม่สามารถตั้งชื่อได้\nกรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      debugPrint('Error setting nickname: $e');
      Get.overlayContext?.loaderOverlay.hide();
      _showErrorDialog('เกิดข้อผิดพลาดในการตั้งชื่อเล่น');
    } finally {
      Get.overlayContext?.loaderOverlay.hide();
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _auth.signOut();
      isLoggedIn.value = false;
      nickname.value = '';
      deviceId.value = '';
      user.value = null;
      _storage.remove('device_id');
      _storage.remove('nickname');
      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('Error during logout: $e');
      _showErrorDialog('เกิดข้อผิดพลาดในการออกจากระบบ กรุณาลองใหม่อีกครั้ง');
    } finally {
      isLoading.value = false;
    }
  }

  void changeNicknameDialog() {
    final TextEditingController nicknameController = TextEditingController();
    final RxString errorMessage = ''.obs;
    Get.dialog(
      AlertDialog(
        title: const Text('เปลี่ยนชื่อเล่น'),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nicknameController,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.name,
              decoration: _getInputDecoration(errorMessage),
            ),
          ],
        )),
        actions: [
          AlcMobileButton(
            text: 'ยกเลิก', 
            onPressed: () => Get.back(),
          ),
          AlcMobileButton(
            text: 'บันทึก', 
            onPressed: () => _validateAndSetNickname(nicknameController.text, errorMessage)
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  InputDecoration _getInputDecoration(RxString errorMessage) {
    return InputDecoration(
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
    );
  }

  void _validateAndSetNickname(String newNickname, RxString errorMessage) {
    if (newNickname.isEmpty) {
      errorMessage.value = 'ชื่อเล่นต้องมีอย่างน้อย 1 ตัวอักษร';
    } else if (newNickname.contains(RegExp(r'[\[\]\{\}," ]'))) {
      errorMessage.value = 'ชื่อเล่นต้องไม่มีตัวอักษร "[", "]", "{", "}", ",", " " และช่องว่าง';
    } else {
      _setNickname(newNickname);
    }
  }

  Future<void> _setNickname(String newNickname) async {
    Get.context!.loaderOverlay.show();
    try {
      if (deviceId.value.isEmpty) {
        await _getDeviceId();
      }

      if (deviceId.value.isNotEmpty) {
        bool isDuplicate = await _isNicknameDuplicate(newNickname);
        if (!isDuplicate) {
          await _updateNicknameInDatabase(newNickname);
          nickname.value = newNickname;
          _storage.write('nickname', nickname.value);
          Get.context!.loaderOverlay.hide();
          Get.back();
        } else {
          _showErrorDialog('ไม่สามารถตั้งชื่อนี้ได้\nเนื่องจากมีชื่อนี้อยู่แล้ว');
        }
      } else {
        _showErrorDialog('ไม่สามารถตั้งชื่อได้\nกรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      debugPrint("Error setting nickname: $e");
      _showErrorDialog('เกิดข้อผิดพลาด\nไม่สามารถตั้งชื่อได้\nกรุณาลองใหม่อีกครั้ง');
    }
  }

  Future<bool> _isNicknameDuplicate(String newNickname) async {
    DataSnapshot snapshot = await _database.ref().child('devices').get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> devices = snapshot.value as Map<dynamic, dynamic>;
      return devices.values.any((device) => device['nickname'] == newNickname);
    }
    return false;
  }

  Future<void> _updateNicknameInDatabase(String newNickname) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _database.ref().child('devices')
      .child(deviceId.value)
      .child('nickname_history')
      .child(timestamp.toString())
      .set(nickname.value);
    await _database.ref().child('devices').child(deviceId.value).update({
      'device_id': deviceId.value,
      'nickname': newNickname,
      'last_change': DateTime.now().toIso8601String(),
    });
  }

  void _showErrorDialog(String message) {
    Get.context!.loaderOverlay.hide();
    MyAlertDialog.showDefaultDialog(
      title: 'เกิดข้อผิดพลาด',
      content: message
    );
  }
} */