import 'package:alc_mobile_app/component/barcode_input.dart';
import 'package:alc_mobile_app/component/button.dart';
import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:alc_mobile_app/controller/db_controller.dart';
import 'package:alc_mobile_app/controller/flow_controller.dart';
import 'package:alc_mobile_app/model/bay_model.dart';
import 'package:alc_mobile_app/model/product_data_model.dart';
import 'package:alc_mobile_app/screen/stock_count/barcode_gen_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';

class StockCountDataPage extends StatelessWidget {
  final String aisle;
  final String bay;
  final String div;
  final BayStatus status;
  
  StockCountDataPage(this.aisle, this.bay, this.div, this.status, {super.key});

  final GlobalKey<_InputArticlePanelState> _key = GlobalKey<_InputArticlePanelState>();
  
  @override
  Widget build(BuildContext context) {
    FlowController.fetchBayStatus(aisle, bay, div);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          '$aisle - $bay ($div)',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (FlowController.bayStatus.value == null) {
                return const LinearProgressIndicator();
              } else {
                BayStatus bayStatus = FlowController.bayStatus.value!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    topButton(bayStatus),
                    bayStatusText(bayStatus),
                    itemList(bayStatus),
                  ],
                );
              }
            }),
          ),
          InputArticlePanel(key: _key, aisle: aisle, bay: bay, div: div)
        ],
      ),
    );
  }

  Future<void> changeBayStatus(BayStatus bayStatus) async {
    FlowController.changeBayStatus(aisle, bay, div, bayStatus);
  }

  Widget topButton(BayStatus bayStatus) {
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
              if (bayStatus == BayStatus.bayClose) {
                MyAlertDialog.showDefaultDialog(
                  title: 'นับเพิ่ม',
                  content: 'ต้องการนับเพิ่มในเบย์ $aisle - $bay ใช่หรือไม่',
                  isNoButton: true,
                  textYes: 'นับเพิ่ม',
                  textNo: 'ไม่',
                  onPressYes: () async {
                    Get.back();
                    List<dynamic> checkiteminbay = await DbController.getBayDataList(aisle, bay, div);
                    if (checkiteminbay.isEmpty) {
                      changeBayStatus(BayStatus.notCount);
                    } else {
                      changeBayStatus(BayStatus.counting);
                    }
                  }
                );
              } else {
                MyAlertDialog.showDefaultDialog(
                  title: 'ปิดเบย์',
                  content: 'ต้องการปิดเบย์ $aisle - $bay ใช่หรือไม่',
                  isNoButton: true,
                  textYes: 'ปิดเบย์',
                  onPressYes: () async {
                    Get.back();
                    changeBayStatus(BayStatus.bayClose);
                  }
                );
              }
            },
            text: bayStatus == BayStatus.bayClose ? 'นับเพิ่ม' : 'ปิดเบย์',
          ),
          AlcMobileButton(
            onPressed: () {
              MyAlertDialog.showDefaultDialog(
                title: 'ยกเลิกเบย์',
                content: 'ต้องการยกเลิกเบย์ $aisle - $bay ใช่หรือไม่',
                isNoButton: true,
                textNo: 'ไม่',
                textYes: 'ยกเลิกเบย์',
                onPressYes: () async {
                  Get.back();
                  await DbController.clearBayDataList(aisle, bay, div);
                  changeBayStatus(BayStatus.notCount);
                  await DbController.getBayDataList(aisle, bay, div);
                }
              );
            },
            text: 'ยกเลิกเบย์',
          ),
          Visibility(
            visible: bayStatus == BayStatus.bayClose,
            child: AlcMobileButton(
              color: Colors.green,
              onPressed: () {
                Get.to(BarcodeGeneratorsPage(aisle, bay, div));
              }, 
              text: 'มุมมองบาร์โคด'
            ),
          )
        ],
      ),
    );
  }

  Widget bayStatusText(BayStatus bayStatus) {
    Color statusColor;
    switch (bayStatus) {
      case BayStatus.counting:
        statusColor = Colors.blue.shade300;
        break;
      case BayStatus.notCount:
        statusColor = Colors.red.shade300;
        break;
      case BayStatus.bayClose:
        statusColor = Colors.green.shade300;
        break;
      default:
        statusColor = Colors.grey.shade300;
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text('สถานะ : ${bayStatus.th}', 
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.w500, 
          color: statusColor
        ),
      ),
    );
  }

  Widget itemList(BayStatus bayStaus) {
    FlowController.getBayDataList(aisle, bay, div);
    return Expanded(
      child: Obx(() {
        List<BayData> values = FlowController.bayDataList;
        return ListView.builder(
          itemCount: values.length,
          itemBuilder: (BuildContext context, int index) {
            BayData bayData = values[index];
            return Column(
              children: [
                ListTile(
                  title: Text(bayData.art),
                  subtitle: Text(bayData.descr),
                  trailing: Container(
                    height: 40,
                    constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: bayData.qty.toStringAsFixed(3).split('.')[0],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: '.${bayData.qty.toStringAsFixed(3).split('.')[1]}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green.shade100,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (bayStaus != BayStatus.bayClose) {
                      _key.currentState?.editQtyDialog(
                        context,
                        bayData.art,
                        bayData.descr,
                        bayData.qty,
                      );
                    }
                  },
                  onLongPress: () {
                    if (bayStaus != BayStatus.bayClose) {
                      _key.currentState?.deleteAlertDialog(
                        context,
                        bayData.art,
                        bayData.descr,
                      );
                    }
                  },
                ),
                const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 10,
                    endIndent: 10),
              ],
            );
          },
        );
      },)
    );
  }
}

