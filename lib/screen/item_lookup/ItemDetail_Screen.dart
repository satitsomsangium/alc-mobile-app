/* import 'package:alc_mobile_app/Screens/Test_Screen.dart';
import 'package:alc_mobile_app/database/manage_db.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Itemdetail extends StatefulWidget {
  @override
  _ItemdetailState createState() => _ItemdetailState();
}

class _ItemdetailState extends State<Itemdetail> {
  final fb = FirebaseDatabase.instance;
  bool prepanalmutation = false;
  String preart = '',
      predescr = '',
      predescreng = '',
      prebarcode = '',
      presupno = '',
      predept = '',
      pregrp = '',
      preplu = '';

  List getdataoffline, getmutation, getmutationfinal = [];
  List iiik = [], iiiv = [];
  Map<String, dynamic> mapvalue;
  TextEditingController ArtBarController = TextEditingController();
/*   List<Map<String, dynamic>> itemtable = [
    {'name': 'Art'},
    {'name': 'Descr'},
    {'name': 'Descr Eng'},
    {'name': 'Barcode'},
    {'name': 'Supplier No'},
    {'name': 'Dept'},
    {'name': 'Class'},
    {'name': 'Mutation'},
  ]; */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Table(
                border: TableBorder.all(),
                columnWidths: const <int, TableColumnWidth>{
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(7),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[
                  new TableRow(
                    children: [
                      tablecell('Art'),
                      tablecell(preart),
                    ],
                  ),
                  new TableRow(
                    children: [
                      tablecell('Descr'),
                      tablecell(predescr),
                    ],
                  ),
                  new TableRow(
                    children: [
                      tablecell('Descr Eng'),
                      tablecell(predescreng),
                    ],
                  ),
                  new TableRow(
                    children: [
                      tablecell('Barcode'),
                      tablecell(prebarcode),
                    ],
                  ),
                  new TableRow(
                    children: [
                      tablecell('Supplier No'),
                      tablecell(presupno),
                    ],
                  ),
                  new TableRow(
                    children: [
                      tablecell('Dept'),
                      tablecell(predept),
                    ],
                  ),
                  new TableRow(
                    children: [
                      tablecell('Class'),
                      tablecell(pregrp),
                    ],
                  ),
                  new TableRow(
                    children: [
                      tablecell('PLU'),
                      tablecell(preplu),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 0,
              ),
              TextButton(onPressed: () {}, child: Text('Price Information')),
              SizedBox(
                height: 0,
              ),
              Table(
                border: TableBorder.all(),
                columnWidths: const <int, TableColumnWidth>{
                  0: FlexColumnWidth(10),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[
                  new TableRow(
                    children: [
                      tablecell('Mutation'),
                    ],
                  ),
                  new TableRow(
                    children: [
                      tablecell('รอเพิ่มคำสั่ง'),
                    ],
                  ),
                  new TableRow(
                    children: [
                      tablecell('รอเพิ่มคำสั่ง'),
                    ],
                  ),
                  new TableRow(
                    children: [
                      tablecell('รอเพิ่มคำสั่ง'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(bottom: BorderSide(color: Colors.black12, width: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 10, right: 15, bottom: 10, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 5),
                Flexible(
                  child: TextField(
                    maxLength: 14,
                    /* focusNode: _focus, */
                    textAlignVertical: TextAlignVertical.center,
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ค้นด้วย Art/Barcode',
                      contentPadding: EdgeInsets.fromLTRB(15, 8, 15, 12),
                      isDense: true,
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(75),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.red,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white60,
                      ),
                    ),
                    controller: ArtBarController,
                    onChanged: (value) {
                      if (ArtBarController.text != '') {
                        loadpreviewdata(value);
                      } else {}
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(100)),
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(left: 10),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: () {
                      /* Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomePage())); */
                    },
                    icon: Icon(
                      Icons.add,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget tablecell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Text(text),
      ),
    );
  }

  Future<void> loadpreviewdata(String value) async {
/*     fb
        .reference()
        .child("ItemEnquiry")
        .child('Itemlist')
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot != null) {
        print(snapshot.value);
      } else {
        setState(() {
          preart = '';
          predescr = '';
          predescreng = '';
          prebarcode = '';
          presupno = '';
          predept = '';
          pregrp = '';
          preplu = '';
        });
      }
    }); */

    getdataoffline = await ManageDB().getItemlookupWithConvert(value) ?? [];
    if (getdataoffline.isNotEmpty) {
      List itemdetail = getdataoffline[0].values.toList();
      setState(() {
        preart = getdataoffline[0]['art'].toString();
        predescr = getdataoffline[0]['descr'].toString();
        predescreng = getdataoffline[0]['descreng'].toString();
        prebarcode = getdataoffline[0]['barcode'].toString() != 'null'
            ? getdataoffline[0]['barcode'].toString()
            : '-';
        presupno = getdataoffline[0]['supno'].toString();
        predept = getdataoffline[0]['dept'].toString();
        pregrp = getdataoffline[0]['grp'].toString();
        preplu = prebarcode == '-'
            ? '-'
            : int.parse(prebarcode.substring(2, 6)).toString();
        /* preplu = int.parse(
                getdataoffline[0]['barcode'].toString().substring(2, 6))
            .toString(); */
      });
    } else {
      setState(() {
        preart = '';
        predescr = '';
        predescreng = '';
        prebarcode = '';
        presupno = '';
        predept = '';
        pregrp = '';
        preplu = '';
      });
    }
  }
}
 */