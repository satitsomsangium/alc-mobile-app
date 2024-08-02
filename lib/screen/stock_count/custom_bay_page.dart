import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:alc_mobile_app/controller/db_controller.dart';
import 'package:alc_mobile_app/model/bay_model.dart';
import 'package:alc_mobile_app/model/database_store_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CustomBayPage extends StatefulWidget {
  const CustomBayPage({super.key});

  @override
  State<CustomBayPage> createState() => _CustomBayPageState();
}

class _CustomBayPageState extends State<CustomBayPage> {
  String dropdownValue = 'เลือกแผนก';
  final aisleController = TextEditingController();
  final bayStartController = TextEditingController();
  final bayEndController = TextEditingController();
  Color divcolor = Colors.red.shade300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'เพิ่มเบย์แบบกำหนดเอง',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buttonRow(),
            const SizedBox(height: 10),
            const Divider(),
            const Row(
              children: [
                Text('กำหนด Aisle - Bay เอง', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),),
              ],
            ),
            dropdownDivision(),
            aisleBayFrom(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow()]),
                child: FutureBuilder<List<Bay>>(
                  future: DbController.getAllAisleBays(),
                  builder: (BuildContext context, AsyncSnapshot<List<Bay>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          const LinearProgressIndicator(),
                          Expanded(child: Container())
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('ยังไม่มี Aisle - Bay'));
                    } else {
                      List<Bay> values = snapshot.data!;
                      return ListView.builder(
                        itemCount: values.length,
                        itemBuilder: (BuildContext context, int index) {
                          Bay bay = values[index];
                          Color divColor;

                          switch (bay.div) {
                            case 'FV':
                              divColor = Colors.blue.shade100;
                              break;
                            case 'BU':
                              divColor = Colors.red.shade100;
                              break;
                            case 'FI':
                              divColor = Colors.green.shade100;
                              break;
                            case 'BK':
                              divColor = Colors.orange.shade100;
                              break;
                            case 'FZ':
                              divColor = Colors.purple.shade100;
                              break;
                            default:
                              divColor = Colors.grey.shade100;
                          }

                          return Container(
                            color: divColor,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '${bay.div} - ${bay.aisle} - ${bay.bay}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  indent: 10,
                                  endIndent: 10,
                                ),
                              ],
                            ),
                          );
                        },
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

  Widget buttonRow() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            MyAlertDialog.showDefaultDialog(
              title: 'เซ็ตเบย์ตามค่าเริ่มต้น',
              content: 'การดำเนินการนี้จะลบเบย์และข้อมูลในเบย์ที่บันทึกไว้ทั้งหมด',
              isNoButton: true,
              onPressYes: () async{
                Get.back();
                Get.context!.loaderOverlay.show();
                await DbController.setAisleBayToDefault();
                setState(() {});
                Get.context!.loaderOverlay.hide();
              }
            );
          }, 
          child: const Text('เซ็ตเบย์ตามค่าเริ่มต้น')
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            MyAlertDialog.showDefaultDialog(
              title: 'ลบเบย์ทั้งหมด',
              content: 'การดำเนินการนี้จะลบเบย์และข้อมูลในเบย์ที่บันทึกไว้ทั้งหมด',
              isNoButton: true,
              onPressYes: () async{
                Get.back();
                Get.context!.loaderOverlay.show();
                await DbController.deleteStore(DatabaseStore.aisleBay);
                await DbController.countAisleBayInit();
                setState(() {});
                Get.context!.loaderOverlay.hide();
              }
            );
          }, 
          child: const Text('ลบเบย์ทั้งหมด')
        )
      ],
    );
  }

  Widget dropdownDivision() {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 20,
      elevation: 8,
      dropdownColor: Colors.white,
      underline: Container(
        height: 2,
        color: Colors.red[300],
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: <String>['เลือกแผนก', 'FV', 'BU', 'FI', 'BK', 'FZ']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
      isExpanded: true,
    );
  }

  Widget headerText(String message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
      ),
    );
  }

  Widget aisleBayFrom() {
    return Column(
      children: [
        headerText('Aisle'),
        TextField(
          textInputAction: TextInputAction.next,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
          maxLength: 3,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(8),
            isDense: true,
            counterText: "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(75),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[800],
            hintText: "Aisle",
            hintStyle: const TextStyle(
                fontWeight: FontWeight.w700, color: Colors.white60),
          ),
          controller: aisleController,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            headerText('Start Bay'),
            const SizedBox(
              width: 20,
            ),
            headerText('End Bay'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: TextField(
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLength: 3,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(8),
                  isDense: true,
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(75),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: "Start Bay",
                  hintStyle: const TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.white60),
                ),
                controller: bayStartController,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Flexible(
              child: TextField(
                textInputAction: TextInputAction.done,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLength: 3,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(8),
                  isDense: true,
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(75),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: "End Bay",
                  hintStyle: const TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.white60),
                ),
                controller: bayEndController,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: onSavePress,
            child: const Text(
              'บันทึก',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  void onSavePress() async {
    if (aisleController.text.isEmpty ||
        bayStartController.text.isEmpty ||
        bayEndController.text.isEmpty) {
      MyAlertDialog.showalertdialog(context, 'ข้อมูลไม่ถูกต้อง',
          'กรุณากรอกข้อมูลให้ครบ ก่อนบันทึกข้อมูล', 'ตกลง', false, '', () {
        Navigator.of(context).pop();
      });
    } else if (dropdownValue == 'เลือกแผนก') {
      MyAlertDialog.showalertdialog(context, 'ข้อมูลไม่ถูกต้อง',
          'กรุณาเลือกแผนกก่อนบันทึกข้อมูล', 'ตกลง', false, '', () {
        Navigator.of(context).pop();
      });
    } else if (aisleController.text.length != 3 ||
        int.parse(aisleController.text) < 100) {
      MyAlertDialog.showalertdialog(context, 'ข้อมูลไม่ถูกต้อง',
          'เลข Aisle ต้องไม่น้อยกว่า 100', 'ตกลง', false, '', () {
        Navigator.of(context).pop();
      });
    } else if (int.parse(bayEndController.text) <
        int.parse(bayStartController.text)) {
      MyAlertDialog.showalertdialog(context, 'ข้อมูลไม่ถูกต้อง',
          'เลขเบย์เริ่มต้น ต้องน้อยกว่า เบย์สุดท้าย', 'ตกลง', false, '', () {
        Navigator.of(context).pop();
      });
    } else {
      List<Bay> waitData = [];
      for (int i = int.parse(bayStartController.text); i <= int.parse(bayEndController.text); i++) {
        String formattedBay = i.toString().padLeft(3, '0');
        Bay currentData = Bay(
          aisle: aisleController.text,
          bay: formattedBay,
          div: dropdownValue,
          status: BayStatus.notCount,
          bayDataList: [],
        );
        waitData.add(currentData);
      }
      await DbController.insertAisleBayWithCheckDuplicate(waitData);
      aisleController.clear();
      bayStartController.clear();
      bayEndController.clear();
      setState(() {});
    }
  }
}