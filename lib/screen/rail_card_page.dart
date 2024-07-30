import 'package:alc_mobile_app/component/appbar.dart';
import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class RailCardPage extends StatefulWidget {
  const RailCardPage({super.key});

  @override
  State<RailCardPage> createState() => _RailCardPageState();
}

class _RailCardPageState extends State<RailCardPage> {
  final AuthController authController = Get.find();
  final AudioPlayer audioPlayer = AudioPlayer();
  final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
  final TextEditingController railcardController = TextEditingController();
  String description = '', article = '', date = '', time = '';
  int quantity = 0, dataQuantity = 0;
  List<dynamic> values = [], listArticle = [], listQuantity = [], filterData = [];
  String previousArticle = '', previousDescription = '';
  String convertToKey = '';
  int length = 0;
  bool isPreviewPanelVisible = false, isListPanelVisible = false;

  void previewData(String articleNumber) async {
    DataSnapshot snapshot = await firebaseDatabase.ref().child("0").child(articleNumber).child('0').get();
    if (snapshot.exists && snapshot.value != null) {
      var data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        previousArticle = data['art'].toString();
        previousDescription = data['dscr'].toString();
        isPreviewPanelVisible = true;
      });
    } else {
      setState(() {
        isPreviewPanelVisible = false;
      });
    }
  }

  void saveButtonClick() async {
    DateTime now = DateTime.now();
    String formattedDate = '${now.day}/${now.month}/${now.year}';
    String formattedTime = '${now.hour}:${now.minute}:${now.second}';

    // Get Railcard list
    DataSnapshot dataSnapshot = await firebaseDatabase.ref().child('Railcard').get();
    print('xxxxxxxxxx ${dataSnapshot.value}');
    if (dataSnapshot.exists && dataSnapshot.value != null) {
      print('xxxxxxxxxx dataSnapshot.exists && dataSnapshot.value != null ${dataSnapshot.value}');
      var data = dataSnapshot.value as List<dynamic>;
      length = data.length;
      listArticle = [];
      listQuantity = [];
      for (var item in data) {
        listArticle.add(item['art']);
        listQuantity.add(item['qty']);
      }
    } else {
      print('xxxxxxxxxx length = 0; ${dataSnapshot.value}');
      length = 0;
    }

    String nickname = authController.nickname.value;
    String date = formattedDate;
    String time = formattedTime;
    int qty = 1;

    if (previousArticle.isNotEmpty) {
      print('xxxxxxxxxx previousArticle.isNotEmpty ${previousArticle.toString()}');
      int index = listArticle.indexOf(previousArticle);

      // ถ้าเช็คแล้ว art ไม่ซ้ำให้สร้างรายการใหม่
      if (index < 0) {
        await firebaseDatabase.ref().child('Railcard').child('$length').set({
          'art': previousArticle,
          'dscr': previousDescription,
          'nickname': nickname,
          'date': date,
          'time': time,
          'qty': qty,
        });
      } else {
        int updatedQuantity = listQuantity[index] + 1;
        await firebaseDatabase.ref().child('Railcard').child('$index').update({
          'qty': updatedQuantity,
          'nickname': nickname,
        });
      }

      setState(() {
        isPreviewPanelVisible = false;
      });
      railcardController.clear();
    } else {
      print('xxxxxxxxxx previousArticle.isEmpty ${previousArticle.toString()}');
    }
  }

  void getDataFromFirebase(String articleNumber) async {
    DateTime now = DateTime.now();
    String formattedDate = '${now.day}/${now.month}/${now.year}';
    String formattedTime = '${now.hour}:${now.minute}:${now.second}';

    // Get Railcard list
    DataSnapshot snapshot = await firebaseDatabase.ref().child('Railcard').get();
    if (snapshot.exists && snapshot.value != null) {
      var data = snapshot.value as List<dynamic>;
      length = data.length;
      listArticle = [];
      listQuantity = [];
      for (var item in data) {
        listArticle.add(item['art']);
        listQuantity.add(item['qty']);
      }
    } else {
      length = 0;
    }

    // Get item data
    DataSnapshot itemSnapshot = await firebaseDatabase.ref().child("0").child(articleNumber).child('0').get();
    if (itemSnapshot.exists && itemSnapshot.value != null) {
      var data = itemSnapshot.value as Map<dynamic, dynamic>;
      int index = listArticle.indexOf(data['art'].toString());
      if (index < 0) {
        await firebaseDatabase.ref().child('Railcard').child('$length').set({
          'art': data['art'].toString(),
          'dscr': data['dscr'].toString(),
          'nickname': authController.nickname.value,
          'date': formattedDate,
          'time': formattedTime,
          'qty': 1,
        });
      } else {
        int updatedQuantity = listQuantity[index] + 1;
        await firebaseDatabase.ref().child('Railcard').child('$index').update({
          'qty': updatedQuantity,
          'nickname': authController.nickname.value,
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: 'สินค้านี้ไม่มีในระบบ',
        gravity: ToastGravity.CENTER,
      );
    }
    setState(() {});
  }

  String convertToArticle(String barcode) {
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

  Future<void> scanBarcode() async {
    try {
      String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.BARCODE,
      );
      String finalArticle = convertToArticle(barcodeScanResult);
      if (int.parse(finalArticle) >= 0) {
        await audioPlayer.play(AssetSource('audio/barcodesound.mp3'));
      }
      getDataFromFirebase(finalArticle);
    } on PlatformException {
      Fluttertoast.showToast(
        msg: 'Failed to get platform version.',
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    railcardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'ขอเรียวการ์ด',
        popupMenu: SizedBox.shrink(),
        color1: Color(0xFFFF416C),
        color2: Color(0xFF8A52E9)),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: firebaseDatabase.ref().child("Railcard").get(),
              builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  var data = snapshot.data!.value;
                  if (data is List<dynamic>) {
                    filterData = data.where((item) => item['nickname'].toString() == authController.nickname.value).toList();
            
                    return ListView.builder(
                      itemCount: filterData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(filterData[index]['art'].toString()),
                              subtitle: Text(filterData[index]['dscr'].toString()),
                              trailing: CircleAvatar(
                                backgroundColor: Colors.red[300],
                                child: Text(
                                  filterData[index]['qty'].toString(),
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
                    );
                  } else if (data is Map<dynamic, dynamic>) {
                                          filterData = data.values.where((item) => item['nickname'].toString() == authController.nickname.value).toList();
            
                    return ListView.builder(
                      itemCount: filterData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(filterData[index]['art'].toString()),
                              subtitle: Text(filterData[index]['dscr'].toString()),
                              trailing: CircleAvatar(
                                backgroundColor: Colors.red[300],
                                child: Text(
                                  filterData[index]['qty'].toString(),
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
                    );
                  } else {
                    return const Center(child: Text(''));
                  }
                } else {
                  return const Center(child: Text('Loading...'));
                }
              },
            ),
          ),
          AnimatedOpacity(
            opacity: isPreviewPanelVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 100),
            child: Visibility(
              visible: isPreviewPanelVisible,
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
                  title: Text(previousArticle),
                  subtitle: Text(previousDescription),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      borderRadius: BorderRadius.circular(100),
                    ),
                    width: 40,
                    height: 40,
                    child: IconButton(
                      color: Colors.white,
                      onPressed: saveButtonClick,
                      icon: const Icon(
                        Icons.save,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.black12, width: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 10, right: 15, bottom: 10, left: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: TextField(
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
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
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white60,
                      ),
                    ),
                    controller: railcardController,
                    onChanged: (value) {
                      if (railcardController.text.isNotEmpty) {
                        previewData(convertToArticle(value));
                      } else {
                        setState(() {
                          isPreviewPanelVisible = false;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  width: 40,
                  height: 40,
                  child: IconButton(
                    color: Colors.white,
                    onPressed: scanBarcode,
                    icon: const Icon(
                      Icons.add,
                      size: 25,
                      color: Colors.white,
                    ),
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