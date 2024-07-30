import 'dart:async';
import 'package:alc_mobile_app/component/appbar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class CheckPricePage extends StatefulWidget {
  const CheckPricePage({super.key});

  @override
  State<CheckPricePage> createState() => _CheckPricePageState();
}

class _CheckPricePageState extends State<CheckPricePage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
  final TextEditingController checkPriceController = TextEditingController();
  final int currentDay = DateTime.now().day;

  String description = 'xxxxxxxx';
  String article = 'XXXXXX';
  String price = 'XXX';
  String dateModified = '';
  String dateModifiedStatus = '';
  String updateStatus = '';
  String convertToKey = '';
  Color colorStatus = Colors.black87;
  bool isVisible = false, isPricePanelVisible = true;

  @override
  void initState() {
    super.initState();
    getDateModified();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    checkPriceController.dispose();
    super.dispose();
  }

  void getDateModified() {
    firebaseDatabase.ref().child("1").child('datemodified').get().then((DataSnapshot snapshot) {
      if (snapshot.exists && snapshot.value is String) {
        dateModified = snapshot.value as String;
        dateModifiedStatus = 'อัปเดตราคาล่าสุด : $dateModified';
        if (dateModified.substring(2, (dateModified.indexOf('/'))) != currentDay.toString()) {
          colorStatus = Colors.red;
          updateStatus = 'กรุณาแจ้ง ALC อัปเดตราคา';
        } else if (dateModified.substring((dateModified.indexOf(':') - 2), (dateModified.indexOf(':'))) == '05' &&
            dateModified.substring((dateModified.indexOf(':') + 1), (dateModified.indexOf(':') + 3)) == '40') {
          colorStatus = Colors.yellow[800]!;
          updateStatus = 'วันนี้ยังไม่มีการปรับราคา';
        } else {
          colorStatus = Colors.lightGreen;
          updateStatus = 'อัปเดตแล้ว';
        }
        setState(() {
          isVisible = !isVisible;
        });
      }
    });
  }

  void getDataFromFirebase(String artNum) {
    firebaseDatabase.ref().child('0').child(artNum).child('0').get().then((DataSnapshot snapshot) {
      var formatter = NumberFormat("###,###.##", 'en_US');
      if (snapshot.exists && snapshot.value != null) {
        var data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          description = data['dscr'].toString();
          article = data['art'].toString();
          price = formatter.format(int.parse(data['price'].toString()));
          isPricePanelVisible = true;
        });
      } else {
        setState(() {
          description = 'xxxxxxxx';
          article = 'XXXXXX';
          price = 'XXX';
          isPricePanelVisible = false;
        });
      }
    });
  }

  Future<void> playBarcodeSound() async {
    await audioPlayer.play(AssetSource('audio/barcodesound.mp3'));
  }


  Future<void> scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "ยกเลิก", true, ScanMode.BARCODE);
      String finalArt = convertToArt(barcodeScanRes);
      if (int.parse(finalArt) >= 0) {
        await playBarcodeSound();
      }
      getDataFromFirebase(finalArt);
    } on PlatformException {
      // Handle the exception
    }
  }

  String convertToArt(String barcode) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'เช็คราคา', 
        popupMenu: SizedBox.shrink(),
        color1: Color(0xFFFF7765),
        color2: Color(0xFFF7A23C)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 30),
                  child: Text(
                    description,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  article,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Container(
                  color: Colors.yellow[200],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('   ', style: TextStyle(fontSize: 40)),
                          Text(
                            price,
                            style: TextStyle(fontSize: 50, color: Colors.redAccent[700], fontWeight: FontWeight.bold),
                          ),
                          const Text(' .-', style: TextStyle(fontSize: 40))
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        dateModifiedStatus,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        updateStatus,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorStatus),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black12, width: 0.3)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 2),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                    maxLength: 14,
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
                      hintText: "สแกนหรือพิมพ์รหัสสินค้า",
                      hintStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white60),
                    ),
                    controller: checkPriceController,
                    onChanged: (value) {
                      setState(() {
                        description = 'xxxxxxxx';
                        article = 'XXXXXX';
                        price = 'XXX';
                      });
                      getDataFromFirebase(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(100)),
                  width: 40,
                  height: 40,
                  child: IconButton(
                    onPressed: () {
                      scanBarcode();
                      checkPriceController.clear();
                    },
                    icon: const Icon(Icons.add, size: 25, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}