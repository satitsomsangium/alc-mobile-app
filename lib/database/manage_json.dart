/* import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:alc_mobile_app/database/manage_db.dart';

class ManageJson {
  Future<void> updateItemLookup() async {
    final String response = await rootBundle.loadString('assets/json/itemlistfinal.json');
    final List<dynamic> data = json.decode(response);

    for (int i = 0; i < data.length; i++) {
      Map<String, dynamic> item = data[i];
      double loadingPercentage = (i / data.length * 100);
      String percentageDisplay = loadingPercentage.toStringAsFixed(2) + ' %';
      print('$i ${item['art']} .............$percentageDisplay');
      await ManageDB().insertData('ItemLookup', item);
    }
  }
} */