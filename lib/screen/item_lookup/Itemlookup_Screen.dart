/* import 'package:alc_mobile_app/Screens/Itemlookup/ItemDetail_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class Itemlookup extends StatefulWidget {
  @override
  _ItemlookupState createState() => _ItemlookupState();
}

class _ItemlookupState extends State<Itemlookup> {
  TextEditingController ItemlookupController = TextEditingController();
  FocusNode _focus;
  bool _numeric = false;
  List<Map<String, dynamic>> itemstabs = [
    {
      'id': 'plu',
      'index': 0,
      'backgroundColoriconspeeddialchild': Colors.red[400],
      'iconspeeddialchild': 'PLU',
      'labelspeeddialchild': 'ค้นด้วย PLU',
      'hintextcontroller': 'PLU',
      'visibleScannerbtn': false,
      'page': findplu(),
      'keyboardtype': true,
      'maxlenght': 4,
      'functioncontroller': plucontroller()
    },
    {
      'id': 'descr',
      'index': 1,
      'backgroundColoriconspeeddialchild': Colors.red[600],
      'iconspeeddialchild': 'กขค',
      'labelspeeddialchild': 'ค้นด้วยชื่อสินค้า',
      'hintextcontroller': 'ชื่อสินค้า',
      'visibleScannerbtn': false,
      'page': findDescr(),
      'keyboardtype': false,
      'maxlenght': 30,
      'functioncontroller': descrcontroller()
    },
    {
      'id': 'art/barcode',
      'index': 2,
      'backgroundColoriconspeeddialchild': Colors.red[900],
      'iconspeeddialchild': '123',
      'labelspeeddialchild': 'ค้นด้วย Art/Barcode',
      'hintextcontroller': 'Art/Barcode',
      'visibleScannerbtn': true,
      'page': Itemdetail(),
      'keyboardtype': true,
      'maxlenght': 14,
      'functioncontroller': articelbarcodecontroller()
    },
  ];
  int currentIndex = 2;

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    _focus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focus?.dispose();
    super.dispose();
  }

  void _switch() {
    if (_focus.hasFocus) {
      ItemlookupController.clear();
      if (itemstabs[currentIndex]['keyboardtype'] != _numeric) {
        _focus.unfocus();
        setState(() {
          _numeric = !_numeric;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _focus.requestFocus(),
          );
        });
      }
    } else {
      if (itemstabs[currentIndex]['keyboardtype'] != _numeric) {
        setState(() {
          _numeric = !_numeric;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: itemstabs[currentIndex]['page'],
      /* bottomNavigationBar: Column(
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
                    maxLength: itemstabs[currentIndex]['maxlenght'],
                    focusNode: _focus,
                    textAlignVertical: TextAlignVertical.center,
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                    textAlign: TextAlign.center,
                    keyboardType: itemstabs[currentIndex]['keyboardtype']
                        ? TextInputType.number
                        : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: itemstabs[currentIndex]['hintextcontroller'],
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
                    controller: ItemlookupController,
                    onChanged: itemstabs[currentIndex]['functioncontroller'],
                  ),
                ),
                Visibility(
                  visible: itemstabs[currentIndex]['visibleScannerbtn'],
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(100)),
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.only(left: 10),
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        /*  Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Itemdetail())); */
                      },
                      icon: Icon(
                        Icons.add,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ), */
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpeedDial(
            icon: Icons.manage_search,
            activeIcon: Icons.close,
            spacing: 3,
            openCloseDial: ValueNotifier<bool>(false),
            childPadding: EdgeInsets.all(5),
            spaceBetweenChildren: 4,
            buttonSize: 40,
            childrenButtonSize: 40.0,
            visible: true,
            direction: SpeedDialDirection.Up,
            switchLabelPosition: false,
            closeManually: false,
            renderOverlay: true,
            //overlayColor: Colors.black,
            //overlayOpacity: 0.2,
            /* onOpen: () => print('OPENING DIAL'),
            onClose: () => print('DIAL CLOSED'), */
            useRotationAnimation: true,
            // foregroundColor: Colors.black,
            // backgroundColor: Colors.white,
            // activeForegroundColor: Colors.red,
            // activeBackgroundColor: Colors.blue,
            elevation: 2.0,
            isOpenOnStart: false,
            animationSpeed: 200,
            shape: StadiumBorder(),
            children: [
              for (final tab in itemstabs)
                new SpeedDialChild(
                  child: Center(
                    child: Text(
                      tab['iconspeeddialchild'],
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  backgroundColor: tab['backgroundColoriconspeeddialchild'],
                  foregroundColor: Colors.white,
                  label: tab['labelspeeddialchild'],
                  labelStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  onTap: () {
                    onTabTapped(tab['index']);
                    _switch();
                  },
                ),
            ],
          ),
          SizedBox(
            height: 60,
          )
        ],
      ),
    );
  }

  static articelbarcodecontroller() {}
  static plucontroller() {}
  static descrcontroller() {}

  static findArtBarcode() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('descr'),
            Text('descreng'),
            Text('art'),
            Container(
                color: Colors.yellow[300],
                height: 100,
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('    ', style: TextStyle(fontSize: 60)),
                    Text(
                      '1,085',
                      style: TextStyle(fontSize: 60),
                    ),
                    Text('  .-', style: TextStyle(fontSize: 60))
                  ],
                ))),
            Row(
              children: [
                Text('price per unit'),
              ],
            ),
            Row(
              children: [
                Text('plu'),
              ],
            ),
            Row(
              children: [
                Text('barcode'),
              ],
            ),
            Row(
              children: [
                Text('supplier No'),
              ],
            ),
            Row(
              children: [
                Text('Dept'),
              ],
            ),
            Row(
              children: [
                Text('class'),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mutation'),
                TextButton(
                    onPressed: null,
                    child: Text('867551 - แอปเปิ้ลบรีซ #113 - ขายลัง')),
                TextButton(
                    onPressed: null,
                    child: Text('867552 - แอปเปิ้ลบรีซ #113 - แพค 6')),
                TextButton(
                    onPressed: null,
                    child: Text('867553 - แอปเปิ้ลบรีซ #113 - แพค 10')),
              ],
            )
          ],
        ),
      ),
    );
  }

  static findplu() {
    return Container(
      child: Center(
        child: Text('find plu'),
      ),
    );
  }

  static findDescr() {
    return Container(
      child: Center(
        child: Text('find descr'),
      ),
    );
  }
}
 */