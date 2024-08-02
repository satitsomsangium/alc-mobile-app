import 'package:alc_mobile_app/component/appbar.dart';
import 'package:alc_mobile_app/component/button.dart';
import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:alc_mobile_app/controller/db_controller.dart';
import 'package:alc_mobile_app/model/count_aisle_bay_model.dart';
import 'package:alc_mobile_app/screen/stock_count/custom_bay_page.dart';
import 'package:alc_mobile_app/screen/stock_count/select_bay_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

class StockCountPage extends StatefulWidget {
  const StockCountPage({super.key});

  @override
  State<StockCountPage> createState() => _StockCountPageState();
}

class _StockCountPageState extends State<StockCountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'นับสต๊อก',
        popupMenu: SizedBox(),
        color1: Color(0xFFFFA72F),
        color2: Color(0xFFFF641A)
      ),
      body: Obx(() {
        CountAisleBay aisleBayData = DbController.countAisleBay.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            setAisleBay(),
            productDataStatus(),
            customListtile('FV', 'แผนกผักและผลไม้', aisleBayData.fvAisle, aisleBayData.fvBay),
            customListtile('BU', 'แผนกหมู เนื้อ ไก่', aisleBayData.buAisle, aisleBayData.buBay),
            customListtile('FI', 'แผนกปลา', aisleBayData.fiAisle, aisleBayData.fiBay),
            customListtile('BK', 'แผนกเบเกอรี่', aisleBayData.bkAisle, aisleBayData.bkBay),
            customListtile('FZ', 'แผนกอาหารแช่แข็ง', aisleBayData.fzAisle, aisleBayData.fzBay),
          ],
        );
      }),
    );
  }

  Widget setAisleBay() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.start,
        spacing: 16.0,
        runSpacing: 16.0,
        children: [
          AlcMobileButton(
            onPressed: () {
              Get.to(const CustomBayPage());
            }, 
            text: 'กำหนด Aisle - Bay'
          ),
          ElevatedButton(
            onPressed: () {
              MyAlertDialog.showDefaultDialog(
                title: 'ลบข้อมูลการนับ',
                content: 'หากลบข้อมูลการนับ Aisle - Bay จะไม่หายไป \n ข้อมูลที่นับจะถูกลบออกเท่านั้น \nต้องการลบข้อมูลการนับใช่หรือไม่',
                isNoButton: true,
                textYes: 'ลบข้อมูลการนับ',
                onPressYes: () async {
                  Get.back();
                  Get.context!.loaderOverlay.show();
                  await DbController.clearAllBayDataLists();
                  Get.context!.loaderOverlay.hide();
                }, 
              );
            },
            child: const Text('ลบข้อมูลการนับ')
          ),
          ElevatedButton(
            onPressed: () {
              MyAlertDialog.showDefaultDialog(
                title: 'รีเช็ตฐานข้อมูล',
                content: 'ต้องการลบข้อมูล offline ออกจากอุปกรณ์นี้ใช่หรือไม่',
                isNoButton: true,
                textYes: 'รีเช็ตฐานข้อมูล',
                onPressYes: () async {
                  Get.back();
                  Get.context!.loaderOverlay.show();
                  await DbController.clearDatabase();
                  await DbController.countAisleBayInit();
                  await DbController.isOfflineDataReadyInit();
                  Get.context!.loaderOverlay.hide();
                }, 
              );
            },
            child: const Text('รีเช็ตฐานข้อมูล')
          ),
          AlcMobileButton(
            text: 'ดาวน์โหลดข้อมูล', 
            onPressed: onPressDownLoadData, 
            color: Colors.green, 
            enable: !DbController.isOfflineDatabaseReady.value
          )
        ],
      ),
    );
  }

  Widget productDataStatus() {
    return Obx(() {
      return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Text('สถานะข้อมูล offline: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          DbController.isOfflineDatabaseReady.value 
            ? const Text('พร้อมใช้งาน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.green))
            : const Text('ไม่พร้อมใช้งาน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.red))
        ],
      ),
    );
    });
  }

  static void onPressDownLoadData() {
    MyAlertDialog.showDefaultDialog(
      title: 'ต้องการโหลดข้อมูลหรือไม่',
      content: 'การโหลดข้อมูลอาจใช้เวลาหลายนาที \nหากไม่ต้องการใช้ฟังชั่นนี้ กรุณากดยกเลิก',
      isNoButton: true,
      onPressYes: () async {
        Get.back();
        await DbController.loadAllDataFromFirebase();
      }
    );
  }

  Widget customListtile(String dept, String deptName, int aisle, int bay) {
    return Column(
      children: [
        ListTile(
          isThreeLine: false,
          title: Text(
            deptName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('$aisle Aisle - $bay Bay'),
          leading: CircleAvatar(
            backgroundColor: Colors.red[300],
            child: Text(
              dept,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white),
            ),
          ),
          onTap: () {
            if (DbController.isOfflineDatabaseReady.value) {
              if (aisle == 0) {
                MyAlertDialog.showDefaultDialog(
                  title: 'ยังไม่ได้กำหนด Aisle - Bay',
                  content: 'ต้องการไปหน้ากำหนด Aisle - Bay หรือไม่',
                  isNoButton: true,
                  onPressYes: () {
                    Get.back();
                    Get.to(const CustomBayPage());
                  },
                );
              } else {
                Get.to(SelectBayPage(dept));
              }
            } else {
              MyAlertDialog.showDefaultDialog(
                title: 'แจ้งเตือน',
                content: 'ต้องดาวน์โหลดข้อมูลก่อน\n เพื่อให้ใช้งานในโหมด offline ได้'
              );
            }
            
          },
        ),
        const Divider(height: 1, thickness: 0.5, indent: 10, endIndent: 10),
      ],
    );
  }
}