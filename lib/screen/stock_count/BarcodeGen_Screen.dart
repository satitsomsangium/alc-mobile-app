/* import 'package:alc_mobile_app/database/transection_db.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class BarcodeGenerators extends StatefulWidget {
  String aisle, bay, div;
  BarcodeGenerators(this.aisle, this.bay, this.div);
  @override
  _BarcodeGeneratorsState createState() => _BarcodeGeneratorsState();
}

class _BarcodeGeneratorsState extends State<BarcodeGenerators> {
  List stdb;
  var tabs;

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> getdatalist() async {
    stdb = await TransactionDB().loadAllData('${widget.aisle}${widget.bay}');
    return stdb;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getdatalist(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            tabs = snapshot.data;
            List getindex = [];
            for (int i = 0; i < tabs.length; i++) {
              getindex.add(tabs[i]['art']);
            }
            return DefaultTabController(
              initialIndex: 0,
              length: tabs.length,
              child: Scaffold(
                appBar: AppBar(
                    /* automaticallyImplyLeading: false, */
                    title: Text(
                        '${widget.aisle} - ${widget.bay} (${widget.div})')),
                body: TabBarView(
                  children: [
                    for (final tab in tabs)
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red[300],
                                      borderRadius: BorderRadius.circular(100)),
                                  width: 80,
                                  height: 80,
                                  padding: EdgeInsets.all(0),
                                  margin: EdgeInsets.all(0),
                                  child: Center(
                                    child: Text(
                                      (getindex.indexOf(tab['art']) + 1)
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 40,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'รหัสสินค้า',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                height: 120,
                                child: SfBarcodeGenerator(
                                  textStyle: TextStyle(
                                      fontSize: 30, fontWeight: FontWeight.bold),
                                  value: /* tab['art'].toString() */'${tab['art']}',
                                  symbology: Code128(),
                                  showValue: true,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                '${tab['descr']}',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'จำนวน',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                height: 120,
                                child: SfBarcodeGenerator(
                                  textStyle: TextStyle(
                                      fontSize: 30, fontWeight: FontWeight.bold),
                                  value: tab['qty'].toString(),
                                  symbology: Code128(),
                                  showValue: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                bottomNavigationBar: Container(
                  height: 55,
                  color: Colors.red,
                  child: TabBar(
                    isScrollable: true,
                    tabs: [
                      for (final tab in tabs)
                        Text(
                          (getindex.indexOf(tab['art']) + 1).toString(),
                          style: TextStyle(fontSize: 22),
                        ),
                    ],
                  ),
                ),
              ),
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
    );
  }
}
 */