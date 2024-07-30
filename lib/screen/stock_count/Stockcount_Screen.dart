/* import 'package:alc_mobile_app/Screens/StockCount/CustomBay_Screen.dart';
import 'package:alc_mobile_app/Screens/StockCount/Selectbay_Screen.dart';
import 'package:alc_mobile_app/database/Model/AlertDialog.dart';
import 'package:alc_mobile_app/database/manage_db.dart';
import 'package:alc_mobile_app/database/Model/Appbar.dart';
import 'package:alc_mobile_app/database/transection_db.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Stockcount extends StatefulWidget {
  @override
  _StockcountState createState() => _StockcountState();
}

class _StockcountState extends State<Stockcount> {
  final fb = FirebaseDatabase.instance;
  bool _visible = false;
  int fvbay = 0, bubay = 0, fibay = 0, bkbay = 0, fzbay = 0;
  int fvaisleint = 0,
      buaisleint = 0,
      fiaisleint = 0,
      bkaisleint = 0,
      fzaisleint = 0;
  List fvaisle = [], buaisle = [], fiaisle = [], bkaisle = [], fzaisle = [];

  @override
  void initState() {
    super.initState();
    getbay();
  }

  Future<List<dynamic>> getbay() async {
    var baydata = await ManageDB().getAllData('AisleBay');

    for (int i = 0; i < baydata.length; i++) {
      if (baydata[i]['div'] == 'FV') {
        fvbay++;
        fvaisle.add(baydata[i]['aisle']);
      } else if (baydata[i]['div'] == 'BU') {
        bubay++;
        buaisle.add(baydata[i]['aisle']);
      } else if (baydata[i]['div'] == 'FI') {
        fibay++;
        fiaisle.add(baydata[i]['aisle']);
      } else if (baydata[i]['div'] == 'BK') {
        bkbay++;
        bkaisle.add(baydata[i]['aisle']);
      } else if (baydata[i]['div'] == 'FZ') {
        fzbay++;
        fzaisle.add(baydata[i]['aisle']);
      }
      fvaisleint = fvaisle.toSet().toList().length;
      buaisleint = buaisle.toSet().toList().length;
      fiaisleint = fiaisle.toSet().toList().length;
      bkaisleint = bkaisle.toSet().toList().length;
      fzaisleint = fzaisle.toSet().toList().length;
      setState(() {
        _visible = true;
      });
    }
    return baydata;
  }

  Widget ani(String getani) {
    return AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Text(getani));
  }

  void choiceAction(String choice) {
    if (choice == popmenu.FirstItem) {
      Navigator.of(context)
          .push(
        new MaterialPageRoute(builder: (_) => new Custombay()),
      )
          .then((val) {
        setState(() {});
      });
    } else if (choice == popmenu.SecondItem) {
      MyAlertDialog.showalertdialog(
          context,
          'ลบข้อมูลทั้งหมด',
          'คุณกำลังจะลบข้อมูลที่บันทึกไว้ในเบย์ทั้งหมด',
          'ตกลง',
          true,
          'ยกเลิก', () async {
        Navigator.of(context).pop();
        MyAlertDialog.loadingdialog(context, 'กรุณารอสักครู่');
        await TransactionDB().clearDatabase();
        await ManageDB().resetStatusBay();
        await new Future.delayed(const Duration(seconds: 15));
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
          'นับสต๊อก',
          PopupMenuButton<String>(
            offset: const Offset(0, 60),
            icon: Icon(
              Icons.more_vert,
            ),
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return popmenu.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
          Color(0xFFFFA72F),
          Color(0xFFFF641A)),
      body: Column(
        children: [
          Divider(height: 1, thickness: 0.5, indent: 10, endIndent: 10),
          CustomListtile(
              'FV',
              'แผนกผักและผลไม้',
              '$fvaisleint Aisle - $fvbay Bay',
              'assets/images/FV.jpg',
              _visible),
          CustomListtile(
              'BU',
              'แผนกหมู เนื้อ ไก่',
              '$buaisleint Aisle - $bubay Bay',
              'assets/images/BU.jpg',
              _visible),
          CustomListtile('FI', 'แผนกปลา', '$fiaisleint Aisle - $fibay Bay',
              'assets/images/FI.jpg', _visible),
          CustomListtile('BK', 'แผนกเบเกอรี่', '$bkaisleint Aisle - $bkbay Bay',
              'assets/images/BK.jpg', _visible),
          CustomListtile(
              'FZ',
              'แผนกอาหารแช่แข็ง',
              '$fzaisleint Aisle - $fzbay Bay',
              'assets/images/FZ.jpg',
              _visible),
        ],
      ),
    );
  }
}

class CustomListtile extends StatelessWidget {
  String dept, deptname, deptsub, imagelink;
  bool vi = false;
  CustomListtile(
      this.dept, this.deptname, this.deptsub, this.imagelink, this.vi);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          isThreeLine: false,
          title: Text(
            deptname,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: AnimatedOpacity(
              opacity: vi ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Text(deptsub)),
          leading: CircleAvatar(
            backgroundColor: Colors.red[300],
            child: Text(
              dept,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
          trailing: Container(
            height: 200,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  /* minWidth: 150,
                minHeight: 80,
                maxWidth: 196,
                maxHeight: 98, */
                  ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(imagelink, fit: BoxFit.cover)),
            ),
          ),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SelectBay(dept)));
          },
        ),
        Divider(height: 1, thickness: 0.5, indent: 10, endIndent: 10),
      ],
    );
  }
}

class popmenu {
  static const String FirstItem = 'เพิ่มเบย์แบบกำหนดเอง';
  static const String SecondItem = 'ล้างข้อมูลทั้งหมด';

  static const List<String> choices = <String>[
    FirstItem,
    SecondItem,
  ];
}
 */