/* import 'dart:async';
import 'dart:io';

import 'package:alc_mobile_app/component/appbar.dart';
import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:math' as math;

class ServiceRequestInputPage extends StatefulWidget {
  const ServiceRequestInputPage({super.key});

  @override
  State<ServiceRequestInputPage> createState() => _ServiceRequestInputPageState();
}

class _ServiceRequestInputPageState extends State<ServiceRequestInputPage> {
  final fb = FirebaseDatabase.instance;
  CollectionReference serviceRequestCollention =
      FirebaseFirestore.instance.collection("ServiceRequest");
  final issuesController = TextEditingController();
  final titleController = TextEditingController();
  String dropdownValue = 'เลือกเครื่อง';
  String dropdownValue2 = 'เลือก';
  String dropdownValueName = 'เลือกชื่อ';
  bool visibleDropdown2 = false;
  String serailnumber = '';
  DateTime currentdate = new DateTime.now();
  var curd = new DateTime.now().day;
  var curm = new DateTime.now().month;
  var cury = new DateTime.now().year;
  var curh = new DateTime.now().hour;
  var curmi = new DateTime.now().minute;
  var curs = new DateTime.now().second;
  String caseno = '-';
  String workstatus = 'รอแจ้งซ่อม';
  String requestto = '';
  String phoneNo = '';

  //add images
  late List<XFile> _imageFileList;

  set _imageFile(XFile value) {
    _imageFileList = (value == null ? null : [value])!;
  }

  dynamic _pickImageError;
  late String _retrieveDataError;
  final ImagePicker _picker = ImagePicker();

  List<XFile> myimagelist = [];

  List<String> selecttill = <String>[
    'เลือก',
    'Till 1',
    'Till 2',
    'Till 3',
    'Till 4',
    'Till 5',
    'Till 6',
    'Till 7',
    'Till 8',
    'Till 9',
    'Till 10',
    'Till 11',
    'Till 12',
    'Till 13',
    'Till 14',
    'Till 15',
    'Till 16',
    'Till 17',
    'Till 18',
    'Till 19'
  ];

  List<String> selectWeightScal = <String>[
    'เลือก',
    '81',
    '82',
    '83',
    '84',
    '85',
    '86',
    '87',
    '88',
    '95'
  ];

  List<String> selectPrinter = <String>[
    'เลือก',
    'ALC',
    'ALC Server',
    'GR',
    'Telesale',
    'Customer Service'
  ];

  List<String> selectComputerUser = <String>[
    'เลือก',
    'SGM',
    'ASGM',
    'SSR',
    'OCS',
    'CDM',
    'CDO1',
    'CDO2',
    'CDA',
    'CENTER',
    'HRS',
    'HRM',
    'COM',
    'RECEPTION',
    'DF1',
    'DF2',
    'FRESH',
    'BKM',
    'NF1',
    'GRM',
    'ADMGRS',
    'ALCM',
    'ALC 1',
    'ALC 2',
    'ADMM',
    'ADMS',
    'GAM',
    'EL1',
    'EL2',
    'Shrinkage',
    'SKYPE'
  ];

  List<String> selectMenuItem = <String>['เลือก', ''];

  /*  @override
  void initState() {
    super.initState();
  
  } */

  Future<bool> onWillPop() async {
    print(myimagelist);
    print('okkkkkkkk');
    if (dropdownValue != 'เลือกเครื่อง' ||
        dropdownValue2 != 'เลือก' ||
        dropdownValueName != 'เลือกชื่อ' ||
        issuesController.text != '' ||
        myimagelist.length > 0) {
      MyAlertDialog.showalertdialog(context, 'ยังไม่ได้บันทึก',
          'ต้องการละทิ้งใช่หรือไม่', 'ตกลง', true, 'ยกเลิก', () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        return true;
      });
    }
    return true;
  }

  Future serailnumberfilter(String getmachinename) {
    fb
        .ref()
        .child('ServiceRequest')
        .child('SerialNo')
        .child(getmachinename)
        .once()
        .then((DataSnapshot data) {
      if (data.value != null) {
        print('${data.value['serialno']}');
        serailnumber = '${data.value['serialno']}';
      } else {
        serailnumber = '';
      }
    });
    /*  if (getmachinename == 'เครื่องชั่ง 81') {
      serailnumber = 'รอข้อมูล';
    }
    serailnumber = 'รอเพิ่มข้อมูล'; */
  }

  onsaveclick() async {
    if (dropdownValue == 'เลือกเครื่อง') {
      MyAlertDialog.showalertdialog(context, 'กรุณากรอกข้อมูลให้ครบ',
          'กรุณาเลือกเครื่อง', 'ตกลง', false, '', () {
        Navigator.pop(context);
      });
    } else if (dropdownValue2 == 'เลือก') {
      MyAlertDialog.showalertdialog(context, 'กรุณากรอกข้อมูลให้ครบ',
          'กรุณาเลือกเลขเครื่อง', 'ตกลง', false, '', () {
        Navigator.pop(context);
      });
    } else if (issuesController.text == '') {
      MyAlertDialog.showalertdialog(context, 'กรุณากรอกข้อมูลให้ครบ',
          'กรุณาใส่ปัญหาที่ต้องการแจ้ง', 'ตกลง', false, '', () {
        Navigator.pop(context);
      });
    } else if (dropdownValueName == 'เลือกชื่อ') {
      MyAlertDialog.showalertdialog(context, 'กรุณากรอกข้อมูลให้ครบ',
          'กรุณาเลือกชื่อใส่ชื่อ', 'ตกลง', false, '', () {
        Navigator.pop(context);
      });
    } else {
      print(serailnumber + '555555555555555555555');
      //เลือกครบทุกอย่างแล้ว
      if (dropdownValue == 'เครื่องชั่ง ' ||
          dropdownValue == 'เครื่องปริ้น Long from ' ||
          dropdownValue == 'เครื่องปริ้น Short from ' ||
          dropdownValue == 'ลิ้นชักเก็บเงิน ' ||
          dropdownValue == 'POS ' ||
          dropdownValue == 'เครื่องปริ้น บัตรสมาชิก') {
        requestto = 'EMC';
        phoneNo = '02-026-6299';
        /* serailnumber =
            await serailnumberfilter('${dropdownValue}${dropdownValue2}'); */
        confirmDialog(requestto, phoneNo, dropdownValueName, serailnumber);
      } else if (dropdownValue == 'เครื่องปริ้น ') {
        requestto = 'Fuji Xerox';
        phoneNo = '02-660-8484';
        /* serailnumber =
            await serailnumberfilter('${dropdownValue}${dropdownValue2}'); */
        confirmDialog(requestto, phoneNo, dropdownValueName, serailnumber);
      } else if (dropdownValue == 'เครื่องคอมพิวเตอร์ ' ||
          dropdownValue == 'คีย์บอร์ด ' ||
          dropdownValue == 'เมาส์ ' ||
          dropdownValue == 'จอคอมพิวเตอร์ ') {
        requestto = 'Acer';
        phoneNo = '02-153-9600';
        /* serailnumber =
            await serailnumberfilter('${dropdownValue}${dropdownValue2}'); */
        confirmDialog(requestto, phoneNo, dropdownValueName, serailnumber);
      } else if (dropdownValue == 'เครื่องปริ้น Barcode GR') {
        requestto = 'CDG';
        phoneNo = '086-057-2775';
        /* serailnumber =
            await serailnumberfilter('${dropdownValue}${dropdownValue2}'); */
        confirmDialog(requestto, phoneNo, dropdownValueName, serailnumber);
      }
    }
  }

  confirmDialog(String getrequestto, String getphoneNo, String getrequestby,
      String getserailnumber) {
    MyAlertDialog.showalertdialogWidgetContent(
        context,
        'รายละเอียดการแจ้งซ่อม',
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 16 / 100,
                  child: Text(
                    'Title :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text('${dropdownValue}${dropdownValue2}'),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 16 / 100,
                  child: Text(
                    's/n :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(
                  child: Text(
                    '${getserailnumber}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 16 / 100,
                  child: Text(
                    'Issue :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text('${issuesController.text}'),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 16 / 100,
                  child: Text(
                    'Tel :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(getphoneNo),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 16 / 100,
                  child: Text(
                    'To :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(getrequestto),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 16 / 100,
                  child: Text(
                    'By :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(getrequestby),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 16 / 100,
                  child: Text(
                    'Img :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                myimagelist.length < 1
                    ? Text('ไม่มี')
                    : Text('${myimagelist.length} รูป'),
              ],
            ),
          ],
        ),
        'บันทึก',
        true,
        'ยกเลิก', () {
      Navigator.pop(context);
    }, () async {
      //save to database

      MyAlertDialog.loadingdialog(context, 'กำลังบันทึกข้อมูล');

      imgurl().then((value) async {
        await serviceRequestCollention.add({
          "caseNo": "-",
          "createDate": new DateTime.now(),
          "createTime": '${curh}:${curmi}',
          "images": value,
          "issues": issuesController.text,
          "name": dropdownValueName,
          "remark": "-",
          "serailNo": serailnumber,
          "status": "รอแจ้งซ่อม",
          "tel": phoneNo,
          "title": '${dropdownValue}${dropdownValue2}',
          "to": requestto
        });
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        /* setState(() {
          myimagelist = [];
          visibleDropdown2 = false;
          dropdownValue2 = 'เลือก';
          dropdownValue = 'เลือกเครื่อง';
          dropdownValueName = 'เลือกชื่อ';
        }); */

        /* issuesController.clear(); */
      });
    });
  }

  Future<List<String>> imgurl() async {
    List<String> files = [];
    if (myimagelist.length > 0) {
      for (int i = 0; i < myimagelist.length; i++) {
        final String fileName = path.basename(myimagelist[i].path);

        File imageFile = File(myimagelist[i].path);

        try {
          FirebaseStorage storage = FirebaseStorage.instance;
          Reference ref = await storage.ref('ServiceRequest').child(fileName);
          UploadTask uploadTask = ref.putFile(imageFile);

          await uploadTask.whenComplete(() async {
            String _mainurl = (await ref.getDownloadURL()).toString();
            files.add(_mainurl);
          });
        } on FirebaseException catch (error) {
          print(error);
        }
      }
    }
    return files;
  }

  Widget _previewImages(double vw, double vh) {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (myimagelist.length > 0) {
      return SizedBox(
        height: vh,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          key: UniqueKey(),
          itemCount: myimagelist.length,
          itemBuilder: (context, index) {
            return kIsWeb
                ? Image.network(myimagelist[index].path)
                : Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          _displayDialog(
                              context, File(myimagelist[index].path));
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 5),
                          height: vh,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(myimagelist[index].path),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(75),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () async {
                              await myimagelist.removeAt(index);
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.close,
                              size: 15,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Text('');
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      _imageFile = response.file!;
      _imageFileList = response.files!;
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    double swidth(double width) {
      return MediaQuery.of(context).size.width * width / 100;
    }

    double imagesize() {
      return ((MediaQuery.of(context).size.width - 30) / 2) - 5;
    }

    double imagesizeheight() {
      return imagesize() * 2 / 3;
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: const MyAppBar(
          title: 'แจ้งซ่อม', 
          popupMenu: SizedBox.shrink(),
          color1: Color(0xFFFF7765),
          color2: Color(0xFFF7A23C)
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(75),
                  ),
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: DropdownButton<String>(
                    borderRadius: BorderRadius.circular(15),
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 20,
                    elevation: 8,
                    underline: Container(
                      height: 0,
                      color: Colors.red[300],
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                        dropdownValue2 = 'เลือก';
                      });
                    },
                    items: <String>[
                      'เลือกเครื่อง',
                      'เครื่องชั่ง ',
                      'เครื่องปริ้น ',
                      'เครื่องปริ้น Long from ',
                      'เครื่องปริ้น Short from ',
                      'เครื่องคอมพิวเตอร์ ',
                      'จอคอมพิวเตอร์ ',
                      'คีย์บอร์ด ',
                      'เมาส์ ',
                      'ลิ้นชักเก็บเงิน ',
                      'POS ',
                      'เครื่องปริ้น Barcode GR',
                      'เครื่องปริ้น บัตรสมาชิก',
                      'อื่น ๆ',
                    ].map<DropdownMenuItem<String>>((String value) {
                      if (dropdownValue == 'เครื่องชั่ง ') {
                        setState(() {
                          visibleDropdown2 = true;
                          selectMenuItem = selectWeightScal;
                        });
                      } else if (dropdownValue == 'เครื่องปริ้น ') {
                        setState(() {
                          visibleDropdown2 = true;
                          selectMenuItem = selectPrinter;
                        });
                      } else if (dropdownValue == 'เครื่องปริ้น Long from ' ||
                          dropdownValue == 'เครื่องปริ้น Short from ' ||
                          dropdownValue == 'ลิ้นชักเก็บเงิน ' ||
                          dropdownValue == 'POS ') {
                        setState(() {
                          visibleDropdown2 = true;
                          selectMenuItem = selecttill;
                        });
                      } else if (dropdownValue == 'เครื่องคอมพิวเตอร์ ' ||
                          dropdownValue == 'จอคอมพิวเตอร์ ' ||
                          dropdownValue == 'คีย์บอร์ด ' ||
                          dropdownValue == 'เมาส์ ') {
                        setState(() {
                          visibleDropdown2 = true;
                          selectMenuItem = selectComputerUser;
                        });
                      } else if (dropdownValue == 'เครื่องปริ้น Barcode GR' ||
                          dropdownValue == 'เครื่องปริ้น บัตรสมาชิก' ||
                          dropdownValue == 'อื่น ๆ') {
                        setState(() {
                          visibleDropdown2 = false;
                          selectMenuItem = <String>['เลือก', ''];
                          dropdownValue2 = '';
                        });
                      } else {
                        setState(() {
                          visibleDropdown2 = false;
                        });
                      }
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: visibleDropdown2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(75),
                    ),
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: DropdownButton<String>(
                      borderRadius: BorderRadius.circular(15),
                      value: dropdownValue2,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 20,
                      elevation: 8,
                      underline: Container(
                        height: 0,
                        color: Colors.red[300],
                      ),
                      onChanged: (String newValue) async {
                        setState(() {
                          dropdownValue2 = newValue;
                        });
                        await serailnumberfilter(
                            '$dropdownValue$dropdownValue2');
                      },
                      items: selectMenuItem
                          .map<DropdownMenuItem<String>>((String value2) {
                        return DropdownMenuItem<String>(
                          value: value2,
                          child: Text(
                            value2,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                    ),
                  ),
                ),
              ),

              //ชื่อ
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(75),
                  ),
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: DropdownButton<String>(
                    borderRadius: BorderRadius.circular(15),
                    value: dropdownValueName,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 20,
                    elevation: 8,
                    underline: Container(
                      height: 0,
                      color: Colors.red[300],
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValueName = newValue;
                      });
                    },
                    items: <String>[
                      'เลือกชื่อ',
                      'Satein',
                      'Anuwat',
                      'Gardbandit',
                      'Chakkapan',
                    ].map<DropdownMenuItem<String>>((String value3) {
                      return DropdownMenuItem<String>(
                        value: value3,
                        child: Text(
                          value3,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                  ),
                ),
              ),
              //อาการเสีย
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: TextField(
                  maxLines: 10,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      margin: const EdgeInsets.only(right: 10),
                      height: 210,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (myimagelist.length < 3) {
                                onaddclick();
                              } else {
                                MyAlertDialog.showalertdialog(
                                    context,
                                    'เพิ่มครบจำนวนสูงสุดแล้ว',
                                    'เพิ่มได้ 3 รูป เท่านั้น',
                                    'ตกลง',
                                    false,
                                    '', () {
                                  Navigator.of(context).pop();
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (myimagelist.length < 3) {
                                oncameraclick();
                              } else {
                                MyAlertDialog.showalertdialog(
                                    context,
                                    'เพิ่มครบจำนวนสูงสุดแล้ว',
                                    'เพิ่มได้ 3 รูป เท่านั้น',
                                    'ตกลง',
                                    false,
                                    '', () {
                                  Navigator.of(context).pop();
                                });
                              }
                            },
                            icon: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: const Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(8),
                    isDense: true,
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                    hintText: "อาการเสีย",
                    hintStyle: const TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.white60),
                  ),
                  controller: issuesController,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                child: Row(
                  children: [
                    Text(
                      '* เพิ่มรูปได้สูงสุด 3 รูป',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: FutureBuilder<void>(
                  future: retrieveLostData(),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return const Text('');
                      case ConnectionState.done:
                        return _previewImages(imagesize(), imagesizeheight());
                      default:
                        if (snapshot.hasError) {
                          return Text(
                            'Pick image/video error: ${snapshot.error}}',
                            textAlign: TextAlign.center,
                          );
                        } else {
                          return const Text('');
                        }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onsaveclick,
          child: const Icon(Icons.save),
        ),
      ),
    );
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

/*   Future uploadimage() async {
    if (pickedImage == null) return;

    final String fileName = pickedImage != null
        ? path.basename(pickedImage.path)
        : 'No Image Selected';

    File imageFile = File(pickedImage.path);

    try {
      // Uploading the selected image with some custom meta data
      await FirebaseStorage.instance.ref(fileName).putFile(
            imageFile,
          );

      // Refresh the UI

    } on FirebaseException catch (error) {
      print(error);
    }
  } */

  Future onaddclick() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        imageQuality: 60,
      );
      if (pickedFile != null) {
        myimagelist.add(pickedFile);
        setState(() {});
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Future oncameraclick() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        imageQuality: 60,
      );
      if (pickedFile != null) {
        myimagelist.add(pickedFile);
        setState(() {});
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  _displayDialog(BuildContext context, dynamic imagepath) {
    showGeneralDialog(
      context: context,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: InteractiveViewer(
            minScale: 1,
            child: Image.file(imagepath),
          ),
        );
      },
    );
  }
}
 */