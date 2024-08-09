import 'package:alc_mobile_app/component/appbar.dart';
import 'package:alc_mobile_app/component/barcode_input.dart';
import 'package:alc_mobile_app/component/button.dart';
import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:alc_mobile_app/controller/firebase_controller.dart';
import 'package:alc_mobile_app/model/product_data_model.dart';
import 'package:alc_mobile_app/model/rail_card_model.dart';
import 'package:alc_mobile_app/service/barcode_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RailCardPage extends StatefulWidget {
  const RailCardPage({super.key});

  @override
  State<RailCardPage> createState() => _RailCardPageState();
}

class _RailCardPageState extends State<RailCardPage> {
  final GlobalKey<BarcodeInputState> _inputBarcodeKey = GlobalKey<BarcodeInputState>();
  final AuthController authController = Get.find();
  String previewArticle = '';
  String previewDescription = '';
  bool isShowPreviewPanel = false;

  @override
  Widget build(BuildContext context) {
    FirebaseController.getRailCardListByNickname();
    return Scaffold(
      appBar: const MyAppBar(
        title: 'ขอเรียวการ์ด',
        popupMenu: SizedBox.shrink(),
        color1: Color(0xFFFF416C),
        color2: Color(0xFF8A52E9)
      ),
      body: Obx(() {
        return Column(
          children: [
            railCardList(),
            previewPanel(),
            inputBarcodeField()
          ],
        );
      }),
    );
  }

  Widget railCardList() {
    List<RailCard> railCardList = FirebaseController.railCardListDataByNickname;
    if (railCardList.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('ยังไม่มีรายการเรียลการ์ด'),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: railCardList.length,
          itemBuilder: (BuildContext context, int index) {
            RailCard railCard = railCardList[index];
            return Column(
              children: [
                ListTile(
                  title: Text(railCard.art),
                  subtitle: Text(railCard.dscr),
                  trailing: CircleAvatar(
                    backgroundColor: Colors.red[300],
                    child: Text(railCard.qty.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 0.5, indent: 10, endIndent: 10),
              ],
            );
          },
        )
      );
    }
  }

  void clearInputField() {
    setState(() {
      isShowPreviewPanel = false;
    });
    _inputBarcodeKey.currentState?.barcodeController.clear();
  }

  Widget previewPanel() {
    return Visibility(
      visible: isShowPreviewPanel,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ListTile(
          title: Text(previewArticle),
          subtitle: Text(previewDescription),
          trailing: AlcMobileButton(
            color: Colors.green,
            onPressed: () async {
              await FirebaseController.insertRailCard(
                RailCard(art: previewArticle, dscr: previewDescription, qty: 1)
              );
              clearInputField();
            },
            text: 'บันทึก',
          )
        ),
      ),
    );
  }

  Widget inputBarcodeField() {
    return BarcodeInput(
      key: _inputBarcodeKey,
      onPressedBuntton: (String? barcode) async {
        clearInputField();
        if (barcode != null) {
          Product? product = await FirebaseController.getProduct(barcode);
          if (product != null) {
            await FirebaseController.insertRailCard(
              RailCard(art: product.art, dscr: product.dscr, qty: 1)
            );
          } else {
            MyAlertDialog.showDefaultDialog(
              title: 'เกิดข้อผิดพลาด',
              content: 'สแกนบาร์โค้ด ผิดพลาด\nหรือไม่พบสินค้านี้ในฐานข้อมูล\nกรุณาลองอีกครั้ง'
            );
          }
        } else {
          MyAlertDialog.showDefaultDialog(
            title: 'เกิดข้อผิดพลาด',
            content: 'สแกนบาร์โค้ด ผิดพลาด กรุณาลองอีกครั้ง'
          );
        }
      }, 
      onInputChange: (String value) async {
        if (value.isNotEmpty) {
          String article = BarcodeService.convertToArticle(value);
          Product? product = await FirebaseController.getProduct(article);
          setState(() {
            if (product != null) {
              previewArticle = product.art;
              previewDescription = product.dscr;
              isShowPreviewPanel = true;
            } else {
              isShowPreviewPanel = false;
            }
          });
        } else {
          setState(() {
            isShowPreviewPanel = false;
          });
        }
      }
    );
  }
}