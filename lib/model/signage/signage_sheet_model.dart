/* import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:flutter/material.dart';

SignageTransaction {
  id : '',
  title : '',
  creator: '',
  device_id: '',
  status: SignageStatus,
  created: ?, // ถ้าใช้ร่วมกับ fierbase realtime database ควรใช้ type ไหนครับ
  send_time: ?,
  print_time: ?,
}

Signage {
  id: '',
  txnId: '',
  size; SigangeSize,
  type: SignageType,
  discount_tag: false, // ป้ายตัดราคา
  header_logo: true,
  list_product: [Product], // สามารถ สลับรายการได้ 
  created: ?,
}

// ขนาดป้าย
SignageSize {
  a3,
  a4,
  a5,
  a6
}

// จำนวนรายการในป้าย
SignageType {
  d1,
  d2,
  d3,
  d4,
  d5,
  d6,
  d7
}

SignageProduct {
  art: '',
  dscr: '',
  display_price: 20.75,
  original_price: 21.75 || null,
  promotion: ''
}





// อ่านข้อมูล
DatabaseReference ref = FirebaseDatabase.instance.ref("signages/123");
DatabaseEvent event = await ref.once();
if (event.snapshot.value != null) {
  Signage signage = Signage.fromRTDB(Map<String, dynamic>.from(event.snapshot.value as Map));
  // ใช้งาน signage...
}

// เขียนข้อมูล
Signage newSignage = Signage(/* ... */);
DatabaseReference ref = FirebaseDatabase.instance.ref("signages/${newSignage.id}");
await ref.set(newSignage.toRTDB());



// function ที่ต้องใช้

class SignageController extends GetxController {
  static SignageController get to => Get.find();

  static SignageController init({String? tag, bool permanent = false}) =>
      Get.put(SignageController(), tag: tag, permanent: permanent);

  static final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
}

ใน firebase จะมี 
signage : 
  transactions: [
    UUID : {
      'id': UUID,
      'title': 'แผ่นงานใหม่ ${runnumber} โดย ${authController.nickname.value}', 
      'creator': authController.nickname.value, 
      'device_id': authController.deviceId.value,
      'status': SignageStatus.pending.asString,
      'created': วันที่ และ เวลาสร้าง,
      'send_time': วันที่ และ เวลาส่ง || null,
      'print_time': วันที่ และ เวลาพิมพ์ป้าย || null,
    },
    UUID : {
      'id': UUID,
      'title': 'แผ่นงานใหม่ ${runnumber} โดย ${authController.nickname.value}', 
      'creator': authController.nickname.value, 
      'device_id': authController.deviceId.value,
      'status': '',
      'created': วันที่ และ เวลาสร้าง,
      'send_time': วันที่ และ เวลาส่ง || null,
      'print_time': วันที่ และ เวลาพิมพ์ป้าย || null,
    }
  ],
  signages: [
    UUID : {
      'id': UUID,
      'txnId': txnId,
      'size': '',
      'type': '',
      'discount_tag': false,
      'header_logo': true,
      'list_product': [],
      'created': วันที่ และ เวลาสร้าง,
    },
    UUID : {
      'id': UUID,
      'txnId': txnId,
      'size': '',
      'type': '',
      'discount_tag': false,
      'header_logo': true,
      'list_product': [],
      'created': วันที่ และ เวลาสร้าง,
    }
  ], 

// หน้า SignageTransactionListPage
1 get signage transaction list by device id // แสดงรายการทั้งหมดบนหน้า list signage
2 create new transaction // สร้าง txn ใหม่ 
UUID : {
  'id': UUID,
  'title': 'แผ่นงานใหม่ ${runNumber} โดย ${authController.nickname.value}', // ก่อนใส่ชื่อแผ่นงานเช็คด้วยว่า run number ไปถึงไหนแล้วก็ให้ run ต่อไปเรื่อย ๆ (เช็คจาก listของข้อ 1 ก็ได้)
  'creator': authController.nickname.value, 
  'device_id': authController.deviceId.value,
  'status': SignageStatus.pending,
  'created': now,
  'send_time': null,
  'print_time': null,
};
3 delete transaction by id // ลบข้อมูลใน transactions และ signages
4 change status transaction // ถ้า เปลี่ยนเป็น pending ให้ลบ send_time ออกด้วย

