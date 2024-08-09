import 'dart:io';
import 'package:alc_mobile_app/model/bay_model.dart';
import 'package:alc_mobile_app/model/count_aisle_bay_model.dart';
import 'package:alc_mobile_app/model/database_store_model.dart';
import 'package:alc_mobile_app/model/product_data_model.dart';
import 'package:alc_mobile_app/service/download_progress_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class DbController extends GetxController {

  static DbController get to => Get.find();

  static DbController init({String? tag, bool permanent = false}) =>
      Get.put(DbController(), tag: tag, permanent: permanent);
  
  static String databaseFileName = 'stock-conunt-offline.db';

  static final DownloadProgress _downloadProgress = Get.put(DownloadProgress());

  @override
  void onInit() async {
    super.onInit();
    isOfflineDataReadyInit();
    countAisleBayInit();
  }

  static RxBool isOfflineDatabaseReady = false.obs;
  static Rx<CountAisleBay> countAisleBay = CountAisleBay(
      fvBay: 0,
      fvAisle: 0,
      buBay: 0,
      buAisle: 0,
      fiBay: 0,
      fiAisle: 0,
      bkBay: 0,
      bkAisle: 0,
      fzBay: 0,
      fzAisle: 0,
    ).obs;

  static Future<void> fetchDataFromFirebaseWithKey(String key, DatabaseStore storeName) async {
    final fb = FirebaseDatabase.instance;
    final DataSnapshot snapshot = await fb.ref().child('Stockcount').child(key).get();
    List<Object?> rawData = [];
    if (snapshot.value != null) {
      rawData = snapshot.value as List<Object?>;
      int totalItems = rawData.length;
      List<Map<String, dynamic>> transactionList = [];
      
      // Step 1: Processing data
      for (int i = 0; i < rawData.length; i++) {
        var record = rawData[i];
        var data = Map<String, dynamic>.from(record as Map);
        Map<String, dynamic> processedData;
        
        if (storeName == DatabaseStore.aisleBay) {
          String formattedBay = data['bay'].toString().padLeft(3, '0');
          processedData = Bay(
            aisle: data['aisle'].toString(),
            bay: formattedBay,
            div: data['div'].toString(),
            status: BayStatus.fromCode(data['status'].toString()),
            bayDataList: [],
          ).toMap();
        } else if (storeName == DatabaseStore.dataMutation) {
          processedData = ProductDataMutation.fromMap(data).toMap();
        } else {
          processedData = ProductDataMain.fromMap(data).toMap();
        }
        
        transactionList.add(processedData);
        
        // Update progress for processing
        double progress = (i + 1) / (totalItems * 2); // Divide progress by 2 for two-step process
        _downloadProgress.updateProgress(progress, 'Processing ${storeName.asString} (${i + 1}/$totalItems)');
      }
      
      // Step 2: Saving to DB
      /* double baseProgress = 0.5; */ // Start from 50%
      await insertData(storeName, transactionList);
      _downloadProgress.updateProgress(1.0, 'Completed ${storeName.asString}');
    }
  }

  static Future<Database> openDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, databaseFileName);
    Database db = await databaseFactoryIo.openDatabase(dbLocation);
    return db;
  }

  static Future<void> clearDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, databaseFileName);
    await databaseFactoryIo.deleteDatabase(dbLocation);
  }

  static Future<void> deleteStore(DatabaseStore storeName) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(storeName.asString);
    await store.delete(db);
  }

  static Future<void> insertData(DatabaseStore storeName, List<Map<String, dynamic>> dataList) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(storeName.asString);
    
    int totalItems = dataList.length;
    for (int i = 0; i < totalItems; i++) {
      await store.add(db, dataList[i]);
      double progress = (i + 1) / totalItems;
      _downloadProgress.updateProgress(
        progress, 
        'เพิ่มข้อมูล ${storeName.asString} (${i + 1}/$totalItems) \n${dataList[i]['descr']}'
      );
    }
  }

  static Future<void> loadAllDataFromFirebase() async {
    Get.dialog(
      AlertDialog(
        title: const Center(child: Text('ดาวน์โหลดข้อมูลลงอุปกรณ์', style: TextStyle(fontSize: 14),)),
        content: Obx(() => SizedBox(
          width: Get.width * 80 / 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(value: _downloadProgress.progress.value),
              const SizedBox(height: 16),
              Text('${(_downloadProgress.progress.value * 100).toStringAsFixed(2)}%'),
              const SizedBox(height: 8),
              Text(_downloadProgress.currentOperation.value),
            ],
          ),
        )),
      ),
      barrierDismissible: false,
    );

    _downloadProgress.updateProgress(0, 'เตรียมการดาวน์โหลด...');
    await deleteStore(DatabaseStore.dataMain);
    await deleteStore(DatabaseStore.dataMutation);
    await deleteStore(DatabaseStore.dataMainBarcode);

    await fetchDataFromFirebaseWithKey('1', DatabaseStore.dataMain);
    await fetchDataFromFirebaseWithKey('2', DatabaseStore.dataMutation);
    await fetchDataFromFirebaseWithKey('4', DatabaseStore.dataMainBarcode);

    _downloadProgress.updateProgress(1, 'Finalizing...');
    await isOfflineDataReadyInit();
    Get.back();
  }

  static Future<void> isOfflineDataReadyInit() async {
    Database db = await openDatabase();
    var storeDataMain = intMapStoreFactory.store(DatabaseStore.dataMain.asString);
    var storeDataMainBarcode = intMapStoreFactory.store(DatabaseStore.dataMainBarcode.asString);
    var storeDataMutation = intMapStoreFactory.store(DatabaseStore.dataMutation.asString);

    int countDataMain = await storeDataMain.count(db);
    int countDataMainBarcode = await storeDataMainBarcode.count(db);
    int countDataMutation = await storeDataMutation.count(db);
    
    isOfflineDatabaseReady.value = countDataMain > 0 && countDataMainBarcode > 0 && countDataMutation > 0;
  }

  static Future<void> countAisleBayInit() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);
    var snapshot = await store.find(db);

    int fvBay = 0, buBay = 0, fiBay = 0, bkBay = 0, fzBay = 0;
    Set<String> fvAisle = {}, buAisle = {}, fiAisle = {}, bkAisle = {}, fzAisle = {};

    for (var record in snapshot) {
      String div = record['div'].toString();
      String aisle = record['aisle'].toString();

      if (div == 'FV') {
        fvBay++;
        fvAisle.add(aisle);
      } else if (div == 'BU') {
        buBay++;
        buAisle.add(aisle);
      } else if (div == 'FI') {
        fiBay++;
        fiAisle.add(aisle);
      } else if (div == 'BK') {
        bkBay++;
        bkAisle.add(aisle);
      } else if (div == 'FZ') {
        fzBay++;
        fzAisle.add(aisle);
      }
    }

    countAisleBay.value = CountAisleBay(
      fvBay: fvBay,
      fvAisle: fvAisle.length,
      buBay: buBay,
      buAisle: buAisle.length,
      fiBay: fiBay,
      fiAisle: fiAisle.length,
      bkBay: bkBay,
      bkAisle: bkAisle.length,
      fzBay: fzBay,
      fzAisle: fzAisle.length
    );
  }

  static Future<void> setAisleBayToDefault() async {
    await deleteStore(DatabaseStore.aisleBay);
    await fetchDataFromFirebaseWithKey('0', DatabaseStore.aisleBay);
    await countAisleBayInit();
  }

  static Future<void> insertAisleBayWithCheckDuplicate(List<Bay> bayList) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);

    for (var bay in bayList) {
      var filter = Filter.and([
        Filter.equals('aisle', bay.aisle),
        Filter.equals('bay', bay.bay),
        Filter.equals('div', bay.div),
      ]);
      var finder = Finder(filter: filter);
      var snapshot = await store.find(db, finder: finder);
      if (snapshot.isEmpty) {
        await store.add(db, bay.toMap());
      }
    }
    await countAisleBayInit();
  }

  static Future<void> clearBayDataList(String aisle, String bay, String div) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);

    var filter = Filter.and([
      Filter.equals('aisle', aisle),
      Filter.equals('bay', bay),
      Filter.equals('div', div),
    ]);
    var finder = Finder(filter: filter);
    var snapshot = await store.findFirst(db, finder: finder);

    if (snapshot != null) {
      var bay = Bay.fromMap(snapshot.value);
      bay.bayDataList = []; // Clear the bayDataList
      bay.status = BayStatus.notCount; // Set status to notCount
      await store.record(snapshot.key).put(db, bay.toMap());
    }
  }

  static Future<void> clearAllBayDataLists() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);

    var finder = Finder();
    var snapshots = await store.find(db, finder: finder);

    for (var snapshot in snapshots) {
      var bay = Bay.fromMap(snapshot.value);
      bay.bayDataList = []; // Clear the bayDataList
      bay.status = BayStatus.notCount; // Set status to notCount
      await store.record(snapshot.key).put(db, bay.toMap());
    }
  }

  static Future<List<Bay>> getAllAisleBays() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);

    var finder = Finder();
    var snapshots = await store.find(db, finder: finder);

    List<Bay> bayList = snapshots.map((snapshot) {
      return Bay.fromMap(snapshot.value);
    }).toList();

    return bayList;
  }

  static Future<List<Bay>> getAisleBaysByDivision(String division) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);

    var filter = Filter.equals('div', division);
    var finder = Finder(filter: filter);
    var snapshots = await store.find(db, finder: finder);

    List<Bay> bayList = snapshots.map((snapshot) {
      return Bay.fromMap(snapshot.value);
    }).toList();
    return bayList;
  }

  static Future<BayStatus> changeBayStatus(String aisle, String bay, String div, BayStatus newStatus) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);

    var filter = Filter.and([
      Filter.equals('aisle', aisle),
      Filter.equals('bay', bay),
      Filter.equals('div', div),
    ]);
    var finder = Finder(filter: filter);
    var snapshot = await store.findFirst(db, finder: finder);

    if (snapshot != null) {
      var bayRecord = Bay.fromMap(snapshot.value);
      bayRecord.status = newStatus; // Update status to newStatus
      await store.record(snapshot.key).put(db, bayRecord.toMap());
      return bayRecord.status; // Return the new status
    } else {
      throw Exception("Bay not found");
    }
  }

  static Future<List<BayData>> getBayDataList(String aisle, String bay, String div) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);

    var filter = Filter.and([
      Filter.equals('aisle', aisle),
      Filter.equals('bay', bay),
      Filter.equals('div', div),
    ]);
    var finder = Finder(filter: filter);
    var snapshot = await store.findFirst(db, finder: finder);

    if (snapshot != null) {
      var bayRecord = Bay.fromMap(snapshot.value);
      return bayRecord.bayDataList;
    } else {
      throw Exception("Bay not found");
    }
  }

  static Future<ProductDataMain?> getOneItemWithConvert(String getBarcode) async {
    // ignore: unnecessary_null_comparison
    if (getBarcode == null) {
      return null;
    }

    String converttokey;
    String field;
    DatabaseStore databaseStore;

    // Convert the barcode
    if (getBarcode.length == 13 && getBarcode.substring(0, 2) == "25") {
      converttokey = getBarcode.substring(6, 12);
    } else if (getBarcode.length == 8 && getBarcode.substring(0, 1) == "2") {
      converttokey = getBarcode.substring(1, 7);
    } else if (getBarcode.length == 13 &&
        (getBarcode.substring(0, 2) == "21" ||
            getBarcode.substring(0, 2) == "28" ||
            getBarcode.substring(0, 2) == "29")) {
      converttokey = "${getBarcode.substring(0, 6)}0000000";
    } else {
      converttokey = getBarcode;
    }

    if (converttokey.substring(0, 1) == "0" && converttokey.length == 6) {
      converttokey = int.parse(converttokey).toString();
    }

    if (converttokey.length > 6) {
      field = 'barcode';
      databaseStore = DatabaseStore.dataMainBarcode;
      converttokey = int.parse(converttokey).toString();
    } else {
      field = 'art';
      databaseStore = DatabaseStore.dataMain;
      converttokey = int.parse(converttokey).toString();
    }

    var db = await openDatabase();
    var store = intMapStoreFactory.store(databaseStore.asString);
    var filter = Filter.equals(field, converttokey);
    var finder = Finder(filter: filter);
    var snapshot = await store.find(db, finder: finder);

    if (snapshot.isNotEmpty) {
      var record = snapshot.first;
      return ProductDataMain(
        barcode: record['barcode']?.toString(),
        div: record['div']?.toString() ?? '',
        dept: record['dept']?.toString() ?? '',
        grpdescr: record['grpdescr']?.toString(),
        grp: record['grp']?.toString() ?? '',
        art: record['art']?.toString() ?? '',
        descr: record['descr']?.toString() ?? '',
        mutart: record['mutart']?.toString(),
        mutdescr: record['mutdescr']?.toString(),
      );
    } else {
      return null;
    }
  }

  static Future<List<ProductDataMutation>> getMutationItems(String? art, String notArt) async {
    if (art == null || art.isEmpty) {
      return [];
    }
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.dataMutation.asString);
    var filter = Filter.and([Filter.equals('art', art), Filter.notEquals('artpack', notArt)]);
    var finder = Finder(filter: filter);
    var snapshot = await store.find(db, finder: finder);
    List<ProductDataMutation> convertedSnapshot = snapshot.map((record) {
      return ProductDataMutation.fromMap(record.value as Map<String, dynamic>);
    }).toList();
    
    return convertedSnapshot;
  }

  static Future<BayData?> findArtInBayDataList(String aisle, String bay, String div, String art) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);

    var filter = Filter.and([
      Filter.equals('aisle', aisle),
      Filter.equals('bay', bay),
      Filter.equals('div', div),
    ]);
    var finder = Finder(filter: filter);
    var snapshot = await store.findFirst(db, finder: finder);

    if (snapshot != null) {
      var bayRecord = Bay.fromMap(snapshot.value);
      for (var bayData in bayRecord.bayDataList) {
        if (bayData.art == art) {
          return bayData;
        }
      }
    }
    return null;
  }

  static Future<void> addBayDataToBayDataList(String aisle, String bay, String div, BayData newBayData) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);

    var filter = Filter.and([
      Filter.equals('aisle', aisle),
      Filter.equals('bay', bay),
      Filter.equals('div', div),
    ]);
    var finder = Finder(filter: filter);
    var snapshot = await store.findFirst(db, finder: finder);

    if (snapshot != null) {
      var bayRecord = Bay.fromMap(snapshot.value);
      bayRecord.bayDataList.add(newBayData);
      bayRecord.status = BayStatus.counting; 
      await store.record(snapshot.key).put(db, bayRecord.toMap());
    } else {
      throw Exception("Bay not found");
    }
  }

  static Future<void> updateBayData(String aisle, String bay, String div, BayData updatedBayData) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);

    var filter = Filter.and([
      Filter.equals('aisle', aisle),
      Filter.equals('bay', bay),
      Filter.equals('div', div),
    ]);
    var finder = Finder(filter: filter);
    var snapshot = await store.findFirst(db, finder: finder);

    if (snapshot != null) {
      var bayRecord = Bay.fromMap(snapshot.value);
      int index = bayRecord.bayDataList.indexWhere((data) => data.art == updatedBayData.art);
      if (index != -1) {
        bayRecord.bayDataList[index] = updatedBayData;
      } else {
        bayRecord.bayDataList.add(updatedBayData);
      }
      bayRecord.status = BayStatus.counting;
      await store.record(snapshot.key).put(db, bayRecord.toMap());
    } else {
      throw Exception("Bay not found");
    }
  }

  static Future<BayStatus?> getBayStatus(String aisle, String bay, String div) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);

    var filter = Filter.and([
      Filter.equals('aisle', aisle),
      Filter.equals('bay', bay),
      Filter.equals('div', div),
    ]);
    var finder = Finder(filter: filter);
    var snapshot = await store.findFirst(db, finder: finder);

    if (snapshot != null) {
      var bayRecord = Bay.fromMap(snapshot.value);
      return bayRecord.status; // Return the status of the bay
    } else {
      return null; // Return null if the bay is not found
    }
  }

  static Future<void> removeBayDataFromBayDataList(String aisle, String bay, String div, String art) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(DatabaseStore.aisleBay.asString);

    var filter = Filter.and([
      Filter.equals('aisle', aisle),
      Filter.equals('bay', bay),
      Filter.equals('div', div),
    ]);
    var finder = Finder(filter: filter);
    var snapshot = await store.findFirst(db, finder: finder);

    if (snapshot != null) {
      var bayRecord = Bay.fromMap(snapshot.value);
      bayRecord.bayDataList.removeWhere((bayData) => bayData.art == art); // Remove BayData by art

      // If bayDataList is empty after removal, change the status to notCount
      if (bayRecord.bayDataList.isEmpty) {
        bayRecord.status = BayStatus.notCount; // Change the status to notCount
        await store.record(snapshot.key).put(db, bayRecord.toMap()); // Update the record in the database
      } else {
        await store.record(snapshot.key).put(db, bayRecord.toMap()); // Update the record in the database
      }
    } else {
      throw Exception("Bay not found");
    }
  }
}