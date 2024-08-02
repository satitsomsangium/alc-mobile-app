import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:alc_mobile_app/model/bay_model.dart';
import 'package:alc_mobile_app/controller/db_controller.dart';

class BarcodeGeneratorsPage extends StatelessWidget {
  final String aisle;
  final String bay;
  final String div;

  const BarcodeGeneratorsPage(this.aisle, this.bay, this.div, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$aisle - $bay ($div)')),
      body: FutureBuilder<List<BayData>>(
        future: DbController.getBayDataList(aisle, bay, div),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          List<BayData> bayDataList = snapshot.data!;
          return DefaultTabController(
            length: bayDataList.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: [
                    for (int i = 0; i < bayDataList.length; i++)
                      Tab(text: (i + 1).toString()),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: List.generate(
                      bayDataList.length,
                      (index) => _BayDataView(data: bayDataList[index], index: index + 1),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BayDataView extends StatelessWidget {
  final BayData data;
  final int index;

  const _BayDataView({Key? key, required this.data, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildCircleNumber(),
          const SizedBox(height: 20),
          _buildBarcode('รหัสสินค้า', data.art),
          const SizedBox(height: 20),
          Text(data.descr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildBarcode('จำนวน', data.qty.toString()),
        ],
      ),
    );
  }

  Widget _buildCircleNumber() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.red[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          index.toString(),
          style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBarcode(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 5),
        SizedBox(
          height: 160.sp,
          child: SfBarcodeGenerator(
            value: value,
            symbology: Code128(),
            showValue: true,
            textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}