// หน้าแก้ไข และเพิ่มข้อมูล signages RequestSinagesPage
5 get signages list by txnId // แสดงรายการป้ายทั้งหนด ใน txnId นี้
6 insert signage // บันทึกข้อมูล ลง signages
UUID : {
  'id': UUID,
  'txnId': currentTxnId,
  'size': SignageSize,
  'type': SignageType,
  'discount_tag': false,
  'header_logo': true,
  'list_product': [SignageProduct],
  'created': วันที่ และ เวลาสร้าง,
}

7 delete signage by id
8 get signage by id // เพื่อเอาข้อมูลที่เคยบันทึกแล้วมาแก้
9 update signage by id // บันทึกข้อมูลทับข้อมูลเดิม



// ui

SignageTransactionListPage 

ListView.builder getSignageTransactionList 
  Container // มีเงา ขอบมน = 16 ระยะขอบ 16 => to RequestSinagesPage(id, title)
    Row [
      Column [
        getSignageTransactionList.title,
        Row [
          Text 'สถานะ : ', 
          Text '{getSignageTransactionList.status}' // ตัวหนา มีสีตาม status
        ],
        Text 'วันและเวลาที่สร้าง : {getSignageTransactionList.created}',
        status == send Text 'วันและเวลาที่ส่ง : {getSignageTransactionList.send_time}',
        status == printed Text 'วันและเวลาที่พิมพ์ : {getSignageTransactionList.print_time}',
      ],
      IconButton => showdialog title 'ลบรายการนี้' content 'ต้องการลบรายการนี้หรือไม่' 'ยกเลิก' => back 'ตกลง' => deleteTransaction
    ]
FloatingActionButton 'เพิ่มแผ่นงานใหม่' => createNewTransaction

RequestSinagesPage(id, title)

AppBar title
Listview.builder getSignagesList(id)
  Text // group by size + type
    Container
      Row [
        Column [
          ListView list_product
            Row [
              Text SignageProduct.art,
              isDiscountTag Text {SignageProduct.original_price / SignageProduct.display_price},
              Text SignageProduct.dscr
            ]
        ],
        IconButton showDialog ใช้ร่วมกับ (พอกดปุ่ม 'เพิ่ม') updateSignage,
        IconButton => showDialog title 'ลบป้ายนี้' content 'ต้องการลบป้ายนี้ใช่หรือไม่' 'ยกเลิก' => back 'ตกลง' => deleteSignage,
      ]
FloatingActionButton 'เพิ่มป้าย' // เมื่อกดจะมี รายการ ขนาดของป้ายลอยขึ้นมาเหนือปุ่ม เรียงเป็นแนวนอน 'A3', 'A4', 'A5', 'A6' value == SignageSize
  // เมื่อกดปุ่ม 'A3'|| 'A4'|| 'A5'|| 'A6' จะมีรายการของประเภทป้ายลอยขึ้นมาเหนือ แถว ขนาดป้าย d1, d2, d3, d4, d5, d6, d7 value == SignageType และมี
  // checkbox อยู่บน แถวของประเภทป้าย 2 checkbox อันแรกคือ true 'เอาหัวป้าย' อันที 2 false 'ตัดราคา' และ ทางขาวของ checkbox มีปุ่ม ElveteButton 'เพิ่ม'

พอกดปุ่ม 'เพิ่ม' => showDialog [
  title 'กรอกรายละเอียดป้าย',
  content [
    Text '{ขนาดที่เลือก} {ประเภทที่เลือก} {ตัดราคา == ture 'ตัดราคา'}{เอาหัวป้าย == false 'ไม่เอาหัว'}' 
    Column [
      Text 'รายการที่ 1',
      Row [
        TextField d1Controller
        IconButton => scanBarcode => getProductItem
        IconButton => showFavoriteItems => getFavoriteItemList => showDialog Listview Text '{รหัสสินค้า ชื่อสินค้า}'
      ],
      Text '{getProductItem.art} {getProductItem.dscr}'
      isDiscountTag Row [
        Text 'ตัดราคาจาก ',
        TextField d1DisconutTagController,
        Text '{d1DisconutTagController.text}/getProductItem.price'
      ]
    ],
    ...รายการที่ 2, 3, 4, 5, 6, 7 // ตาม enum SignageType { d1, d2, d3, d4, d5, d6, d7 }
  ],
  ปุ่ม [
    ElevatedButton 'เปลี่ยนรูปแบบป้าย' => clearAllTextController => back,
    ElevatedButton 'บันทึก' => insertSignage
  ]
]
 */


