/* import 'dart:async';

import 'package:alc_mobile_app/component/appbar.dart';
import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class ServiceRequestDetailPage extends StatefulWidget {
  final String docid;
  const ServiceRequestDetailPage(this.docid, {super.key});

  @override
  State<ServiceRequestDetailPage> createState() => _ServiceRequestDetailPageState();
}

class _ServiceRequestDetailPageState extends State<ServiceRequestDetailPage> {
  final casenocontroller = TextEditingController();
  final issuescontroller = TextEditingController();
  CollectionReference serviceRequestCollention =
      FirebaseFirestore.instance.collection("ServiceRequest");
  Color colorstatus = Colors.red.shade200;
  final formatter = new DateFormat('dd/MM/yyyy hh:mm');
  FirebaseStorage storage = FirebaseStorage.instance;
  String casenovari = '';
  final formKey = GlobalKey<FormState>();

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> deletephoto(String ref) async {
    Reference photo = storage.refFromURL(ref);
    await photo.delete();
  }

  Future oneditstatuspress(String getstatus) async {
    await serviceRequestCollention
        .doc(widget.docid)
        .update({'status': getstatus});
    Navigator.of(context).pop();
    setState(() {});
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
            child: Image.network(
              imagepath,
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return const Text('Image not found');
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double swidth(double width) {
      return MediaQuery.of(context).size.width * width / 100;
    }

    return Scaffold(
      appBar: const MyAppBar(
        title: 'Request Detail',
        popupMenu: SizedBox.shrink(),
        color1: Color(0xFFFF7765),
        color2: Color(0xFFF7A23C)
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.only(top: 15, right: 15, bottom: 15, left: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                spreadRadius: 1,
              ),
            ],
          ),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('ServiceRequest')
                .doc(widget.docid)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if ('${snapshot.data?["status"]}' == 'รอแจ้งซ่อม') {
                colorstatus = Colors.red.shade200;
              } else if ('${snapshot.data?["status"]}' == 'กำลังดำเนินการ') {
                colorstatus = Colors.yellow.shade200;
              } else if ('${snapshot.data?["status"]}' == 'แก้ไขแล้ว') {
                colorstatus = Colors.green.shade200;
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '${snapshot.data?['title']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                  formatter.format(DateTime.parse(snapshot.data!["createDate"].toDate().toString()))),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            child: '${snapshot.data?["status"]}' == 'รอแจ้งซ่อม'
                                ? IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(() {
                                        _makePhoneCall(
                                            'tel:${snapshot.data?["tel"]}');
                                      });
                                    },
                                    icon: Icon(
                                      Icons.phone_iphone,
                                      color: Colors.greenAccent[400],
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                          /* SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () async {
                              /*  if (snapshot.data["images"] != []) {
                                for (int i = 0;
                                    i < snapshot.data["images"].length ?? 0;
                                    i++) {
                                  await deletephoto(snapshot.data["images"][i]);
                                }
                              }
      
                              await serviceRequestCollention
                                  .doc(widget.docid)
                                  .delete();
                              Navigator.of(context).pop(); */
                            },
                            icon: Icon(
                              Icons.more_vert,
                            ),
                          ) */
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: swidth(20),
                        child: const Text(
                          's/n : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('${snapshot.data?["serailNo"]}')
                    ],
                  ),
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: swidth(20),
                        child: const Text(
                          'Issues : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(snapshot.data?["issues"]),
                      ),
                      InkWell(
                        onTap: () {
                          issuescontroller.text = snapshot.data?["issues"];
                          MyAlertDialog.showAlertDialogWithWidgetContent(
                              context: context,
                              title: 'แก้ไขรายละเอียด',
                              contentWidget: Flexible(
                                child: TextField(
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.start,
                                  maxLines: 10,
                                  maxLength: 500,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
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
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white60),
                                  ),
                                  controller: issuescontroller,
                                ),
                              ),
                              okButtonText: 'บันทึก',
                              cancelButtonVisible: true,
                              cancelButtonText: 'ยกเลิก',
                              cancelCallback: () {
                            Navigator.of(context).pop();
                          },okCallback: () async {
                            if (issuescontroller.text != '') {
                              await serviceRequestCollention
                                  .doc(widget.docid)
                                  .update({'issues': issuescontroller.text});
                              issuescontroller.clear();
                              Navigator.of(context).pop();
                            }
                          });
                        },
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: swidth(20),
                        child: const Text(
                          'Case No :',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      /* Flexible(
                        child: TextField(
                          maxLines: 1,
                          style: TextStyle(color: Colors.black87),
                          textAlign: TextAlign.start,
                          maxLength: 30,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            counterText: "",
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: '${snapshot.data["caseNo"]}',
                            hintStyle: TextStyle(color: Colors.black87),
                          ),
                          controller: casenocontroller,
                          onChanged: (value) async {
                            await serviceRequestCollention
                                .doc(widget.docid)
                                .update({'caseNo': value});
                            setState(() {});
                          },
                        ),
                      ),
                       */

                      Expanded(child: Text('${snapshot.data?["caseNo"]}')),
                      InkWell(
                        onTap: () {
                          MyAlertDialog.showalertdialogWidgetContent(
                              context,
                              'เพิ่มหมายเลขงาน',
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Form(
                                    key: formKey,
                                    child: Flexible(
                                      child: TextFormField(
                                        validator: RequiredValidator(
                                            errorText: 'กรุณาเพิ่มข้อมูล').call,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                        textAlign: TextAlign.center,
                                        maxLength: 20,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.all(8),
                                          isDense: true,
                                          counterText: "",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(75),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[800],
                                          hintText: "พิมพ์หมายเลขงาน",
                                          hintStyle: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white60),
                                        ),
                                        controller: casenocontroller,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              'บันทึก',
                              true,
                              'ยกเลิก', () {
                            Navigator.of(context).pop();
                          }, () async {
                            if (formKey.currentState!.validate()) {
                              await serviceRequestCollention
                                  .doc(widget.docid)
                                  .update({'caseNo': casenocontroller.text});
                              Navigator.of(context).pop();
                            }
                          });
                        },
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  InkWell(
                    onTap: () {
                      MyAlertDialog.showalertdialogWidgetContentNobtn(
                          context,
                          'แก้ไข Status',
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.green.shade200),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(75),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  oneditstatuspress('แก้ไขแล้ว');
                                },
                                child: const SizedBox(
                                  child: Center(
                                    child: Text(
                                      'แก้ไขแล้ว',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.yellow.shade200),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(75),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  oneditstatuspress('กำลังดำเนินการ');
                                },
                                child: const SizedBox(
                                  child: Center(
                                    child: Text(
                                      'กำลังดำเนินการ',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.red.shade200),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(75),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  oneditstatuspress('รอแจ้งซ่อม');
                                },
                                child: const SizedBox(
                                  child: Center(
                                    child: Text(
                                      'รอแจ้งซ่อม',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: swidth(20),
                          child: const Text(
                            'Status : ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                            decoration: BoxDecoration(
                              color: colorstatus,
                              borderRadius: BorderRadius.circular(75),
                            ),
                            child: Text(snapshot.data?["status"])),
                      ],
                    ),
                  ),
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: swidth(20),
                        child: const Text(
                          'To : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('${snapshot.data?["to"]}')
                    ],
                  ),
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: swidth(20),
                        child: const Text(
                          'Tel : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('${snapshot.data?["tel"]}')
                    ],
                  ),
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: swidth(20),
                        child: const Text(
                          'By : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('${snapshot.data?["name"]}')
                    ],
                  ),
                  snapshot.data?["images"].length > 0 ? const Divider() : const SizedBox(),
                  snapshot.data?["images"].length > 0
                      ? Column(
                          children: [
                            snapshot.data?["images"].length > 0
                                ? InkWell(
                                    onTap: () {
                                      _displayDialog(
                                          context, snapshot.data?["images"][0]);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        snapshot.data?["images"][0],
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace stackTrace) {
                                          return const Text('Image not found');
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;

                                          return const Center(
                                              child: Text('Loading...'));
                                        },
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            snapshot.data?["images"].length > 1
                                ? Divider()
                                : SizedBox(),
                            snapshot.data?["images"].length > 1
                                ? InkWell(
                                    onTap: () {
                                      _displayDialog(
                                          context, snapshot.data?["images"][1]);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        snapshot.data?["images"][1],
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace stackTrace) {
                                          return const Text('Image not found');
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;

                                          return const Center(
                                              child: Text('Loading...'));
                                        },
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            snapshot.data?["images"].length > 2
                                ? Divider()
                                : SizedBox(),
                            snapshot.data?["images"].length > 2
                                ? InkWell(
                                    onTap: () {
                                      _displayDialog(
                                          context, snapshot.data?["images"][2]);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        snapshot.data?["images"][2],
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace stackTrace) {
                                          return const Text('Image not found');
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;

                                          return const Center(
                                              child: Text('Loading...'));
                                        },
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        )
                      : const SizedBox(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
 */