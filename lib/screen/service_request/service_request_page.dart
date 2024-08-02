import 'package:alc_mobile_app/component/appbar.dart';
import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:alc_mobile_app/screen/service_request/service_request_detail_page.dart';
import 'package:alc_mobile_app/screen/service_request/service_request_input_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceRequestPage extends StatefulWidget {
  const ServiceRequestPage({super.key});

  @override
  State<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  CollectionReference serviceRequestCollention =
      FirebaseFirestore.instance.collection("ServiceRequest");
  String dropdownValue = 'ทั้งหมด';
  Color colorstatus = Colors.red.shade200;
  String? firestorequery = '';
  final ScrollController _scrollController = ScrollController();
  bool _show = true;

  @override
  void initState() {
    super.initState();
    handleScroll();
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {});
    super.dispose();
  }

  void handleScroll() async {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _show = false;
        });
      }
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _show = true;
        });
      }
    });
  }

  Future<void> _makePhoneCall(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future oneditstatuspress(String docid, String getstatus) async {
    await serviceRequestCollention.doc(docid).update({'status': getstatus});
    Get.back();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Service request',
        popupMenu: SizedBox.shrink(),
        color1: Color(0xFFFF7765),
        color2: Color(0xFFF7A23C)
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
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
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>[
                  'ทั้งหมด',
                  'รอแจ้งซ่อม',
                  'กำลังดำเนินการ',
                  'แก้ไขแล้ว'
                ].map<DropdownMenuItem<String>>((String value) {
                  if (dropdownValue == 'ทั้งหมด') {
                    firestorequery = null;
                  } else {
                    firestorequery = dropdownValue;
                  }

                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                isExpanded: true,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('ServiceRequest')
                  .where('status', isEqualTo: firestorequery)
                  .orderBy('createDate', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final formatter = DateFormat('dd/MM/yyyy hh:mm');
                return ListView(
                  controller: _scrollController,
                  children: snapshot.data!.docs.map((document) {
                    if ('${document["status"]}' == 'รอแจ้งซ่อม') {
                      colorstatus = Colors.red.shade200;
                    } else if ('${document["status"]}' == 'กำลังดำเนินการ') {
                      colorstatus = Colors.yellow.shade200;
                    } else if ('${document["status"]}' == 'แก้ไขแล้ว') {
                      colorstatus = Colors.green.shade200;
                    }

                    return InkWell(
                      onLongPress: () {
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
                                    oneditstatuspress(
                                        document.id, 'แก้ไขแล้ว');
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
                                    oneditstatuspress(
                                        document.id, 'กำลังดำเนินการ');
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
                                    oneditstatuspress(
                                        document.id, 'รอแจ้งซ่อม');
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
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ServiceRequestDetailPage(document.id)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 10, top: 5),
                        child: Container(
                          padding: const EdgeInsets.only(
                              top: 15, right: 15, bottom: 15, left: 15),
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
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            document["title"],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(formatter.format(DateTime.parse(document["createDate"].toDate().toString()))),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // ignore: avoid_unnecessary_containers
                                  Container(
                                      child: Row(
                                    children: [
                                      document["images"].length > 0
                                          ? Icon(
                                              document["images"].length > 1
                                                  ? Icons.photo_library
                                                  : Icons.image,
                                              color: Colors.black54,
                                            )
                                          : const SizedBox(),
                                      '${document["status"]}' != 'รอแจ้งซ่อม'
                                          ? const SizedBox()
                                          : const SizedBox(
                                              width: 10,
                                            ),
                                      '${document["status"]}' == 'รอแจ้งซ่อม'
                                          ? IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () {
                                                setState(() {
                                                  _makePhoneCall(
                                                      'tel:${document["tel"]}');
                                                });
                                              },
                                              icon: Icon(
                                                Icons.phone_iphone,
                                                color: Colors.greenAccent[400],
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  )),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                        margin:
                                            const EdgeInsets.only(top: 5, bottom: 5),
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.04),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(document["issues"])),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Case No : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('${document["caseNo"]}')
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'To : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('${document["to"]}'),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Status : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('${document["status"]}'),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.circle_rounded,
                                        color: colorstatus,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'By : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('${document["name"]}'),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _show ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: _show
            ? FloatingActionButton(
                /* shape: const CircleBorder(), */
                child: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ServiceRequestInputPage()));
                },
              )
            : FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {},
              ),
      ),
    );
  }
}