/* เพิ่ม function

1 insertFavoriteItems // ดูที่ save จากตัวอย่างครับ
await _database.ref().child('devices').child(deviceId.value).set({
      'device_id': deviceId.value,
      'nickname': newNickname,
      'created': DateTime.now().toIso8601String(),
      'favorite': [Product] // สร้างรูปแบบ id ให้สามารถ insert delete ได้ ใช้ art เป็น key ก็ได้
    });
class Product {
  final String art;
  final String dscr;
  final String price;

  Product({
    required this.art,
    required this.dscr,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      art: json['art'] ?? 0,
      dscr: json['dscr'] ?? '',
      price: json['price'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'art': art,
      'dscr': dscr,
      'price': price,
    };
  }
}

2 deleteFavoriteItemsByArticle
3 getFavoriteItemListByDeviceId */



/* ผมมีข้อมูลแบบนี้อยู่ครับ ช่วยทำหน้า flutter ให้ผมหน่อย โดยแบ่งกลุ่มตาม size + type 

list ของ groub 
  Text '{sized type}' + discount_tag 'ตัดราคา' + header_logo '' : ไม่เอาหัว
  list ของรายการที่ ตรงกับ '{sized type}' + discount_tag 'ตัดราคา' + header_logo '' : ไม่เอาหัว
    Table art (discount_tag == true {original_price / display_price}) dscr เรียงจาก วันที่เก่าสุด ไปใหม่สุด


{
  "25f01fb7-6b74-4243-870f-e609f5daf6dc": {
    "created": 1722973944757,
    "discount_tag": false,
    "header_logo": true,
    "id": "25f01fb7-6b74-4243-870f-e609f5daf6dc",
    "list_product": [
      {
        "art": "183082",
        "display_price": 38,
        "dscr": "น้ำดื่มเนปจูน600ซีซี*12ขวด",
        "promotion": ""
      },
      {
        "art": "236235",
        "display_price": 79,
        "dscr": "BKP แฟรงค์ไก่รมควันหนังกรอบ 500 ก",
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "d8ce7bd4-d7e1-4aa4-9558-e5cd920bae9d",
    "type": "d2"
  },
  "62b27319-19d8-438f-9dda-c472ee192ad4": {
    "created": 1722963011051,
    "discount_tag": false,
    "header_logo": true,
    "id": "62b27319-19d8-438f-9dda-c472ee192ad4",
    "list_product": [
      {
        "art": "52",
        "display_price": 91,
        "dscr": "เมจิเฟรชแพค946ซซ.*2ขาดมัน",
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d1"
  },
  "6d48df96-0d3e-44da-aec7-449171c282af": {
    "created": 1722963063753,
    "discount_tag": false,
    "header_logo": true,
    "id": "6d48df96-0d3e-44da-aec7-449171c282af",
    "list_product": [
      {
        "art": "236235",
        "display_price": 79,
        "dscr": "BKP แฟรงค์ไก่รมควันหนังกรอบ 500 ก",
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d1"
  },
  "792509a3-0112-4f07-a5b9-c235a382ef7e": {
    "created": 1722963747697,
    "discount_tag": false,
    "header_logo": true,
    "id": "792509a3-0112-4f07-a5b9-c235a382ef7e",
    "list_product": [
      {
        "art": "888888",
        "display_price": 445,
        "dscr": "ALCOTTกระดาษA4 70G. 5*500",
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d1"
  },
  "7aa983e8-3cc2-43bf-8a38-db82d86582ca": {
    "created": 1722963545243,
    "discount_tag": false,
    "header_logo": true,
    "id": "7aa983e8-3cc2-43bf-8a38-db82d86582ca",
    "list_product": [
      {
        "art": "236235",
        "display_price": 79,
        "dscr": "BKP แฟรงค์ไก่รมควันหนังกรอบ 500 ก",
        "promotion": ""
      },
      {
        "art": "52",
        "display_price": 91,
        "dscr": "เมจิเฟรชแพค946ซซ.*2ขาดมัน",
        "promotion": ""
      },
      {
        "art": "222000",
        "display_price": 24990,
        "dscr": "E-ต.เย็น16.2Q SAMSUNG#RT46H5570SL",
        "promotion": ""
      },
      {
        "art": "111111",
        "display_price": 0,
        "dscr": "โครงการรถเร่",
        "promotion": ""
      },
      {
        "art": "888888",
        "display_price": 445,
        "dscr": "ALCOTTกระดาษA4 70G. 5*500",
        "promotion": ""
      },
      {
        "art": "555555",
        "display_price": 1,
        "dscr": "ค่าขนส่งสินค้า - VAT",
        "promotion": ""
      },
      {
        "art": "999999",
        "display_price": 1,
        "dscr": "ค่าขนส่งสินค้า E-COMMERCE",
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d7"
  },
  "851e1f3e-db56-4d63-9f7c-48cb4b4e0ea7": {
    "created": 1722974343048,
    "discount_tag": true,
    "header_logo": true,
    "id": "851e1f3e-db56-4d63-9f7c-48cb4b4e0ea7",
    "list_product": [
      {
        "art": "183082",
        "display_price": 38,
        "dscr": "น้ำดื่มเนปจูน600ซีซี*12ขวด",
        "original_price": 63,
        "promotion": ""
      },
      {
        "art": "183082",
        "display_price": 38,
        "dscr": "น้ำดื่มเนปจูน600ซีซี*12ขวด",
        "original_price": 58.75,
        "promotion": ""
      }
    ],
    "size": "a5",
    "txnId": "d8ce7bd4-d7e1-4aa4-9558-e5cd920bae9d",
    "type": "d2"
  },
  "8806aa72-fad1-467b-a869-b48936405de1": {
    "created": 1722972787443,
    "discount_tag": false,
    "header_logo": true,
    "id": "8806aa72-fad1-467b-a869-b48936405de1",
    "list_product": [
      {
        "art": "52",
        "display_price": 91,
        "dscr": "เมจิเฟรชแพค946ซซ.*2ขาดมัน",
        "promotion": ""
      },
      {
        "art": "183082",
        "display_price": 38,
        "dscr": "น้ำดื่มเนปจูน600ซีซี*12ขวด",
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d2"
  },
  "a1a58116-19fb-4629-8c10-c1ad3c0a9057": {
    "created": 1722972813496,
    "discount_tag": false,
    "header_logo": true,
    "id": "a1a58116-19fb-4629-8c10-c1ad3c0a9057",
    "list_product": [
      {
        "art": "69",
        "display_price": 1,
        "dscr": "ส่วนลด/ส่วนเพิ่มราคา FF NON VAT",
        "promotion": ""
      },
      {
        "art": "999999",
        "display_price": 1,
        "dscr": "ค่าขนส่งสินค้า E-COMMERCE",
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d2"
  },
  "a3ffc3c3-c66e-46b4-a477-52dca0e909f2": {
    "created": 1722973233449,
    "discount_tag": true,
    "header_logo": true,
    "id": "a3ffc3c3-c66e-46b4-a477-52dca0e909f2",
    "list_product": [
      {
        "art": "52",
        "display_price": 91,
        "dscr": "เมจิเฟรชแพค946ซซ.*2ขาดมัน",
        "original_price": 69,
        "promotion": ""
      }
    ],
    "size": "a6",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d1"
  },
  "a698f3a8-8cdb-468b-9ee7-159e37ae0831": {
    "created": 1722963235935,
    "discount_tag": false,
    "header_logo": true,
    "id": "a698f3a8-8cdb-468b-9ee7-159e37ae0831",
    "list_product": [
      {
        "art": "236235",
        "display_price": 79,
        "dscr": "BKP แฟรงค์ไก่รมควันหนังกรอบ 500 ก",
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d1"
  },
  "a7ab25e3-5c88-4d44-a28d-484235ecd79c": {
    "created": 1722963673866,
    "discount_tag": false,
    "header_logo": true,
    "id": "a7ab25e3-5c88-4d44-a28d-484235ecd79c",
    "list_product": [
      {
        "art": "236235",
        "display_price": 79,
        "dscr": "BKP แฟรงค์ไก่รมควันหนังกรอบ 500 ก",
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d1"
  },
  "b0392bed-d921-4714-8fb4-c82f741e4965": {
    "created": 1722963824276,
    "discount_tag": false,
    "header_logo": true,
    "id": "b0392bed-d921-4714-8fb4-c82f741e4965",
    "list_product": [
      {
        "art": "236236",
        "display_price": 785,
        "dscr": "แบรนด์รังนกแท้-คลาสสิค 70มลX6",
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d1"
  },
  "b0ed4682-f2fe-45c1-bd88-d40dad737472": {
    "created": 1722973412835,
    "discount_tag": true,
    "header_logo": true,
    "id": "b0ed4682-f2fe-45c1-bd88-d40dad737472",
    "list_product": [
      {
        "art": "52",
        "display_price": 91,
        "dscr": "เมจิเฟรชแพค946ซซ.*2ขาดมัน",
        "original_price": 500,
        "promotion": ""
      },
      {
        "art": "183082",
        "display_price": 38,
        "dscr": "น้ำดื่มเนปจูน600ซีซี*12ขวด",
        "original_price": 52,
        "promotion": ""
      },
      {
        "art": "183082",
        "display_price": 38,
        "dscr": "น้ำดื่มเนปจูน600ซีซี*12ขวด",
        "original_price": 69,
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d3"
  },
  "c1ff1ec1-1cb2-4711-bc37-4933fe7d26a2": {
    "created": 1722963796218,
    "discount_tag": false,
    "header_logo": true,
    "id": "c1ff1ec1-1cb2-4711-bc37-4933fe7d26a2",
    "list_product": [
      {
        "art": "232446",
        "display_price": 15,
        "dscr": "แอปเปิ้ลกาล่า# 110-ลูกละ",
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d1"
  },
  "cd1da446-57c1-4f9c-a26b-694277ce9020": {
    "created": 1722978004012,
    "discount_tag": true,
    "header_logo": true,
    "id": "cd1da446-57c1-4f9c-a26b-694277ce9020",
    "list_product": [
      {
        "art": "52",
        "display_price": 91,
        "dscr": "เมจิเฟรชแพค946ซซ.*2ขาดมัน",
        "original_price": 96,
        "promotion": ""
      },
      {
        "art": "183082",
        "display_price": 38,
        "dscr": "น้ำดื่มเนปจูน600ซีซี*12ขวด",
        "original_price": 50,
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d2"
  },
  "fdfef7b5-6e1f-4788-ad78-601630af01b1": {
    "created": 1722963928171,
    "discount_tag": false,
    "header_logo": true,
    "id": "fdfef7b5-6e1f-4788-ad78-601630af01b1",
    "list_product": [
      {
        "art": "236237",
        "display_price": 185,
        "dscr": "#จานสี่เหลี่ยม ลึก 9 นิ้วสีส้ม1*3",
        "promotion": ""
      }
    ],
    "size": "a3",
    "txnId": "7bbf3672-451c-4fac-9726-deb16ed09717",
    "type": "d1"
  }
} */



