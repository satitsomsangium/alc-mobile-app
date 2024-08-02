import 'package:alc_mobile_app/controller/db_controller.dart';
import 'package:alc_mobile_app/model/bay_model.dart';
import 'package:alc_mobile_app/screen/stock_count/stock_count_data_page.dart';
import 'package:flutter/material.dart';

class SelectBayPage extends StatefulWidget {
  final String division;
  const SelectBayPage(this.division, {super.key});

  @override
  State<SelectBayPage> createState() => _SelectBayPageState();
}

class _SelectBayPageState extends State<SelectBayPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'เลือกเบย์',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: Text(
              widget.division,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Bay>>(
              future: DbController.getAisleBaysByDivision(widget.division),
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
                  return const Center(child: Text('ไม่พบข้อมูล Aisle - Bay'));
                } else {
                  List<Bay> values = snapshot.data!;
                  return ListView.builder(
                    itemCount: values.length,
                    itemBuilder: (BuildContext context, int index) {
                      Bay bay = values[index];
                      Color statusColor;
            
                      switch (bay.status) {
                        case BayStatus.counting:
                          statusColor = Colors.blue.shade300;
                          break;
                        case BayStatus.notCount:
                          statusColor = Colors.red.shade300;
                          break;
                        case BayStatus.bayClose:
                          statusColor = Colors.green.shade300;
                          break;
                        default:
                          statusColor = Colors.grey.shade300;
                      }
            
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              '${bay.aisle} - ${bay.bay}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 18),
                            ),
                            trailing: Container(
                              height: 40,
                              constraints:
                                  const BoxConstraints(minHeight: 40, minWidth: 40),
                              decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  bay.status.th,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                    builder: (_) => StockCountDataPage(
                                        bay.aisle,
                                        bay.bay,
                                        widget.division,
                                        bay.status)),
                              )
                                  .then((val) {
                                setState(() {});
                              });
                            },
                          ),
                          const Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 10,
                              endIndent: 10),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
