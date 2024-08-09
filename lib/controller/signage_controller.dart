import 'dart:convert';

import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:alc_mobile_app/model/product_data_model.dart';
import 'package:alc_mobile_app/model/signage_model.dart';
import 'package:alc_mobile_app/service/config.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class SignageController extends GetxController {
  static SignageController get to => Get.find();

  static SignageController init({String? tag, bool permanent = false}) =>
      Get.put(SignageController(), tag: tag, permanent: permanent);

  static final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
  static final DatabaseReference _transactionsRef = firebaseDatabase.ref('signage/transactions');
  static final DatabaseReference _signagesRef = firebaseDatabase.ref('signage/signages');

  static final AuthController authController = Get.find<AuthController>();

  static RxList<SignageTransaction> transactionList = <SignageTransaction>[].obs;
  static RxList<SignageTransaction> printTransactionList = <SignageTransaction>[].obs;
  static RxList<Signage> signageList = <Signage>[].obs;
  static final RxBool isLoadingTransactions = false.obs;
  static final RxBool isLoadingSignages = false.obs;
  static final RxBool isLoadingPrintTransactions = false.obs;
  static final RxList<Product> favoriteItems = <Product>[].obs;
  static final RxBool isLoadingFavorites = false.obs;
  
  static final Rx<SignageStatus> transactionStatus = SignageStatus.pending.obs;
  static final Rx<SignageTransaction> signageTransaction = SignageTransaction(
    id: '',
    title: '',
    creator: '',
    deviceId: '',
    created: DateTime.now(),
  ).obs;

  static final RxInt pendingPrintCount = 0.obs;

  static RxList<String> selectedTransactions = <String>[].obs;
  static RxBool allSelected = false.obs;

  static Future<List<SignageTransaction>> getSignageTransactionList({isLoad = true}) async {
    if (isLoad) {
      isLoadingTransactions.value = true;
    }
    List<SignageTransaction> listSignageTransaction = [];
    try {
      final event = await _transactionsRef
          .orderByChild('device_id')
          .equalTo(authController.deviceId.value)
          .once();

      if (event.snapshot.value != null) {
        final map = event.snapshot.value as Map<dynamic, dynamic>;
        listSignageTransaction = map.entries
            .map((e) => SignageTransaction.fromRTDB(Map<String, dynamic>.from(e.value)))
            .toList();

        // เรียงลำดับรายการตามวันที่สร้างในลำดับจากมากไปน้อย
        listSignageTransaction.sort((a, b) => b.created.compareTo(a.created));

        transactionList.value = listSignageTransaction;
      } else {
        transactionList.clear();
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูล SignageTransaction: $e');
    } finally {
      if (isLoad) {
        isLoadingTransactions.value = false;
      }
    }

    return listSignageTransaction;
  }

  // 2. Create new transaction
  static Future<String> createNewTransaction(String title) async {
    // Fetch all transactions for the current device
    final transactions = await getSignageTransactionList(isLoad: false);
    
    // Find the maximum run number from existing titles
    int maxRunNumber = 0;
    final nickname = authController.nickname.value;
    String formatTitle = title != '' ? ' - $title' : '';
    
    // Updated regular expression
    RegExp reg = RegExp(r'^' + RegExp.escape(nickname) + r' (\d+)');
    
    for (var transaction in transactions) {
      final match = reg.firstMatch(transaction.title);
      if (match != null) {
        final runNumber = int.tryParse(match.group(1)!) ?? 0;
        if (runNumber > maxRunNumber) {
          maxRunNumber = runNumber;
        }
      }
    }
    
    // Set the new run number to be one more than the maximum found
    final newRunNumber = maxRunNumber + 1;
    
    // Create the new transaction
    final newTransaction = SignageTransaction(
      id: const Uuid().v4(),
      title: '$nickname $newRunNumber$formatTitle',
      creator: nickname,
      deviceId: authController.deviceId.value,
      status: SignageStatus.pending,
      created: DateTime.now(),
    );
    
    // Save the new transaction to the database
    await _transactionsRef.child(newTransaction.id).set(newTransaction.toRTDB());
    return newTransaction.id;
  }

  // 3. Delete transaction by id
  static Future<void> deleteTransaction(String id) async {
    await _transactionsRef.child(id).remove();
    // Delete associated signages
    final signagesEvent = await _signagesRef.orderByChild('txnId').equalTo(id).once();
    if (signagesEvent.snapshot.value != null) {
      final map = signagesEvent.snapshot.value as Map<dynamic, dynamic>;
      for (var signageId in map.keys) {
        await _signagesRef.child(signageId).remove();
      }
    }
  }

  // 4. Change status transaction
  static Future<void> changeTransactionStatus(String id, SignageStatus newStatus) async {
    final transactionData = (await _transactionsRef.child(id).once()).snapshot.value as Map<dynamic, dynamic>?;
    if (transactionData != null) {
      final transaction = SignageTransaction.fromRTDB(Map<String, dynamic>.from(transactionData));
      transaction.status = newStatus;
      if (newStatus == SignageStatus.pending) {
        transaction.sendTime = null;
      } else if (newStatus == SignageStatus.sent && transaction.sendTime == null) {
        transaction.sendTime = DateTime.now();
      } else if (newStatus == SignageStatus.printed && transaction.printTime == null) {
        transaction.printTime = DateTime.now();
      }
      await _transactionsRef.child(id).update(transaction.toRTDB());

      if (newStatus == SignageStatus.sent) {
        await sendNotificationToPrinters("มีป้ายใหม่รอพิมพ์", "กรุณาตรวจสอบรายการป้ายใหม่");
      } else if (newStatus == SignageStatus.printed) {
        await sendNotificationToRequester(authController.user.value!.uid, "พิมพ์ป้ายเสร็จแล้ว", "แผ่นงาน ${transaction.title} พิมพ์เสร็จเรียบร้อยแล้ว");
      }
    }
  }

  // 4.5
  static Future<SignageTransaction?> getSignageTransactionById(String id) async {
    SignageTransaction signageTransactionData;
    final transactionData = (await _transactionsRef.child(id).once()).snapshot.value as Map<dynamic, dynamic>?;
    if (transactionData != null) {
      signageTransactionData = SignageTransaction.fromRTDB(Map<String, dynamic>.from(transactionData));
      signageTransaction.value = signageTransactionData;
      transactionStatus.value = signageTransactionData.status;
      return signageTransactionData;
    }
    return null;
  }

  Future getSignagesList(List<String> txnIdList) async {
    isLoadingSignages.value = true;
    try {
      // สร้างลิสต์ของ Future ที่จะทำการดึงข้อมูลตาม txnId แต่ละตัว
      final futures = txnIdList.map((txnId) {
        return _signagesRef.orderByChild('txnId').equalTo(txnId).once();
      });

      // รอจนกว่าจะดึงข้อมูลทั้งหมดเสร็จ
      final results = await Future.wait(futures);

      // รวมผลลัพธ์จากแต่ละ txnId
      final allSignages = <Signage>[];
      for (final result in results) {
        if (result.snapshot.value != null) {
          final map = result.snapshot.value as Map;
          allSignages.addAll(
            map.entries
                .map((e) => Signage.fromRTDB(Map.from(e.value)))
                .toList(),
          );
        }
      }

      // อัพเดตรายการ signages
      signageList.value = allSignages;
    } catch (e) {
      print('Error fetching signages: $e');
    } finally {
      isLoadingSignages.value = false;
    }
  }

  // 6. Insert signage
  static Future<void> insertSignage(Signage newSignage) async {
    try {
      await _signagesRef.child(newSignage.id).set(newSignage.toRTDB());
      signageList.add(newSignage);
    } catch (e) {
      print('Error inserting signage: $e');
    }
  }

  // 7. Delete signage by id
  static Future<void> deleteSignage(String id) async {
    try {
      await _signagesRef.child(id).remove();
      signageList.removeWhere((signage) => signage.id == id);
    } catch (e) {
      print('Error deleting signage: $e');
    }
  }

  // 8. Get signage by id
  static Future<Signage?> getSignageById(String id) async {
    final event = await _signagesRef.child(id).once();
    if (event.snapshot.value != null) {
      return Signage.fromRTDB(Map<String, dynamic>.from(event.snapshot.value as Map));
    }
    return null;
  }

  // 9. Update signage by id
  static Future<void> updateSignage(Signage updatedSignage) async {
    try {
      await _signagesRef.child(updatedSignage.id).update(updatedSignage.toRTDB());
      int index = signageList.indexWhere((signage) => signage.id == updatedSignage.id);
      if (index != -1) {
        signageList[index] = updatedSignage;
      }
    } catch (e) {
      print('Error updating signage: $e');
    }
  }

  // Favorite Items

  // 1. insertFavoriteItems
  static Future<void> insertFavoriteItem(Product product) async {
    final deviceRef = firebaseDatabase.ref().child('devices').child(authController.deviceId.value);
    final favoriteRef = deviceRef.child('favorite');

    // สร้าง Map ของรายการโปรดโดยใช้ art เป็น key
    final Map<String, dynamic> favoriteItem = {
      product.art: product.toJson()
    };

    // อัปเดตหรือเพิ่มรายการโปรด
    await favoriteRef.update(favoriteItem);
  }

  // 2. deleteFavoriteItemsByArticle
  static Future<void> deleteFavoriteItemsByArticle(String article) async {
    try {
      final favoriteItemRef = firebaseDatabase.ref().child('devices').child(authController.deviceId.value).child('favorite').child(article);
      await favoriteItemRef.remove();
      favoriteItems.removeWhere((item) => item.art == article);
    } catch (e) {
      print('Error deleting favorite item: $e');
    }
  }

  // 3. getFavoriteItemListByDeviceId
  static Future<void> getFavoriteItemListByDeviceId() async {
    isLoadingFavorites.value = true;
    try {
      final favoriteRef = firebaseDatabase.ref().child('devices').child(authController.deviceId.value).child('favorite');
      final snapshot = await favoriteRef.get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        favoriteItems.value = values.entries.map((entry) => Product.fromJson(Map<String, dynamic>.from(entry.value))).toList();
      } else {
        favoriteItems.clear();
      }
    } catch (e) {
      print('Error fetching favorite items: $e');
    } finally {
      isLoadingFavorites.value = false;
    }
  }























  // ระบบ ส่งป้าย

  static Future<void> updatePendingPrintCount() async {
    final sentTransactions = await getPrintTransactions(isLoad: false);
    pendingPrintCount.value = sentTransactions.length;
  }

  static Future<List<SignageTransaction>> getPrintTransactions({isLoad = true}) async {
    if (isLoad) {
      isLoadingPrintTransactions.value = true;
    }
    List<SignageTransaction> listSignageTransaction = [];
    try {
      final event = await _transactionsRef
          .orderByChild('status')
          .equalTo(SignageStatus.sent.toString().split('.').last)
          .once();

      if (event.snapshot.value != null) {
        final map = event.snapshot.value as Map<dynamic, dynamic>;
        listSignageTransaction = map.entries
            .map((e) => SignageTransaction.fromRTDB(Map<String, dynamic>.from(e.value)))
            .toList();
        listSignageTransaction.sort((a, b) => b.created.compareTo(a.created));

        printTransactionList.value = listSignageTransaction;
      } else {
        printTransactionList.clear();
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูล PrintTransactions: $e');
    } finally {
      if (isLoad) {
        isLoadingPrintTransactions.value = false;
      }
    }

    return listSignageTransaction;
  }

  static void toggleSelection(String txnId) {
    if (selectedTransactions.contains(txnId)) {
      selectedTransactions.remove(txnId);
    } else {
      selectedTransactions.add(txnId);
    }
    allSelected.value = selectedTransactions.length == printTransactionList.length;
  }

  static void toggleSelectAll(bool value) {
    allSelected.value = value;
    if (value) {
      selectedTransactions.assignAll(printTransactionList.map((tx) => tx.id));
    } else {
      selectedTransactions.clear();
    }
  }

  static Future<void> markAsPrinted(List<String> transactionIds) async {
    for (String id in transactionIds) {
      await changeTransactionStatus(id, SignageStatus.printed);
    }
    await updatePendingPrintCount();
  }


  static Future<void> saveFCMToken(String userId, String token) async {
    await firebaseDatabase.ref('users/$userId/fcmToken').set(token);
  }

  static Future<String?> getFCMToken(String userId) async {
    final snapshot = await firebaseDatabase.ref('users/$userId/fcmToken').get();
    return snapshot.value as String?;
  }


  static Future<void> sendNotificationToPrinters(String title, String body) async {
    final printerTokens = await getPrinterTokens();
    for (String token in printerTokens) {
      await sendFCMMessage(token, title, body);
    }
  }

  static Future<void> sendNotificationToRequester(String userId, String title, String body) async {
    final token = await getFCMToken(userId);
    if (token != null) {
      await sendFCMMessage(token, title, body);
    } else {
      print('FCM token not found for user: $userId');
    }
  }

  static Future<void> sendFCMMessage(String token, String title, String body) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Config.fcmServerKey}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': token,
        },
      ),
    );

    if (response.statusCode == 200) {
      print('FCM request for device sent!');
    } else {
      print('FCM request for device failed with status: ${response.statusCode}');
    }
  }

  static Future<List<String>> getPrinterTokens() async {
    // ดึง token ของคนพิมพ์ป้ายทั้งหมดจากฐานข้อมูล
    // ตัวอย่างเช่น:
    final snapshot = await firebaseDatabase.ref('printers').get();
    final printers = snapshot.value as Map<dynamic, dynamic>?;
    if (printers != null) {
      return printers.values.map((printer) => printer['fcmToken'] as String).toList();
    }
    return [];
  }
}