// สร้างหน้าใหม่ สำหรับให้เจ้าหน้าที่ alc เอาข้อมูลไปพิมพ์ป้าย พิมพ์ป้าย
// ผมมีระบบขอป้ายราคาด้วยสมาร์ทโฟน ผมทำระบบเสร็จแล้ว และมีข้อมูลประมาณนี้ ผมกำลังจะทำระบบให้คนพิมพ์ป้ายสามารถเอาป้ายไปพิมพ์แบบง่าย ๆ ผ่าน แอปเดียวกัน แต่อยู่คนละเมนู ผมอยากให้มี noti แจ้งเมื่อมีคนส่งป้ายให้กับคนพิมพ์ และใน icon ก่อนเข้าหน้ารายละเอียดมีจำนวน transaction ที่ส่งแล้วเป็นตัวเลขอยู่บน icon พอกดเข้าไปจะมีรายการ transaction เมื่อคนพิมพ์ป้ายกดเข้าไปใน transaction นั้น จะเจอรายละเอียดที่ต้องพิมพ์ และในหน้ารายละเอียดจะมีปุ่มให้คนพิมพ์สามารถเปลี่ยนสถานะเป็น ปริ้นแล้วได้ด้วย และอยากให้มีระบบที่สามารถเลือกหลาย transaction เพื่อเอามารวมปริ้นทีเดียวแล้วมีปุ่มทำสถานะเป็นปริ้นแล้วหลาย transaction ได้  ผมมี code จากระบบ ส่งป้ายให้ สามาระเอาไปปรับใช้ได้เลย 




/* SignageAlcPage
  Scaffold



 */


/* 
ระบบ login ios
ผมต้องการให้ login ด้วยอีเมลเหมือนเดิม และ androd ใช้ android id เหมือนเดิม ทั้งหมด แต่ ios ผมจะให้เพิ่ม username ในหน้า set nick name ครับ ที่จะเอาไปใช้ แทนส่วนของ device id ถ้า ios ออกจากระบบ แล้ว login มาใหม่ ก็ให้เข้าด้วย email เหมือน เดิม แต่เพิ่มหน้า ให้กรอก username ด้วย เพราะ ระบบ login เดิมต้องเอา device id ไปค้นใน realtime db ก่อน ช่วยปรับปรุง code ให้ผมหน่อยครับ

 */
