import 'package:alc_mobile_app/component/alc_padding.dart';
import 'package:alc_mobile_app/component/button.dart';
import 'package:alc_mobile_app/component/alc_card.dart';
import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:alc_mobile_app/controller/signage_controller.dart';
import 'package:alc_mobile_app/model/signage_model.dart';
import 'package:alc_mobile_app/screen/signage_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';

class SignageTransactionListPage extends GetView<SignageController> {
  const SignageTransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    SignageController.getSignageTransactionList();
    
    return Scaffold(
      appBar: AppBar(title: const Text('รายการแผ่นงาน')),
      body: AlcPadding(
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: Colors.red,
          onRefresh: () async {
            await SignageController.getSignageTransactionList(isLoad: false);
          },
          child: Obx(() {
            if (SignageController.isLoadingTransactions.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (SignageController.transactionList.isEmpty) {
              return ListView(
                children: const [
                  Center(child: Text('ไม่มีข้อมูล')),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: SignageController.transactionList.length,
                itemBuilder: (context, index) {
                  final transaction = SignageController.transactionList[index];
                  return Column(
                    children: [
                      AlcCard(
                        child: InkWell(

                          //test ระบบ ปริ้นป้าย
                          /* onLongPress: () async {
                            Get.overlayContext?.loaderOverlay.show();
                            await SignageController.changeTransactionStatus(transaction.id, SignageStatus.printed);
                            await SignageController.getSignageTransactionList(isLoad: false);
                            Get.overlayContext?.loaderOverlay.hide();
                          }, */
                          onTap: () => Get.to(() => SignagesListPage(txnIdList: [transaction.id], title: transaction.title)),
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
                                            transaction.status.asString,
                                            style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(transaction.status)),
                                          ),
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
                                IconButton(
                                  icon: const Icon(Icons.delete_rounded, color: Colors.red,),
                                  onPressed: () => _showDeleteDialog(context, transaction.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16)
                    ],
                  );
                },
              );
            }
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final TextEditingController titleController = TextEditingController();
          MyAlertDialog.showDefaultDialog(
            title: 'เพิ่มแผ่นงานใหม่',
            contentWidget: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('(ไม่บังคับ)'),
                TextField(
                  controller: titleController,
                  maxLength: 14,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    isDense: true,
                    counterText: "",
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    hintText: "ตั้งชื่อแผ่นงาน",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black26,
                    ),
                  ),
                  onSubmitted: (value) => submitTitle(value),
                )
              ],
            ),
            isNoButton: true,
            onPressYes: () => submitTitle(titleController.text),
          );
        },
      ),
    );
  }

  void submitTitle(String titleValue) async {
    Get.back();
    Get.overlayContext!.loaderOverlay.show();
    await SignageController.createNewTransaction(titleValue);
    await SignageController.getSignageTransactionList(isLoad: false);
    Get.overlayContext!.loaderOverlay.hide();
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

  void _showDeleteDialog(BuildContext context, String id) {
    MyAlertDialog.showDefaultDialog(
      title: 'ลบแผ่นงานนี้',
      content: 'ต้องการลบแผ่นงานนี้หรือไม่',
      isNoButton: true,
      onPressYes: () async {
        Get.context!.loaderOverlay.show();
        Get.back();
        await SignageController.deleteTransaction(id);
        await SignageController.getSignageTransactionList(isLoad: false);
        Get.context!.loaderOverlay.hide();
      }
    );
  }
}