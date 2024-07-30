import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class ManageDB {
  final BuildContext context;
  final fb = FirebaseDatabase.instance;
  List<Object?> rawData = [];
  List<String> firebaseKeys = [];
  List<Map<String, dynamic>> firebaseValues = [];

  ManageDB(this.context);

  Future<void> fetchDataFromFirebase() async {
    final DataSnapshot snapshot = await fb.ref().child('Stockcount').child('1').get();
    if (snapshot.value != null) {
      rawData = snapshot.value as List<Object?>;
      List<Map<String, dynamic>> transactionList = rawData.map((record) {
        var data = record as Map<String, dynamic>;
        return {
          "barcode": data['barcode'],
          "div": data['div'],
          "dept": data['dept'],
          "grp": data['grp'],
          "art": data['art'],
          "descr": data['descr'],
          "mutart": data['mutart'],
          "mutdescr": data['mutdescr']
        };
      }).toList();

      for (var transaction in transactionList) {
        await insertData('DataMain', transaction);
      }
    }
    await getDatabaseVersionFromFirebase();
  }

  Future<void> fetchDataFromFirebaseWithKey(String key, String storeName) async {
    final DataSnapshot snapshot = await fb.ref().child('Stockcount').child(key).get();
    if (snapshot.value != null) {
      rawData = snapshot.value as List<Object?>;
      List<Map<String, dynamic>> transactionList = rawData.map((record) {
        var data = record as Map<String, dynamic>;
        return {
          "barcode": data['barcode'],
          "div": data['div'],
          "dept": data['dept'],
          "grp": data['grp'],
          "art": data['art'],
          "descr": data['descr'],
          "mutart": data['mutart'],
          "mutdescr": data['mutdescr']
        };
      }).toList();

      for (var transaction in transactionList) {
        await insertData(storeName, transaction);
      }
    }
    await getDatabaseVersionFromFirebase();
  }

  Future<void> getDatabaseVersionFromFirebase() async {
    final snapshot = await fb
        .ref()
        .child('Stockcount')
        .child('3')
        .child('0')
        .child('databaseversion')
        .once();
    if (snapshot.snapshot.value != null) {
      int databaseVersion = snapshot.snapshot.value as int;
      await deleteStore('DataBaseVersion');
      await insertDatabaseVersion(databaseVersion);
    }
  }

  Future<Database> openDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, 'OfflineData.db');
    Database db = await databaseFactoryIo.openDatabase(dbLocation);
    return db;
  }

  Future<void> clearDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, 'OfflineData.db');
    await databaseFactoryIo.deleteDatabase(dbLocation);
  }

  Future<void> deleteStore(String storeName) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(storeName);
    await store.delete(db);
  }

  Future<int> insertDatabaseVersion(int version) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('DataBaseVersion');
    var keyID = await store.add(db, {'databaseversion': version});
    return keyID;
  }

  Future<int> insertData(String storeName, Map<String, dynamic> data) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(storeName);
    var keyID = await store.add(db, data);
    return keyID;
  }

  Future<int> insertDataMutation(Map<String, dynamic> data) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('DataMutation');
    var keyID = await store.add(db, data);
    return keyID;
  }

  Future<int> insertAisleBayData(Map<String, dynamic> data) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('AisleBay');
    var keyID = await store.add(db, data);
    return keyID;
  }

  Future<List<Map<String, dynamic>>> getAllData(String storeName) async {
    final Database db = await openDatabase();
    final StoreRef<int, Map<String, dynamic>> store = intMapStoreFactory.store(storeName);
    final List<RecordSnapshot<int, Map<String, dynamic>>> snapshots = await store.find(db);

    List<Map<String, dynamic>> convertedSnapshot = snapshots.map((record) {
      String status;
      switch (record['status'].toString()) {
        case '0':
          status = 'ยังไม่ได้นับ';
          break;
        case '8':
          status = 'กำลังนับ';
          break;
        case '9':
          status = 'ปิดเบย์แล้ว';
          break;
        default:
          status = 'ไม่ทราบสถานะ';
      }

      return {
        'aisle': record['aisle'],
        'bay': NumberFormat("000").format(int.parse(record['bay'].toString())),
        'div': record['div'],
        'status': status
      };
    }).toList();

    return convertedSnapshot;
  }

  Future<List<Map<String, dynamic>>> getSomeData(
      String storeName, String field, String value) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(storeName);
    var filter = Filter.equals(field, value);
    var finder = Finder(filter: filter);
    var snapshot = await store.find(db, finder: finder);
    List<Map<String, dynamic>> convertedSnapshot = snapshot.map((record) {
      return {
        'art': record['art'],
        'descr': record['descr'],
        'qty': record['qty']
      };
    }).toList();

    return convertedSnapshot;
  }

  Future<List<Map<String, dynamic>>> getItemLookupWithConvert(String barcode) async {
    dynamic convertedKey;
    String field;

    if (barcode.length == 13 && barcode.startsWith("25")) {
      convertedKey = barcode.substring(6, 12);
    } else if (barcode.length == 8 && barcode.startsWith("2")) {
      convertedKey = barcode.substring(1, 7);
    } else if (barcode.length == 13 &&
        (barcode.startsWith("21") ||
            barcode.startsWith("28") ||
            barcode.startsWith("29"))) {
      convertedKey = barcode.substring(0, 6) + "0000000";
    } else {
      convertedKey = barcode;
    }
    if (convertedKey.toString().startsWith("0") && convertedKey.toString().length == 6) {
      convertedKey = int.parse(convertedKey.toString()).toString();
    }

    if (convertedKey.toString().length > 6) {
      field = 'barcode';
      convertedKey = int.parse(convertedKey);
    } else {
      field = 'art';
      convertedKey = int.parse(convertedKey);
    }

    var db = await openDatabase();
    var store = intMapStoreFactory.store('ItemLookup');
    var filter = Filter.equals(field, convertedKey);
    var finder = Finder(filter: filter);
    var snapshot = await store.find(db, finder: finder);
    List<Map<String, dynamic>> convertedSnapshot = snapshot.map((record) {
      return {
        "art": record['art'],
        "arttype": record['arttype'],
        "barcode": record['barcode'],
        "contsellunit": record['contsellunit'],
        "dept": record['dept'],
        "descr": record['descr'],
        "descreng": record['descreng'],
        "grp": record['grp'],
        "grpdescr": record['grpdescr'],
        "price": record['price'],
        "subunitpack": record['subunitpack'],
        "supno": record['supno'],
        "vatno": record['vatno'],
      };
    }).toList();

    return convertedSnapshot;
  }

  Future<List<Map<String, dynamic>>> getMutationItems(dynamic art, dynamic notArt) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('DataMutation');
    var filter = Filter.and([Filter.equals('art', art), Filter.notEquals('artpack', notArt)]);
    var finder = Finder(filter: filter);
    var snapshot = await store.find(db, finder: finder);
    List<Map<String, dynamic>> convertedSnapshot = snapshot.map((record) {
      return {
        "dept": record['dept'],
        "grp": record['grp'],
        "art": record['art'],
        "descr": record['descr'],
        "artpack": record['artpack']
      };
    }).toList();
    return convertedSnapshot;
  }

  Future<void> deleteAll(String storeName) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(storeName);
    await store.delete(db);
  }

  Future<void> updateBayStatus(dynamic aisle, dynamic bay, String status) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('AisleBay');
    var filter = Filter.and([Filter.equals('aisle', aisle), Filter.equals('bay', bay)]);
    var finder = Finder(filter: filter);
    var snapshot = await store.find(db, finder: finder);

    if (snapshot.isNotEmpty) {
      var key = snapshot.first.key;
      await store.record(key).update(db, {'status': status});
    }
  }

  Future<void> resetBayStatus() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('AisleBay');
    var snapshot = await store.find(db);
    for (var record in snapshot) {
      await store.record(record.key).update(db, {'status': '0'});
    }
  }

  Future<List<Map<String, dynamic>>> getAllBayData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('AisleBay');
    var snapshot = await store.find(db);
    List<Map<String, dynamic>> convertedSnapshot = snapshot.map((record) {
      return {
        'aisle': record['aisle'],
        'bay': record['bay'],
        'div': record['div'],
        'status': record['status']
      };
    }).toList();
    return convertedSnapshot;
  }

  Future<void> insertAisleBayWithCheckDuplicate(List<Map<String, dynamic>> bayList) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('AisleBay');

    for (var bay in bayList) {
      var filter = Filter.and([
        Filter.equals('aisle', bay['aisle']),
        Filter.equals('bay', bay['bay']),
        Filter.equals('div', bay['div']),
      ]);
      var finder = Finder(filter: filter);
      var snapshot = await store.find(db, finder: finder);
      if (snapshot.isEmpty) {
        await store.add(db, {
          'div': bay['div'],
          'aisle': bay['aisle'],
          'bay': bay['bay'],
          'status': bay['status']
        });
      }
    }
  }

  Future<int> getDatabaseVersion() async {
    final Database db = await openDatabase();
    final StoreRef<int, Map<String, dynamic>> store = intMapStoreFactory.store('DataBaseVersion');
    final List<RecordSnapshot<int, Map<String, dynamic>>> snapshots = await store.find(db);

    if (snapshots.isEmpty) {
      return 0;
    } else {
      return snapshots.first['databaseversion'] as int;
    }
  }
}