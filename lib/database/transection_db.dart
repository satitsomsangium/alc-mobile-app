import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

// เก็บข้อมูลที่บันทึกโดยผู้ใช้ data bay detail
class TransactionDB {
  Future<Database> openDatabase() async {
    //find location
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, 'BayDetail.db');
    //create database
    DatabaseFactory dbFactory = await databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  Future clearDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, 'BayDetail.db');
    var db = await databaseFactoryIo.openDatabase(dbLocation);
    await databaseFactoryIo.deleteDatabase(dbLocation);
  }

  Future<int> InsertData(String StoreName, getart, getdescr, getqty) async {
    var db = await this.openDatabase();
    var store = intMapStoreFactory.store(StoreName);
    var keyID =
        store.add(db, {'art': getart, 'descr': getdescr, 'qty': getqty});
    return keyID;
  }

  Future<List<dynamic>> loadAisleBayData() async {
    var db = await this.openDatabase();
    var store = intMapStoreFactory.store('AisleBay');
    var snapshot = await store.find(db);
    List transactionList = [];
    for (var record in snapshot) {
      transactionList.add({'Aisle': record['Aisle'], 'Bay': record['Bay']});
    }
    return transactionList;
  }

  Future<List<dynamic>> loadAllData(String StoreName) async {
    var db = await this.openDatabase();
    var store = intMapStoreFactory.store(StoreName);
    var snapshot = await store.find(db);
    List transactionList = [];
    for (var record in snapshot) {
      transactionList.add({
        'art': record['art'],
        'descr': record['descr'],
        'qty': record['qty']
      });
    }
    return transactionList;
  }

  Future delete(String StoreName, getart) async {
    Database db = await TransactionDB().openDatabase();
    var store = intMapStoreFactory.store(StoreName);
    var filter = Filter.equals('art', getart);
    var finder = Finder(filter: filter);
    await store.delete(db, finder: finder);
  }

  Future cancelbay(String getaislebay) async {
    Database db = await TransactionDB().openDatabase();
    var store = intMapStoreFactory.store(getaislebay);
    await store.delete(db);
  }

  Future<List<dynamic>> updateQTY(
      String StoreName, dynamic getart, String getqty) async {
    var db = await TransactionDB().openDatabase();
    var store = intMapStoreFactory.store(StoreName);
    var filter = Filter.equals('art', getart);
    var finder = Finder(filter: filter);
    var snapshot = await store.find(db, finder: finder);
    var key = snapshot[0].key;
    await store.record(key).update(db, {'qty': getqty});
    return snapshot;
  }

  Future<int> findDuplicate(String StoreName, dynamic getart) async {
    var db = await TransactionDB().openDatabase();
    var store = intMapStoreFactory.store(StoreName);
    var filter = Filter.equals('art', getart);
    var finder = Finder(filter: filter);
    var snapshot = await store.find(db, finder: finder);

    //ถ้ามี return 1 ถ้าไม่มี return 0
    return snapshot.length;
  }

  Future<Object?> findqty(String StoreName, dynamic getart) async {
    var db = await TransactionDB().openDatabase();
    var store = intMapStoreFactory.store(StoreName);
    var filter = Filter.equals('art', getart);
    var finder = Finder(filter: filter);
    var snapshot = await store.find(db, finder: finder);
    if (snapshot.isEmpty) {
      return '';
    } else {
      Object? qty = snapshot[0]['qty'];
      return qty;
    }
  }
}
