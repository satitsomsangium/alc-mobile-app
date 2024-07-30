/* import 'package:alc_mobile_app/database/manage_db.dart';
import 'package:alc_mobile_app/database/Model/AlertDialog.dart';
import 'package:flutter/material.dart';

class Custombay extends StatefulWidget {
  @override
  _CustombayState createState() => _CustombayState();
}

class _CustombayState extends State<Custombay> {
  String dropdownValue = 'เลือกแผนก';
  final AisleController = TextEditingController();
  final BayStartController = TextEditingController();
  final BayEndController = TextEditingController();
  List values;
  Color divcolor = Colors.red[300];

  Future<List<dynamic>> getbay() async {
    List<dynamic> baydata = await ManageDB().getAllData('AisleBay');
    return baydata;
  }

  Future<List<dynamic>> gettocheckbay() async {
    List<dynamic> baydata = await ManageDB().getAllbayData();
    return baydata;
  }

  Widget Headtxt(String txt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          txt,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }

  void choiceAction(String choice) {
    if (choice == popmenuCustomBay.FirstItem) {
      MyAlertDialog.showalertdialog(
          context,
          'ลบเบย์ทั้งหมด',
          'การดำเนินการนี้จะลบเบย์และข้อมูลในเบย์ที่บันทึกไว้ทั้งหมด',
          'ตกลง',
          true,
          'ยกเลิก', () async {
        Navigator.of(context).pop();
        MyAlertDialog.loadingdialog(context, 'กรุณารอสักครู่');
        await ManageDB().deleteStore('AisleBay');
        await new Future.delayed(const Duration(seconds: 15));
        Navigator.of(context).pop();
        setState(() {});
      });
    } else if (choice == popmenuCustomBay.SecondItem) {
      MyAlertDialog.showalertdialog(
          context,
          'เซ็ตเบย์ตามค่าเริ่มต้น',
          'การดำเนินการนี้จะลบเบย์และข้อมูลในเบย์ที่บันทึกไว้ทั้งหมด',
          'ตกลง',
          true,
          'ยกเลิก', () async {
        Navigator.of(context).pop();
        MyAlertDialog.loadingdialog(context, 'กรุณารอสักครู่');
        await ManageDB().deleteStore('AisleBay');
        await ManageDB().getAisleBayfirebase();
        await new Future.delayed(const Duration(seconds: 15));
        Navigator.of(context).pop();
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'เพิ่มเบย์แบบกำหนดเอง',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PopupMenuButton<String>(
              offset: const Offset(0, 60),
              onSelected: choiceAction,
              itemBuilder: (BuildContext context) {
                return popmenuCustomBay.choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 20,
              elevation: 8,
              underline: Container(
                height: 2,
                color: Colors.red[300],
              ),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items: <String>['เลือกแผนก', 'FV', 'BU', 'FI', 'BK', 'FZ']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              isExpanded: true,
            ),
            Headtxt('Aisle'),
            TextField(
              textInputAction: TextInputAction.next,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              maxLength: 3,
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
                hintText: "Aisle",
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.white60),
              ),
              controller: AisleController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Headtxt('Start Bay'),
                SizedBox(
                  width: 20,
                ),
                Headtxt('End Bay'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: TextField(
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                    maxLength: 3,
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
                      hintText: "Start Bay",
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.white60),
                    ),
                    controller: BayStartController,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                    maxLength: 3,
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
                      hintText: "End Bay",
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.white60),
                    ),
                    controller: BayEndController,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                onPressed: savePress,
                padding: EdgeInsets.fromLTRB(30, 4, 30, 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(75)),
                color: Colors.red,
                textTheme: ButtonTextTheme.primary,
                child: Text(
                  'บันทึก',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow()]),
                child: FutureBuilder(
                  future: getbay(),
                  builder:
                      (BuildContext context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.hasData) {
                      values = snapshot.data;
                      return ListView.builder(
                        itemCount: values.length ??= 0,
                        itemBuilder: (BuildContext context, int index) {
                          if (values[index]['div'].toString() == 'FV') {
                            divcolor = Colors.blue[50];
                          } else if (values[index]['div'].toString() == 'BU') {
                            divcolor = Colors.red[50];
                          } else if (values[index]['div'].toString() == 'FI') {
                            divcolor = Colors.green[50];
                          } else if (values[index]['div'].toString() == 'BK') {
                            divcolor = Colors.orange[50];
                          } else if (values[index]['div'].toString() == 'FZ') {
                            divcolor = Colors.purple[50];
                          }
                          return Container(
                            color: divcolor,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '${values[index]['div']} - ${values[index]['aisle']} - ${values[index]['bay']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    indent: 10,
                                    endIndent: 10),
                              ],
                            ),
                          );
                          ;
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
          ],
        ),
      ),
    );
  }

  savePress() async {
    Map currentdata;
    if (AisleController.text == '' ||
        BayStartController.text == '' ||
        BayEndController.text == '') {
      MyAlertDialog.showalertdialog(context, 'ข้อมูลไม่ถูกต้อง',
          'กรุณากรอกข้อมูลให้ครบ ก่อนบันทึกข้อมูล', 'ตกลง', false, '', () {
        Navigator.of(context).pop();
      });
    } else if (dropdownValue == 'เลือกแผนก') {
      MyAlertDialog.showalertdialog(context, 'ข้อมูลไม่ถูกต้อง',
          'กรุณาเลือกแผนกก่อนบันทึกข้อมูล', 'ตกลง', false, '', () {
        Navigator.of(context).pop();
      });
    } else if (AisleController.text.length != 3 ||
        int.parse(AisleController.text) < 100) {
      MyAlertDialog.showalertdialog(context, 'ข้อมูลไม่ถูกต้อง',
          'เลข Aisle ต้องไมน้อยกว่า 100', 'ตกลง', false, '', () {
        Navigator.of(context).pop();
      });
    } else if (int.parse(BayEndController.text) <
        int.parse(BayStartController.text)) {
      MyAlertDialog.showalertdialog(context, 'ข้อมูลไม่ถูกต้อง',
          'เลขเบย์เริ่มต้น ต้องน้อยกว่า เบย์สุดท้าย', 'ตกลง', false, '', () {
        Navigator.of(context).pop();
      });
    }

    //ถ้าครบ
    else {
      List<dynamic> waitdata = [];
      for (int i = int.parse(BayStartController.text);
          i <= int.parse(BayEndController.text);
          i++) {
        currentdata = {
          'aisle': AisleController.text,
          'bay': i.toString(),
          'div': dropdownValue,
          'status': '0'
        };
        waitdata.add(currentdata);
      }
      await ManageDB().InsertAisleBayWithCheckDuplicate(waitdata);
      AisleController.clear();
      BayStartController.clear();
      BayEndController.clear();
      setState(() {});
    }
  }
}

class popmenuCustomBay {
  static const String FirstItem = 'ลบเบย์ทั้งหมด';
  static const String SecondItem = 'เซ็ตเบย์ตามค่าเริ่มต้น';

  static const List<String> choices = <String>[
    FirstItem,
    SecondItem,
  ];
}
 */