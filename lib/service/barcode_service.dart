import 'dart:async';

import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:alc_mobile_app/service/barcode/barcode_scanner_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';

class BarcodeService extends GetxController {
  static BarcodeService get to => Get.find();

  static BarcodeService init({String? tag, bool permanent = false}) =>
      Get.put(BarcodeService(), tag: tag, permanent: permanent);

  static final AudioPlayer audioPlayer = AudioPlayer();
  
  static Future<String?> scanAndConvert({ 
    String lineColor = '', 
    String cancelButtonText = 'ยกเลิก', 
    bool isShowFlashIcon = true,
    ScanMode scanMode = ScanMode.BARCODE
  }) async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(lineColor, cancelButtonText, isShowFlashIcon, scanMode);
      String finalArt = convertToArticle(barcodeScanRes);
      if (int.parse(finalArt) >= 0) {
        await playBarcodeSound();
        return finalArt;
      }
    } on PlatformException {
      MyAlertDialog.showDefaultDialog(
        title: 'เกิดข้อผิดพลาด',
        content: 'ไม่สามารถสแกน ${scanMode != ScanMode.QR ? 'barcode' : 'qr code'} ได้ กรุณาลองอีกครั้ง'
      );
    }
    return null;
  }

  static Future<void> playBarcodeSound() async {
    await audioPlayer.play(AssetSource('audio/barcodesound.mp3'));
  }

  static Future<String?> scanAndConvertV2() async {
    try {
      final result = await Navigator.push(
        Get.context!,
        MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
      );
      if (result != null) {
        String finalArt = convertToArticle(result);
        if (int.tryParse(finalArt) != null && int.parse(finalArt) >= 0) {
          await playBarcodeSound();
          return finalArt;
        }
      }
    } catch (e) {
      MyAlertDialog.showDefaultDialog(
        title: 'เกิดข้อผิดพลาด',
        content: 'ไม่สามารถสแกนบาร์โค้ดได้ กรุณาลองอีกครั้ง'
      );
    }
    return null;
  }

  static String convertToArticle(String barcode) {
    String convertToKey = '';
    if (barcode.isEmpty) {
      return "";
    } else if (barcode.length == 13 && barcode.startsWith("25")) {
      convertToKey = barcode.substring(6, 12);
    } else if (barcode.length == 8 && barcode.startsWith("2")) {
      convertToKey = barcode.substring(1, 7);
    } else if (barcode.length == 13 && (barcode.startsWith("21") || barcode.startsWith("28") || barcode.startsWith("29"))) {
      convertToKey = "${barcode.substring(0, 6)}0000000";
    } else {
      convertToKey = barcode;
    }
    return convertToKey.startsWith("0") && convertToKey.length == 6 ? int.parse(convertToKey).toString() : convertToKey;
  }
}