class InputArticlePanel extends StatefulWidget {
  final String aisle;
  final String bay;
  final String div;

  const InputArticlePanel({
    super.key,
    required this.aisle,
    required this.bay,
    required this.div,
  });

  @override
  State<InputArticlePanel> createState() => _InputArticlePanelState();
}

class _InputArticlePanelState extends State<InputArticlePanel> {
  final AudioPlayer audioPlayer = AudioPlayer();
  List values = [];
  final stockCountController = TextEditingController();
  final editQtyController = TextEditingController();
  late String converttokey;
  ProductDataMain? productMain;
  bool isShowPreviewProductDetail = false;
  bool isShowPreviewMutationProductDetail = false;
  bool isShowSaveButton = true;
  List<ProductDataMutation> mutationDataList = [];
  String qtyvalidator = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        previewMutationProductDetail(),
        previewProductDetail(),
        inputBarcodefield(),
      ],
    );
  }

  Widget previewMutationProductDetail() {
    return Visibility(
      visible: isShowPreviewMutationProductDetail,
      child: Container(
          color: Colors.red[50],
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: mutationDataList.length,
            itemBuilder: (context, int index) {
              return Column(
                children: [
                  ListTile(
                    onTap: () {
                      loadPrevieDataPanel(mutationDataList[index].art);
                    },
                    title: Text(
                      '${mutationDataList[index].art} ${mutationDataList[index].descr}',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 10,
                      endIndent: 10),
                ],
              );
            },
          )),
    );
  }

  Widget previewProductDetail() {
    return Visibility(
      visible: isShowPreviewProductDetail,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: ListTile(
          title: Text(productMain?.art ?? ''),
          subtitle: Text(productMain?.descr ?? ''),
          trailing: Visibility(
            visible: isShowSaveButton,
            child: AlcMobileButton(
              color: Colors.green,
              onPressed: () async {
                BayData? articleData = await DbController.findArtInBayDataList(widget.aisle, widget.bay, widget.div, productMain?.art ?? '');
                double qty = articleData != null ? articleData.qty : 0;
                editQtyDialog(Get.context, productMain?.art ?? '', productMain?.descr ?? '', qty);
              },
              text: 'ใ่ส่จำนวน',
            ),
          ),
        ),
      ),
    );
  }

  Widget inputBarcodefield() {
    return Obx(() {
      bool isBayClose = FlowController.bayStatus.value != BayStatus.bayClose;
      return Visibility(
        visible: isBayClose,
        child: BarcodeInput(
          onPressedBuntton: (String? barcode) {
            if(barcode != null) {
              loadPrevieDataPanel(barcode);
            }
          },
          onInputChange: (String value) {
            if (value.isNotEmpty) {
              loadPrevieDataPanel(value);
            }
          },
        ),
      );
    });
  }

  Future<void> loadPrevieDataPanel(String productCode) async {
    ProductDataMain? product = await DbController.getOneItemWithConvert(productCode);
    if (product != null) {
      productMain = product;
      isShowPreviewProductDetail = true;
      
      if (product.div != widget.div) {
        isShowSaveButton = false;
      } else {
        isShowSaveButton = true;
      }

      // ถ้ามี mutart(ลูก) ให้เอา mutart(ลูก) ไปค้น
      if (product.mutart != null && product.mutart!.isNotEmpty) {
        isShowSaveButton = false;
        
        // กรณี ยิงสินค้าลัง (มีลูกแน่นอน)
        List<ProductDataMutation> getMutationDataList = await DbController.getMutationItems(product.mutart, product.art);
        
        // ได้ List แพ็คลังกลับมา เอาไป show ใน premut
        mutationDataList = [];
        for (ProductDataMutation productDataMutation in getMutationDataList) {
          mutationDataList.add(ProductDataMutation(
            dept: '', 
            grp: '', 
            art: productDataMutation.artpack, 
            descr: productDataMutation.descr, 
            artpack: ''
          ));
        }
        mutationDataList.add(ProductDataMutation(
          dept: '', 
          grp: '', 
          art: product.mutart!, 
          descr: product.mutdescr!, 
          artpack: ''
        ));

        if (mutationDataList.isNotEmpty) {
          isShowPreviewMutationProductDetail = true;
        }
      }
      // ถ้าไม่มีให้เอาตัวเองไปค้นหา mutate
      else {
        List<ProductDataMutation> getMutationDataList = await DbController.getMutationItems(product.art, product.art);
        // ได้ List แพ็คลังกลับมา เอาไป show ใน premut
        if (getMutationDataList.isNotEmpty) {
          mutationDataList = [];
          for (ProductDataMutation productDataMutation in getMutationDataList) {
            mutationDataList.add(ProductDataMutation(
              dept: '', 
              grp: '', 
              art: productDataMutation.artpack, 
              descr: productDataMutation.descr, 
              artpack: ''
            ));
          }

          if (mutationDataList.isNotEmpty) {
            isShowPreviewMutationProductDetail = true;
          }
        }
      }

      setState(() {});
    } else {
      isShowPreviewProductDetail = false;
      isShowPreviewMutationProductDetail = false;
      setState(() {});
    }
  }

  void deleteAlertDialog(context, String getart, getdescr) {
    MyAlertDialog.showalertdialog(
        context, 'ลบรายการนี้', '$getart \n$getdescr', 'ตกลง', true, 'ยกเลิก',
        () async {
      await DbController.removeBayDataFromBayDataList(widget.aisle, widget.bay, widget.div, getart);
      List<BayData> checkiteminbay = await DbController.getBayDataList(widget.aisle, widget.bay, widget.div);
      if (checkiteminbay.isEmpty) {
        await FlowController.changeBayStatus(widget.aisle, widget.bay, widget.div, BayStatus.notCount);
      }
      await FlowController.getBayDataList(widget.aisle, widget.bay, widget.div);
      Navigator.of(context).pop();
    });
  }

  void editQtyDialog(context, String article, String descr, double qty) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        String qtyString;
        if (qty == 0.0) {
          qtyString = '';
        } else if (qty == qty.roundToDouble()) {
          qtyString = qty.toInt().toString();
        } else {
          qtyString = qty.toString();
        }
        editQtyController.text = qtyString;
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(article, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(descr, style: const TextStyle(fontSize: 16))
                ],
              ),
              const SizedBox(height: 10),
              const Text('จำนวน', style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              const SizedBox(height: 10),
              TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLength: 10,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(8),
                  isDense: true,
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(75),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: 'ใส่จำนวน',
                  hintStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white60),
                ),
                controller: editQtyController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,3}'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AlcMobileButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'ยกเลิก',
                ),
                const SizedBox(width: 10),
                AlcMobileButton(
                  onPressed: () async {
                    if (editQtyController.text.isEmpty) {
                      MyAlertDialog.checkqtyDialog(context, 'จำนวนต้องไม่เว้นว่าง');
                    } else {
                      double? quantity;
                      try {
                        quantity = double.parse(editQtyController.text);
                        if (quantity < 1) {
                          MyAlertDialog.checkqtyDialog(context, 'จำนวนต้องมากกว่า 0');
                          return;
                        }
                      } catch (e) {
                        MyAlertDialog.checkqtyDialog(context, 'จำนวนไม่ถูกต้อง');
                        return;
                      }

                      BayData newBayData = BayData(
                        art: article,
                        descr: descr,
                        qty: quantity,
                      );

                      BayData? existingBayData = await DbController.findArtInBayDataList(
                        widget.aisle,
                        widget.bay,
                        widget.div,
                        article,
                      );

                      if (existingBayData != null) {
                        await DbController.updateBayData(
                          widget.aisle,
                          widget.bay,
                          widget.div,
                          newBayData,
                        );
                        FlowController.getBayDataList(widget.aisle, widget.bay, widget.div);
                      } else {
                        await DbController.addBayDataToBayDataList(
                          widget.aisle,
                          widget.bay,
                          widget.div,
                          newBayData,
                        );
                        FlowController.getBayDataList(widget.aisle, widget.bay, widget.div);
                      }

                      isShowPreviewProductDetail = false;
                      isShowPreviewMutationProductDetail = false;
                      stockCountController.text = '';
                      setState(() {});
                      Get.back();
                    }
                  },
                  text: 'บันทึก',
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> playBarcodeSound() async {
    await audioPlayer.play(AssetSource('audio/barcodesound.mp3'));
  }

  Future<void> scanBarcodeNormal() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", 'ยกเลิก', true, ScanMode.BARCODE);
      if (int.parse(barcodeScanRes) >= 0) {
        await playBarcodeSound();
      }
      stockCountController.clear();
      loadPrevieDataPanel(barcodeScanRes);
    } catch (e) {
      debugPrint(e.toString());
    }

    if (!mounted) return;
  }
}