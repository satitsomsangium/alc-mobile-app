import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:alc_mobile_app/model/app_version_model.dart';
import 'package:alc_mobile_app/model/product_data_model.dart';
import 'package:alc_mobile_app/model/rail_card_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FirebaseController extends GetxController {
  static FirebaseController get to => Get.find();

  static FirebaseController init({String? tag, bool permanent = false}) =>
      Get.put(FirebaseController(), tag: tag, permanent: permanent);

  static final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
  static final AuthController authController = Get.find();

  static Rx<DateTime?> productDateModify = Rx<DateTime?>(null);

  static Rx<Product> product = Product(art: 'XXXXXX', dscr: 'xxxxxxxx', price: 'XXX').obs;

  static RxList<RailCard> railCardListDataByNickname = <RailCard>[].obs;

  static Future<void> checkNicknameIsEmpty() async {
    if (authController.nickname.value == '') {
      MyAlertDialog.showDefaultDialog(
        barrierDismissible: false,
        title: 'ยังไม่ได้ตั้งชื่อเล่น',
        content: 'หากยังไม่ตั้งชื่อเล่นจะไม่สามารถขอเรียลการ์ดได้',
        textYes: 'ตั้งชื่อเล่น',
        onPressYes: () async {
          Get.back();
          Get.offAllNamed('/set_nickname');
        }
      );
    }
  }

  static Future<Product?> getProduct(String article) async {
    await AuthController.checkInternetConnection();
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
      String dateString = snapshot.value.toString();
      // แยกวันที่และเวลาออกจากกัน
      List<String> parts = dateString.split('|').where((part) => part.trim().isNotEmpty).toList();
      String datePart = parts[0].trim();
      String timePart = parts[1].trim();
      // แปลง String เป็น DateTime
      DateTime dateTime = DateFormat("d/M/yyyy").parse(datePart);
      List<String> timeParts = timePart.split(':');
      dateTime = dateTime.add(Duration(
        hours: int.parse(timeParts[0]),
        minutes: int.parse(timeParts[1]),
        seconds: int.parse(timeParts[2])
      ));
      productDateModify.value = dateTime;
    } else {
      productDateModify.value = null;
    }
  }

  static Future<List<RailCard>> getRailCardList() async {
    final DataSnapshot snapshot = await firebaseDatabase.ref().child('Railcard').get();
    List<RailCard> railCardList = [];
    if (snapshot.exists && snapshot.value != null) {
      if (snapshot.value is List) {
        List<dynamic> listRailCard = snapshot.value as List<dynamic>;
        for (var railCard in listRailCard) {
          if (railCard != null) {
            railCardList.add(RailCard.fromMap(Map<String, dynamic>.from(railCard as Map)));
          }
        }
      }
    }
    return railCardList;
  }

  static Future<void> getRailCardListByNickname() async {
    List<RailCard> railCardListByNickname = [];
    List<RailCard> getListRailCard = await getRailCardList();
    if (getListRailCard.isNotEmpty) {
      for (RailCard railCard in getListRailCard) {
        if (railCard.nickname == authController.nickname.value) {
          railCardListByNickname.add(railCard);
        }
      }
    }
    railCardListDataByNickname.value = railCardListByNickname;
  }

  static Future<void> insertRailCard(RailCard railCard) async {
    if (authController.nickname.value != '') {
      DateTime now = DateTime.now();
      String formattedDate = '${now.day}/${now.month}/${now.year}';
      String formattedTime = '${now.hour}:${now.minute}:${now.second}';
      List<RailCard> getListRailCard = await getRailCardList();

      bool isUpdated = false;

      for (int i = 0; i < getListRailCard.length; i++) {
        if (getListRailCard[i].art == railCard.art) {
          getListRailCard[i].date = formattedDate;
          getListRailCard[i].time = formattedTime;
          getListRailCard[i].qty = getListRailCard[i].qty + 1;

          await firebaseDatabase.ref().child('Railcard').child('${i + 1}')
          .update(getListRailCard[i].toMap());
          isUpdated = true;
          break;
        }
      }
      if (!isUpdated) {
        railCard.nickname = authController.nickname.value;
        railCard.date = formattedDate;
        railCard.time = formattedTime;
        await firebaseDatabase.ref().child('Railcard').child('${getListRailCard.length + 1}')
        .set(railCard.toMap());
      }

      await getRailCardListByNickname();
    } else {
      await checkNicknameIsEmpty();
    }
  }

  static Future<void> storeVersionsInFirebase() async {
    final versionsRef = firebaseDatabase.ref().child('app_versions');

    final List<Map<String, dynamic>> versions = [
      {
        'version': '4.0.0',
        'date': '3-AUG-2024',
        'content': [
          'อัปเดต sdk',
          'อัปเดต Libary',
          'ปรับปรุง ui',
          'เปลี่ยนระบบ login ให้สามารถจำเครื่อง และชื่อเล่นที่เคยตั้งไว้ได้ เมื่อ login ใหม่ในเครื่องเดิมจะใช้ชื่อที่เคยตั้งไว้ได้เลย',
          'เพิ่มการแสดงรูปภาพสินค้าในหน้าเช็คราคาสินค้า (บางรายการอาจจะไม่มีรูป)',
          'เปลี่ยนการดาวน์โหลดข้อมูลสำหรับ feature การนับสต๊อก offline จากดาวน์โหลดเมื่อเปิดแอปครั้งแรก เป็นให้โหลดเองเมื่อจะใช้งานครั้งแรก',
          '',
          'ลบการเช็คอัปเดตแอป',
        ],
      },
      {
        'version': '3.1.0',
        'date': '25-NOV-2021',
        'content': [
          'เพิ่มลิงก์เข้า M-Learning, HR Self Services, สมัครงานภายใน',
          'เพิ่มระบบแจ้งซ่อมของแผนก ALC',
        ],
      },
      {
        'version': '3.0.1',
        'date': '16-OCT-2021',
        'content': [
          'แก้ไขการอ่านข้อมูลบาร์โค้ด 13 หลัก ในโหมดออฟไลน์',
        ],
      },
      {
        'version': '3.0.0',
        'date': '9-SEP-2021',
        'content': [
          'เพิ่มฟังชันนับสต๊อกสินค้าแบบออฟไลน์ เพื่อแก้ไขปัญหา hht ไม่มีสัญญานในห้องแช่แข็ง',
          'ตัดฟังชันขอป้าย Makro Sinage ออก',
          'เพิ่มการระบุจำนวนป้าย Railcard เมื่อมีการยิงซ้ำ',
          'พัฒนาแอปด้วย Flutter',
        ],
      },
      {
        'version': '2.0.0',
        'date': '2-APR-2021',
        'content': [
          'เพิ่มประสิทธิภาพการทำงานของแอป',
          'เปลี่ยนระบบล็อกอินให้สามารถเข้าใช้งานได้เร็วขึ้น',
          'เพิ่มความเร็วในการรับ-ส่งข้อมูล ระบบขอ railcard และระบบขอ makro signage',
          'ปรับแต่ง UI ของแอปให้สวยงาม ใช้งานได้ง่ายขึ้น',
          'เพิ่มระบบอัปเดตราคาอัตโนมัติทุก ๆ 10 นาที',
          'ปิดระบบรับข้อมูลของ alc ในแอป และเปลี่ยนไปใช้การรับข้อมูลในคอมพิวเตอร์',
        ],
      },
      {
        'version': '1.4.0',
        'date': '10-OCT-2020',
        'content': [
          'เพิ่มการขอป้ายราคา makro signage',
          'เพิ่มการกดปุ่มกลับ 2 ครั้งเพื่อออกจากแอป',
          'เพิ่มหน้าแจ้งปัญหาการใช้งานและการแนะนำ',
          'เพิ่มการใส่ชื่อคนขอป้ายเพื่อกรองผู้ใช้ได้มากขึ้น',
          'แก้ข้อความในแอปให้เป็นภาษาไทย',
        ],
      },
      {
        'version': '1.3.2',
        'date': '10-OCT-2020',
        'content': [
          'เพิ่มการอ่านบาร์โค้ดที่ปริ้นออกมาจากเครื่องชั่ง',
          'แก้ไขขนาดฟ้อนต์ให้เหมาะสมกับอุปกรณ์',
        ],
      },
      {
        'version': '1.3.1',
        'date': '10-OCT-2020',
        'content': [
          'แก้ไขการอ่านบาร์โค้ด 8 หลัก',
          'เพิ่มการเก็บ Error log และ รหัสสินค้าที่ไม่แสดงผล เพื่อนำไปปรับปรุงระบบ',
        ],
      },
      {
        'version': '1.3.0',
        'date': '10-OCT-2020',
        'content': [
          'เพิ่มการเช็คราคาสินค้า',
          'อัพเดทหน้าจัดการข้อมูลของ ALC',
        ],
      },
      {
        'version': '1.2.0',
        'date': '10-OCT-2020',
        'content': [
          'แก้ไขแหล่งเก็บข้อมูล',
          'เพิ่มฟังชั่นการแจ้งเตือนเมื่อมีการอัพเดทเวอร์ชั่นแอป',
        ],
      },
      {
        'version': '1.0.0',
        'date': '10-OCT-2020',
        'content': [
          'เปิดตัวแอปขอเรียลการ์ด',
        ],
      },
    ];

    for (var versionData in versions) {
      await versionsRef.push().set(versionData);
    }

    debugPrint('Version data stored successfully in Firebase');
  }

  static Future<List<AppVersion>> getVersionsFromFirebase() async {
    final versionsRef = firebaseDatabase.ref().child('app_versions');

    try {
      DatabaseEvent event = await versionsRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> versionsMap = snapshot.value as Map<dynamic, dynamic>;
        List<AppVersion> versions = versionsMap.entries.map((entry) {
          return AppVersion.fromMap(entry.value as Map<dynamic, dynamic>);
        }).toList();

        // เรียงลำดับเวอร์ชันจากใหม่ไปเก่า
        versions.sort((a, b) => b.version.compareTo(a.version));

        return versions;
      }
    } catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการดึงข้อมูล: $e');
    }

    return [];
  }
}