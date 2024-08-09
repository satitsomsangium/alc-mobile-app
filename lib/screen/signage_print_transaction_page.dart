/* import 'package:alc_mobile_app/controller/signage_controller.dart';
import 'package:alc_mobile_app/model/signage_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; */
/* import 'package:badges/badges.dart' as badges;

class SignageAlcPage extends StatelessWidget {
  const SignageAlcPage({super.key});

  @override
  Widget build(BuildContext context) {
    SignageController.updatePendingPrintCount();
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าหลักสำหรับคนพิมพ์ป้าย'),
        actions: [
          /* BadgeIcon(
            icon: Icon(Icons.print),
            badgeCount: Obx(() => SignageController.pendingPrintCount.value),
            onTap: () => Get.to(() => PrinterTransactionListPage()),
          ), */
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const Text('หน้าหลักสำหรับคนพิมพ์ป้าย'),
            /* badges.Badge(
              position: badges.BadgePosition.topEnd(top: -10, end: -12),
              showBadge: true,
              ignorePointer: false,
              onTap: () {},
              badgeContent:
                  const Icon(Icons.check, color: Colors.white, size: 10),
              badgeAnimation: const badges.BadgeAnimation.rotation(
                animationDuration: Duration(seconds: 1),
                colorChangeAnimationDuration: Duration(seconds: 1),
                loopAnimation: false,
                curve: Curves.fastOutSlowIn,
                colorChangeAnimationCurve: Curves.easeInCubic,
              ),
              badgeStyle: badges.BadgeStyle(
                shape: badges.BadgeShape.square,
                badgeColor: Colors.blue,
                padding: const EdgeInsets.all(5),
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderGradient: const badges.BadgeGradient.linear(
                    colors: [Colors.red, Colors.black]),
                badgeGradient: const badges.BadgeGradient.linear(
                    colors: [Colors.blue, Colors.yellow],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                ),
                elevation: 0,
              ),
              child: const Text('Badge'),
            ), */
            badges.Badge(
              badgeContent: Obx(() => Text(SignageController.pendingPrintCount.value.toString())),
              child: const Icon(Icons.settings),
            )
          ],
        ),
      ),
    );
  }
}


 */

import 'package:alc_mobile_app/component/alc_card.dart';
import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:alc_mobile_app/controller/signage_controller.dart';
import 'package:alc_mobile_app/model/signage_model.dart';
import 'package:alc_mobile_app/screen/signage_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SignagePrintTransactionPage extends GetView<SignageController> {
  SignagePrintTransactionPage({super.key});

  final RxBool isShowSelection = false.obs;

  @override
  Widget build(BuildContext context) {
    SignageController.getPrintTransactions();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการแผ่นงาน'),
        actions: [
          Obx(() => TextButton(
            onPressed: () {
              isShowSelection.value = !isShowSelection.value;
              if (!isShowSelection.value) {
                SignageController.selectedTransactions.clear();
                SignageController.toggleSelectAll(false);
              }
            }, 
            child: isShowSelection.value 
              ? const Text('ยกเลิกการเลือก', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)) 
              : const Text('เลือก', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)) 
          ))
        ],
      ),
      body: Column(
        children: [
          _buildSelectAllCheckbox(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: RefreshIndicator(
                color: Colors.white,
                backgroundColor: Colors.red,
                onRefresh: () async {
                  await SignageController.getPrintTransactions(isLoad: false);
                },
                child: Obx(() {
                  if (SignageController.isLoadingPrintTransactions.value) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (SignageController.printTransactionList.isEmpty) {
                    return ListView(
                      children: const [
                        Center(child: Text('ไม่มีข้อมูล')),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: SignageController.printTransactionList.length,
                            itemBuilder: (context, index) {
                              final transaction = SignageController.printTransactionList[index];
                              return Column(
                                children: [
                                  SizedBox(height: index == 0 ? 16.sp : 0),
                                  AlcCard(
                                    child: InkWell(
                                      onTap: () {
                                        if (isShowSelection.value) {
                                          SignageController.toggleSelection(transaction.id);
                                        } else {
                                          Get.to(() => SignagesListPage(txnIdList: [transaction.id], title: transaction.title, isAlc: true));
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(transaction.title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                                                  Row(
                                                    children: [
                                                      const Text('สถานะ : '),
                                                      Text(
                                                        transaction.status == SignageStatus.sent ? 'รอปริ้น' : transaction.status.asString,
                                                        style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(transaction.status)),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Text('ผู้ส่ง : '),
                                                      Text(transaction.creator, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),)
                                                    ],
                                                  ),
                                                  Text('วันและเวลาที่สร้าง : ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.created)}'),
                                                  if (transaction.status == SignageStatus.sent || transaction.status == SignageStatus.printed && transaction.sendTime != null)
                                                    Text('วันและเวลาที่ส่ง :     ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.sendTime!)}'),
                                                  if (transaction.status == SignageStatus.printed && transaction.printTime != null)
                                                    Text('วันและเวลาที่พิมพ์ : ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.printTime!)}'),
                                                ],
                                              ),
                                            ),
                                            _buildCheckbox(transaction.id),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16)
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                }),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
        return Visibility(
          visible: isShowSelection.value,
          child: FloatingActionButton(
            child: const Icon(Icons.print),
            onPressed: () async {
              if (SignageController.selectedTransactions.isNotEmpty) {
                bool? result = await Navigator.push(
                  Get.context!,
                  MaterialPageRoute(builder: (context) => SignagesListPage(
                    txnIdList: SignageController.selectedTransactions, 
                    title: 'เลือก ${SignageController.selectedTransactions.length} รายการ',
                    isAlc: true
                  )),
                );
                if (result != null || result == true) {
                  SignageController.selectedTransactions.clear();
                  SignageController.allSelected.value = false;
                }
              } else {
                MyAlertDialog.showDefaultDialog(
                  content: 'กรุณาเลือกอย่างน้อย 1 รายการ'
                );
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildSelectAllCheckbox() {
    return Obx(() => Visibility(
      visible: isShowSelection.value,
      child: Container(
        /* color: Colors.red, */
        padding: EdgeInsets.symmetric(horizontal: 13.sp),
        child: CheckboxListTile(
          title: SignageController.allSelected.value 
            ? const Text('ยกเลิกการเลือกทั้งหมด') 
            : Text('เลือกทั้งหมด (${SignageController.printTransactionList.length} รายการ)'),
          value: SignageController.allSelected.value,
          onChanged: (bool? value) {
            SignageController.toggleSelectAll(value ?? false);
          },
        ),
      ),
    ));
  }

  Widget _buildCheckbox(String txnId) {
    return Obx(() => Visibility(
      visible: isShowSelection.value,
      child: Checkbox(
        value: SignageController.selectedTransactions.contains(txnId),
        onChanged: (bool? value) {
          SignageController.toggleSelection(txnId);
        },
      ),
    ));
  }

  Color _getStatusColor(SignageStatus status) {
    switch (status) {
      case SignageStatus.pending:
        return Colors.orange;
      case SignageStatus.sent:
        return Colors.blue;
      case SignageStatus.printed:
        return Colors.green;
      case SignageStatus.deleted:
        return Colors.red;
    }
  }
}
