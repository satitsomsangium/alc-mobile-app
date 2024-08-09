import 'package:alc_mobile_app/component/button.dart';
import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:alc_mobile_app/controller/signage_controller.dart';
import 'package:alc_mobile_app/model/signage_model.dart';
import 'package:alc_mobile_app/screen/signage_input_page.dart';
import 'package:alc_mobile_app/screen/signage_selecttion_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:uuid/uuid.dart';

class SignagesListPage extends GetView<SignageController> {
  /* final String txnId; */
  final List<String> txnIdList;
  final String title;
  final bool isAlc;

  SignagesListPage({super.key, /* required this.txnId, */ required this.txnIdList, required this.title, this.isAlc = false}) {
    Get.put(SignagesListController(), permanent: true);
    Get.find<SignageController>().getSignagesList(txnIdList);
  }

  final RxBool isEdit = false.obs;

  @override
  Widget build(BuildContext context) {
    if (!isAlc) {
      SignageController.getSignageTransactionById(txnIdList[0]);
    }
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            Visibility(
              visible: SignageController.signageTransaction.value.status == SignageStatus.pending,
              child: IconButton(
                onPressed: () => isEdit.toggle(),
                icon: Icon(isEdit.value ? Icons.edit_off_rounded : Icons.edit_rounded),
              ),
            )
          ],
        ),
        body: Obx(() {
          final SignageTransaction transaction = SignageController.signageTransaction.value;
          if (SignageController.isLoadingSignages.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (SignageController.signageList.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูล'));
          } else {
            return Column(
              children: [
                if (!isAlc)
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black12
                        )
                      )
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('สถานะ : ', style: TextStyle(fontSize: 16.sp)),
                                  Text(
                                    transaction.status.asString,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(transaction.status),
                                    ),
                                  )
                                ],
                              ),
                              if (transaction.status == SignageStatus.sent || transaction.status == SignageStatus.printed && transaction.sendTime != null)
                                Text('วันและเวลาที่ส่ง :     ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.sendTime!)}'),
                              if (transaction.status == SignageStatus.printed && transaction.printTime != null)
                                Text('วันและเวลาที่พิมพ์ : ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.printTime!)}'),
                            ],
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        sendButton(transaction)
                      ],
                    ),
                  ),
                Expanded(child: _buildSignageList(SignageController.signageList)),
                if (isAlc)
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(16.sp),
                      child: AlcMobileButton(
                        text: 'เปลี่ยนสถานะเป็นพิมพ์แล้ว',
                        onPressed: () {
                          MyAlertDialog.showDefaultDialog(
                            title: txnIdList.length == 1 ? 'เปลี่ยนสถานะเป็นพิมพ์แล้ว' : 'เปลี่ยนสถานะทั้งหมดเป็นพิมพ์แล้ว',
                            content: txnIdList.length == 1 ? 'ต้องการเปลี่ยนสถานะเป็นพิมพ์แล้วหรือไม่' : 'ต้องการเปลี่ยนสถานะเป็นพิมพ์แล้วทั้งหมดหรือไม่',
                            isNoButton: true,
                            onPressYes: () async {
                              Get.back();
                              Get.overlayContext?.loaderOverlay.show();
                              await SignageController.markAsPrinted(txnIdList);
                              Get.overlayContext?.loaderOverlay.hide();
                              Get.back(result: true);
                            }
                          );
                        },
                      ),
                    ),
                  )
              ],
            );
          }
        }),
        floatingActionButton: Visibility(
          visible: SignageController.signageTransaction.value.status == SignageStatus.pending,
          child: AnimatedOpacity(
            opacity: SignagesListController.to.showFloatingButton.value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: SignagesListController.to.showFloatingButton.value
                ? FloatingActionButton(
                    onPressed: () => _showSignageSelectionDialog(),
                    child: const Icon(Icons.add),
                  )
                : const SizedBox(),
          ),
        ),
      );
    });
  }

  Widget sendButton(SignageTransaction transaction) {
    final DateTime now = DateTime.now();
    int cancelAbleTime = 10;
    bool isCancel = false;
    if (transaction.status == SignageStatus.pending) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: AlcMobileButton(
          color: Colors.green,
          text: 'ส่งให้ ALC',
          onPressed: () {
            MyAlertDialog.showDefaultDialog(
              title: 'ส่งให้ ALC',
              content: 'ต้องการส่งแผ่นงานนี้ให้ ALC หรือไม่',
              isNoButton: true,
              textYes: 'ส่ง',
              onPressYes: () async {
                Get.back();
                Get.overlayContext?.loaderOverlay.show();
                await SignageController.changeTransactionStatus(txnIdList[0], SignageStatus.sent);
                await SignageController.getSignageTransactionById(txnIdList[0]);
                await SignageController.getSignageTransactionList();
                Get.overlayContext?.loaderOverlay.hide();

              }
            );
          },
        ),
      );
    } else if (transaction.status == SignageStatus.sent &&
            transaction.sendTime != null &&
            now.difference(transaction.sendTime!).inMinutes < cancelAbleTime) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: AlcMobileButton(
          color: Colors.blue,
          text: 'ยกเลิกการส่ง',
          onPressed: () {
            isCancel = now.difference(transaction.sendTime!).inMinutes < cancelAbleTime;
            if (isCancel) {
              MyAlertDialog.showDefaultDialog(
                title: 'ยกเลิกการส่ง',
                content: 'ต้องการยกเลิกการส่ง หรือไม่',
                isNoButton: true,
                textNo: 'ไม่',
                textYes: 'ยกเลิกการส่ง',
                onPressYes: () async {
                  Get.back();
                  Get.overlayContext?.loaderOverlay.show();
                  await SignageController.changeTransactionStatus(txnIdList[0], SignageStatus.pending);
                  await SignageController.getSignageTransactionById(txnIdList[0]);
                  await SignageController.getSignageTransactionList();
                  Get.overlayContext?.loaderOverlay.hide();
                }
              );
            } else {
              MyAlertDialog.showDefaultDialog(
                title: 'เกิดข้อผิดพลาด',
                content: 'ไม่สามารถยกเลิกได้เนื่องจากเกินเวลาที่กำหนด',
              );
            }
            
          },
        ),
      );
    } else if (transaction.status == SignageStatus.printed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: AlcMobileButton(
          color: Colors.red,
          text: 'ลบแผ่นงาน',
          onPressed: () {
            MyAlertDialog.showDefaultDialog(
              title: 'ลบแผ่นงาน',
              content: 'ต้องการลบแผ่นงานหรือไม่',
              isNoButton: true,
              textYes: 'ลบ',
              onPressYes: () async {
                Get.back();
                Get.context!.loaderOverlay.show();
                await SignageController.deleteTransaction(txnIdList[0]);
                await SignageController.getSignageTransactionList();
                Get.context!.loaderOverlay.hide();
                Get.back();
              }
            );
          },
        ),
      );
    } else {
      return const SizedBox();
    }
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

  void _showSignageSelectionDialog() {
    showSignageSelectionDialog(
      Get.context!,
      (size, type, headerLogo, discountTag) {
        _navigateToInputPage(
          Signage(
            id: const Uuid().v4(),
            txnId: txnIdList[0],
            size: size,
            type: type,
            headerLogo: headerLogo,
            discountTag: discountTag,
            listProduct: [],
            created: DateTime.now()
          )
        );
      },
    );
  }

  void _navigateToInputPage(Signage signage) async {
    isEdit.value = false;
    final result = await Navigator.push<bool>(
      Get.context!,
      MaterialPageRoute(builder: (context) => SignageInputPage(sigange: signage))
    );
    if (result == true) {
      SignageController.to.getSignagesList(txnIdList);
    }
  }

  Widget _buildSignageList(List<Signage> signages) {
    Map<String, List<Signage>> groupedSignages = {};
    for (var signage in signages) {
      String key = '${signage.size.asString}${signage.type.asString}'
          '${signage.discountTag ? "_discount" : "_regular"}'
          '${signage.headerLogo ? "_withHeader" : "_noHeader"}';
      if (!groupedSignages.containsKey(key)) {
        groupedSignages[key] = [];
      }
      groupedSignages[key]!.add(signage);
    }

    var sortedKeys = groupedSignages.keys.toList()..sort();

    return ListView.builder(
      controller: SignagesListController.to.scrollController,
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        String groupKey = sortedKeys[index];
        List<Signage> groupSignages = groupedSignages[groupKey]!;
        return _buildSignageGroup(groupKey, groupSignages);
      },
    );
  }

  Widget _buildSignageGroup(String groupKey, List<Signage> groupSignages) {
    List<String> keyParts = groupKey.split('_');
    String sizeType = keyParts[0];
    bool isDiscount = keyParts[1] == "discount";
    bool hasHeader = keyParts[2] == "withHeader";

    // แยก size และ type จาก sizeType
    String sizeString = sizeType.substring(0, 2); // เช่น 'a3', 'a4', 'a5', 'a6'
    String typeString = sizeType.substring(2);    // เช่น 'd1', 'd2', 'd3', ...

    // แปลง string เป็น enum
    SignageSize size = SignageSize.values.firstWhere(
      (e) => e.asString == sizeString,
      orElse: () => SignageSize.a3 // default value
    );
    SignageType type = SignageType.values.firstWhere(
      (e) => e.asString == typeString,
      orElse: () => SignageType.d1 // default value
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '$sizeType ${isDiscount ? "ตัดราคา" : ""} ${hasHeader ? "" : "ไม่มีหัวป้าย"}',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              const Expanded(child: SizedBox()),
              Visibility(
                visible: SignageController.signageTransaction.value.status == SignageStatus.pending,
                child: InkWell(
                  onTap: () {
                    _navigateToInputPage(
                      Signage(
                        id: '', 
                        txnId: txnIdList[0], 
                        size: size, 
                        type: type, 
                        headerLogo: hasHeader,
                        discountTag: isDiscount,
                        listProduct: [], 
                        created: DateTime.now()
                      )
                    );
                  },
                  child: const Icon(Icons.add_rounded),
                ),
              )
            ],
          ),
        ),
        ...groupSignages.asMap().entries.map((entry) {
          int index = entry.key;
          Signage signage = entry.value;
          return _buildSignageItem(signage, isFirstInGroup: index == 0);
        }),
        const SizedBox(height: 16)
      ],
    );
  }

  Widget _buildSignageItem(Signage signage, {required bool isFirstInGroup}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductTable(signage, showHeader: isFirstInGroup),
        ],
      ),
    );
  }

  Widget _buildProductTable(Signage signage, {required bool showHeader}) {
    final NumberFormat priceFormat = NumberFormat("#,##0.00", "th_TH");
    TextStyle titleStyle = const TextStyle(fontWeight: FontWeight.w500);
    TextStyle contentStyle = TextStyle(fontSize: 14.sp);

    List<TableRow> tableRows = [];

    if (showHeader) {
      tableRows.add(
        TableRow(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5)
            )
          ),
          children: [
            TableCell(
              child: Text('รหัส', 
                style: titleStyle, 
                textAlign: TextAlign.center,
              )
            ),
            TableCell(
              child: Text('ชื่อสินค้า', 
                style: titleStyle, 
                textAlign: TextAlign.center,
              )
            ),
            if (signage.discountTag) TableCell(
              child: Text('ตัด', 
                style: titleStyle, 
                textAlign: TextAlign.center,
              )
            ),
            TableCell(
              child: Text('ราคา', 
                style: titleStyle, 
                textAlign: TextAlign.center,
              )
            ),
          ],
        )
      );
    }

    tableRows.addAll(signage.listProduct.map((product) => TableRow(
      children: [
        TableCell(
          child: FittedBox(
            alignment: Alignment.center,
            fit: BoxFit.scaleDown,
            child: Text(product.art, 
              style: contentStyle,
            ),
          ),
        ),
        TableCell(
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(product.dscr, 
              style: contentStyle
            ),
          )
        ),
        if (signage.discountTag) TableCell(
          child: FittedBox(
            alignment: Alignment.centerRight,
            fit: BoxFit.scaleDown,
            child: Text(
              product.originalPrice != null 
                ? priceFormat.format(product.originalPrice)
                : '',
              style: contentStyle.copyWith(color: Colors.red),
              textAlign: TextAlign.end
            ),
          ),
        ),
        TableCell(
          child: FittedBox(
            alignment: Alignment.centerRight,
            fit: BoxFit.scaleDown,
            child: Text(
              priceFormat.format(product.displayPrice),
              style: contentStyle,
              textAlign: TextAlign.end
            ),
          ),
        ),
      ],
    )));

    return Obx(() => Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  if (isEdit.value) {
                    Get.overlayContext?.loaderOverlay.show();
                    print(signage.toRTDB());
                    _navigateToInputPage(signage);
                  }
                },
                child: Table(
                  border: TableBorder.all(borderRadius: BorderRadius.circular(5)),
                  columnWidths: {
                    0: FlexColumnWidth(signage.discountTag ? 1 : 1),
                    1: FlexColumnWidth(signage.discountTag ? 2.8 : 3.9),
                    2: FlexColumnWidth(signage.discountTag ? 1.1 : 1.1),
                    if (signage.discountTag) 3: const FlexColumnWidth(1.1),
                  },
                  children: tableRows,
                ),
              ),
            ),
            Visibility(
              visible: isEdit.value,
              child: InkWell(
                onTap: () => _showDeleteSignageDialog(signage.id),
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.delete, color: Colors.red,),
                )
              ),
            )
          ],
        ));
  }

  void showSignageSelectionDialog(BuildContext context, Function(SignageSize, SignageType, bool, bool) onSignageSelected) {
    Get.dialog(
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: SignageSelectionDialog(onSignageSelected: onSignageSelected),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showDeleteSignageDialog(String id) {
    MyAlertDialog.showDefaultDialog(
      title: 'ลบป้ายนี้',
      content: 'ต้องการลบป้ายนี้ใช่หรือไม่',
      isNoButton: true,
      onPressYes: () async {
        await SignageController.deleteSignage(id);
        Get.back();
      },
    );
  }
}

class SignagesListController extends GetxController {
  static SignagesListController get to => Get.find();
  
  final ScrollController scrollController = ScrollController();
  final RxBool showFloatingButton = true.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      showFloatingButton.value = false;
    } else {
      showFloatingButton.value = true;
    }
  }
}

