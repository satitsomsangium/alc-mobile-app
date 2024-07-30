/* import 'package:alc_mobile_app/Screens/StockCount/BarcodeGen_Screen.dart';
import 'package:alc_mobile_app/database/manage_db.dart';
import 'package:alc_mobile_app/database/Model/AlertDialog.dart';
import 'package:alc_mobile_app/database/transection_db.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class StockcountData extends StatefulWidget {
  final String aisle, bay, div, status;
  StockcountData(this.aisle, this.bay, this.div, this.status);

  @override
  _StockcountDataState createState() => _StockcountDataState();
}

class _StockcountDataState extends State<StockcountData> {
  AudioCache audioCache = AudioCache();
  var stdb;
  List values;
  final stockcountController = TextEditingController();
  final EditqtyController = TextEditingController();
  String converttokey;
  bool prepanal = false,
      prepanalmutation = false,
      animateprepanal = false,
      animateprepanalmut = false,
      txteditpanal = true,
      popmenupanal = true,
      popmenupanalClosebay = false,
      closebaymenupanal = false,
      savebutton = true;
  String preart = '', predescr = '';
  List getdataoffline, getmutation, getmutationfinal = [];
  String aislebay;
  String baystatus;
  Color savebuttoncolor = Colors.green[400];
  String qtyvalidator = '';

  @override
  void initState() {
    super.initState();
    aislebay = '${widget.aisle}${widget.bay}';
    baystatus = widget.status;
    if (baystatus == 'ปิดเบย์แล้ว') {
      txteditpanal = false;
      popmenupanal = false;
      popmenupanalClosebay = true;
      closebaymenupanal = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          '${widget.aisle} - ${widget.bay} (${widget.div})',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: Row(
              children: [
                Text(baystatus),
                Visibility(
                  visible: popmenupanal,
                  child: PopupMenuButton<String>(
                    offset: const Offset(0, 60),
                    onSelected: choiceAction,
                    itemBuilder: (BuildContext context) {
                      return Constants.choices.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                ),
                Visibility(
                  visible: popmenupanalClosebay,
                  child: PopupMenuButton<String>(
                    offset: const Offset(0, 60),
                    onSelected: choiceActionClosebay,
                    itemBuilder: (BuildContext context) {
                      return ConstantsClosebay.choices.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: FutureBuilder(
                future: getdatalist(),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.hasData) {
                    values = snapshot.data;
                    return ListView.builder(
                      itemCount: values.length ??= 0,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            ListTile(
                                title: Text(values[index]['art'].toString()),
                                subtitle:
                                    Text(values[index]['descr'].toString()),
                                trailing: Container(
                                  height: 40,
                                  constraints: BoxConstraints(
                                      minHeight: 40, minWidth: 40),
                                  decoration: BoxDecoration(
                                      color: Colors.red[300],
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      '${values[index]['qty']}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  if (baystatus != 'ปิดเบย์แล้ว') {
                                    EditqtyDialog(
                                        context,
                                        values[index]['art'].toString(),
                                        values[index]['descr'].toString(),
                                        values[index]['qty'].toString());
                                  }
                                },
                                onLongPress: () {
                                  if (baystatus != 'ปิดเบย์แล้ว') {
                                    deleteAlertDialog(
                                        context,
                                        values[index]['art'].toString(),
                                        values[index]['descr'].toString());
                                  }
                                }),
                            Divider(
                                height: 1,
                                thickness: 0.5,
                                indent: 10,
                                endIndent: 10),
                          ],
                        );
                      },
                    );
                  } else {
                    return Column(
                      children: [
                        LinearProgressIndicator(),
                        Expanded(child: Container())
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          //mutation art
          AnimatedOpacity(
            opacity: animateprepanalmut ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 100),
            child: Visibility(
              visible: prepanalmutation,
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: getmutationfinal.length ?? 0,
                    itemBuilder: (context, int index) {
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              loadpreviewdata(
                                  getmutationfinal[index]['art'].toString());
                            },
                            title: Text(
                              '${getmutationfinal[index]['art']} ${getmutationfinal[index]['descr']}',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 10,
                              endIndent: 10),
                        ],
                      );
                    },
                  )),
            ),
          ),
          AnimatedOpacity(
            opacity: animateprepanal ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Visibility(
              visible: prepanal,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
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
                  title: Text(preart),
                  subtitle: Text(predescr),
                  trailing: Visibility(
                    visible: savebutton,
                    child: Container(
                      height: 40,
                      constraints: BoxConstraints(minHeight: 40, minWidth: 40),
                      decoration: BoxDecoration(
                          color: savebuttoncolor,
                          borderRadius: BorderRadius.circular(20)),
                      child: TextButton(
                        onPressed: () async {
                          String qty =
                              await TransactionDB().findqty(aislebay, preart);
                          if (qty != '') {
                            EditqtyDialog(context, preart, predescr, qty);
                          } else {
                            EditqtyDialog(context, preart, predescr, '');
                          }
                        },
                        child: Text(
                          'ใส่จำนวน',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: txteditpanal,
            child: Container(
              decoration: BoxDecoration(
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
              padding:
                  EdgeInsets.only(top: 10, right: 15, bottom: 10, left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TextField(
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                      maxLength: 14,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(75),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[800],
                        hintText: "สแกนหรือพิมพ์รหัสสินค้า",
                        hintStyle: TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.white60),
                      ),
                      controller: stockcountController,
                      onChanged: (value) {
                        if (stockcountController.text != '') {
                          loadpreviewdata(value);
                        } else {}
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(100)),
                    width: 40,
                    height: 40,
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    child: IconButton(
                      color: Colors.white,
                      onPressed: scanBarcodeNormal,
                      icon: Icon(
                        Icons.add,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //
          Visibility(
            visible: closebaymenupanal,
            child: Container(
              decoration: BoxDecoration(
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
              padding:
                  EdgeInsets.only(top: 10, right: 20, bottom: 10, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40,
                    constraints: BoxConstraints(minHeight: 40, minWidth: 40),
                    decoration: BoxDecoration(
                        color: savebuttoncolor,
                        borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BarcodeGenerators(
                                    widget.aisle, widget.bay, widget.div)));
                      },
                      child: Text(
                        'มูมมองบาร์โค้ด',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> getdatalist() async {
    stdb = await TransactionDB().loadAllData('${widget.aisle}${widget.bay}');
    return stdb;
  }

  Future loadpreviewdata(String value) async {
    getdataoffline = await ManageDB().getOneItemWithConvert(value) ?? [];
    if (getdataoffline.isNotEmpty) {
      prepanal = true;
      savebuttoncolor = Colors.green[400];

      if (getdataoffline[0]['div'].toString() != widget.div) {
        savebutton = false;
      } else {
        savebutton = true;
      }
      setState(() {
        preart = getdataoffline[0]['art'].toString();
        predescr = getdataoffline[0]['descr'];
        animateprepanal = true;
      });
      // ถ้ามี mutart(ลูก) ให้เอา mutart(ลูก) ไปค้น
      if (getdataoffline[0]['mutart'] != null) {
        print(getdataoffline[0]['mutart']);
        savebutton = false;
        savebuttoncolor = Colors.red[400];
        //กรณี ยิงสินค้าลัง (มีลูกแน่นอน)
        getmutation = await ManageDB()
            .getMutItem(getdataoffline[0]['mutart'], getdataoffline[0]['art']);
        //ได้ List แพ็คลังกลับมา เอาไป show ใน premut
        getmutationfinal = [];
        for (var record in getmutation) {
          getmutationfinal
              .add({"art": record['artpack'], "descr": record['descr']});
        }
        getmutationfinal.add({
          "art": getdataoffline[0]['mutart'],
          "descr": getdataoffline[0]['mutdescr']
        });
        if (getmutationfinal != []) {
          prepanalmutation = true;
          setState(() {
            animateprepanalmut = true;
          });
        } else {}
      }
      //ถ้าไม่มีให้เอาต้วเองไปค้นหา mutate
      else {
        getmutation = await ManageDB()
            .getMutItem(getdataoffline[0]['art'], getdataoffline[0]['art']);
        //ได้ List แพ็คลังกลับมา เอาไป show ใน premut
        if (getmutation != null) {
          getmutationfinal = [];
          for (var record in getmutation) {
            getmutationfinal
                .add({"art": record['artpack'], "descr": record['descr']});
          }
          if (getmutationfinal != []) {
            prepanalmutation = true;
            setState(() {
              animateprepanalmut = true;
            });
          } else {}
        }
      }
    } else {
      prepanal = false;
      animateprepanal = false;
      prepanalmutation = false;
      animateprepanalmut = false;
      setState(() {});
    }
  }

  void choiceAction(String choice) {
    if (choice == Constants.FirstItem) {
      MyAlertDialog.showalertdialog(
          context,
          'ปิดเบย์',
          'ต้องการปิดเบย์ ${widget.aisle} - ${widget.bay} ใช่หรือไม่',
          'ปิดเบย์',
          true,
          'ไม่', () async {
        await ManageDB().updateBayStatus(int.parse(widget.aisle).toString(),
            int.parse(widget.bay).toString(), '9');

        Navigator.of(context).pop();
        setState(() {
          popmenupanal = false;
          popmenupanalClosebay = true;
          txteditpanal = false;
          closebaymenupanal = true;

          baystatus = 'ปิดเบย์แล้ว';
        });
      });
    } else if (choice == Constants.SecondItem) {
      MyAlertDialog.showalertdialog(
          context,
          'ยกเลิกเบย์',
          'ต้องการยกเลิกเบย์ ${widget.aisle} - ${widget.bay} ใช่หรือไม่',
          'ตกลง',
          true,
          'ไม่', () async {
        await TransactionDB().cancelbay(aislebay);
        await ManageDB().updateBayStatus(int.parse(widget.aisle).toString(),
            int.parse(widget.bay).toString(), '0');

        Navigator.of(context).pop();
        setState(() {
          getdatalist();
          baystatus = 'ยังไม่ได้นับ';
          popmenupanal = true;
          popmenupanalClosebay = false;
          txteditpanal = true;
          closebaymenupanal = false;
        });
      });
    }
  }

  void choiceActionClosebay(String choice) {
    if (choice == ConstantsClosebay.FirstItem) {
      MyAlertDialog.showalertdialog(
          context,
          'นับเพิ่ม',
          'ต้องการนับเพิ่มในเบย์ ${widget.aisle} - ${widget.bay} ใช่หรือไม่',
          'นับเพิ่ม',
          true,
          'ไม่', () async {
        List<dynamic> checkiteminbay = await getdatalist();
        if (checkiteminbay.length == 0) {
          await ManageDB().updateBayStatus(int.parse(widget.aisle).toString(),
              int.parse(widget.bay).toString(), '0');
          Navigator.of(context).pop();
          setState(() {
            popmenupanal = true;
            popmenupanalClosebay = false;
            txteditpanal = true;
            closebaymenupanal = false;
            baystatus = 'ยังไม่ได้นับ';
          });
        } else {
          await ManageDB().updateBayStatus(int.parse(widget.aisle).toString(),
              int.parse(widget.bay).toString(), '8');

          Navigator.of(context).pop();
          setState(() {
            popmenupanal = true;
            popmenupanalClosebay = false;
            txteditpanal = true;
            closebaymenupanal = false;

            baystatus = 'กำลังนับ';
          });
        }
      });
    } else if (choice == ConstantsClosebay.SecondItem) {
      MyAlertDialog.showalertdialog(
          context,
          'ยกเลิกเบย์',
          'ต้องการยกเลิกเบย์ ${widget.aisle} - ${widget.bay} ใช่หรือไม่',
          'ตกลง',
          true,
          'ไม่', () async {
        await TransactionDB().cancelbay(aislebay);
        await ManageDB().updateBayStatus(int.parse(widget.aisle).toString(),
            int.parse(widget.bay).toString(), '0');

        Navigator.of(context).pop();
        setState(() {
          getdatalist();
          baystatus = 'ยังไม่ได้นับ';
          popmenupanal = true;
          popmenupanalClosebay = false;
          txteditpanal = true;
          closebaymenupanal = false;
        });
      });
    }
  }

  void deleteAlertDialog(context, String getart, getdescr) {
    MyAlertDialog.showalertdialog(
        context, 'ลบรายการนี้', '$getart \n$getdescr', 'ตกลง', true, 'ยกเลิก',
        () async {
      await TransactionDB().delete('${widget.aisle}${widget.bay}', getart);
      List<dynamic> checkiteminbay = await getdatalist();
      if (checkiteminbay.length == 0) {
        await ManageDB().updateBayStatus(int.parse(widget.aisle).toString(),
            int.parse(widget.bay).toString(), '0');
        setState(() {
          baystatus = 'ยังไม่ได้นับ';
        });
      }
      setState(() {});
      Navigator.of(context).pop();
    });
  }

  void EditqtyDialog(context, String getart, String getdescr, String getqty) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        EditqtyController.text = getqty;
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getart,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Center(
                    child: Text(
                      getdescr,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'จำนวน',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              SizedBox(height: 10),
              TextField(
                autofocus: true,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLength: 6,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8),
                  isDense: true,
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(75),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: 'ใส่จำนวน',
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.white60),
                ),
                controller: EditqtyController,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(75),
                              side: BorderSide(color: Colors.red)))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 60,
                    child: Center(
                      child: Text(
                        'ยกเลิก',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(75),
                              side: BorderSide(color: Colors.red)))),
                  onPressed: () async {
                    print(
                        'type of Editingcontroller ${EditqtyController.text.runtimeType}');
                    if (EditqtyController.text == '') {
                      MyAlertDialog.checkqtyDialog(
                          context, 'จำนวนต้องไม่เว้นว่าง');
                    } else if (int.parse(EditqtyController.text) < 1) {
                      MyAlertDialog.checkqtyDialog(
                          context, 'จำนวนต้องมากกว่า 0');
                    } else {
                      print('ไม่ว่าง');
                      int checkdup =
                          await TransactionDB().findDuplicate(aislebay, getart);

                      if (checkdup == 0) {
                        await TransactionDB().InsertData(
                            '${widget.aisle}${widget.bay}',
                            getart,
                            getdescr,
                            int.parse(EditqtyController.text).toString());
                        print(int.parse(EditqtyController.text).toString());
                      } else if (checkdup == 1) {
                        await TransactionDB().updateQTY(aislebay, getart,
                            int.parse(EditqtyController.text).toString());
                      }

                      await ManageDB().updateBayStatus(
                          int.parse(widget.aisle).toString(),
                          int.parse(widget.bay).toString(),
                          '8');

                      prepanal = false;
                      prepanalmutation = false;
                      stockcountController.text = '';
                      baystatus = 'กำลังนับ';
                      setState(() {});
                      Navigator.of(context).pop();
                    }
                  },
                  child: SizedBox(
                    width: 60,
                    child: Center(
                      child: Text(
                        'บันทึก',maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", 'ยกเลิก', true, ScanMode.BARCODE);
      String finalart = barcodeScanRes;
      if (int.parse(finalart) >= 0) {
        audioCache.play('audio/barcodesound.mp3');
      }
      stockcountController.clear();
      loadpreviewdata(finalart);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;
  }
}

class Constants {
  static const String FirstItem = 'ปิดเบย์';
  static const String SecondItem = 'ยกเลิกเบย์';

  static const List<String> choices = <String>[
    FirstItem,
    SecondItem,
  ];
}

class ConstantsClosebay {
  static const String FirstItem = 'นับเพิ่ม';
  static const String SecondItem = 'ยกเลิกเบย์';

  static const List<String> choices = <String>[
    FirstItem,
    SecondItem,
  ];
}
 */