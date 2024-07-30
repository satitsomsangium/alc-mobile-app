/* import 'dart:async';

import 'package:alc_mobile_app/Screens/StockCount/StockcountData_Screen.dart';
import 'package:alc_mobile_app/database/manage_db.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SelectBay extends StatefulWidget {
  final String lead;
  SelectBay(this.lead);

  @override
  _SelectBayState createState() => _SelectBayState();
}

class _SelectBayState extends State<SelectBay> {
  final fb = FirebaseDatabase.instance;
  String preart = '', predescr = '';
  String converttokey;
  bool prepanal = false, savebutton = false;
  final stockcountController = TextEditingController();
  Color statusColor = Colors.red[300];
  List values;

  Future<List<dynamic>> getbay() async {
    var baydata = await ManageDB().getSomeData('AisleBay', 'div', widget.lead);
    return baydata;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'เลือกเบย์',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: Text(
              widget.lead,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: FutureBuilder(
                future: getbay(),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.hasData) {
                    values = snapshot.data;
                    return ListView.builder(
                      itemCount: values.length ??= 0,
                      itemBuilder: (BuildContext context, int index) {
                        if (values[index]['status'].toString() == 'กำลังนับ') {
                          statusColor = Colors.blue[300];
                        } else if (values[index]['status'].toString() ==
                            'ยังไม่ได้นับ') {
                          statusColor = Colors.red[300];
                        } else if (values[index]['status'].toString() ==
                            'ปิดเบย์แล้ว') {
                          statusColor = Colors.green[300];
                        }
                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                '${values[index]['aisle']} - ${values[index]['bay']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 18),
                              ),
                              trailing: Container(
                                height: 40,
                                constraints:
                                    BoxConstraints(minHeight: 40, minWidth: 40),
                                decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    values[index]['status'].toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context)
                                    .push(
                                  new MaterialPageRoute(
                                      builder: (_) => new StockcountData(
                                          values[index]['aisle'].toString(),
                                          values[index]['bay'].toString(),
                                          widget.lead,
                                          values[index]['status'].toString())),
                                )
                                    .then((val) {
                                  setState(() {});
                                });
                              },
                            ),
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
        ],
      ),
    );
  }
}
 */