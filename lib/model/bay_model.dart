class Bay {
  String aisle;
  String bay;
  String div;
  BayStatus status;
  List<BayData> bayDataList;

  Bay({
    required this.aisle,
    required this.bay,
    required this.div,
    required this.status,
    required this.bayDataList,
  });

  // Method to convert Bay object to a map
  Map<String, dynamic> toMap() {
    return {
      'aisle': aisle,
      'bay': bay.padLeft(3, '0'), // Ensure bay is 3 characters long
      'div': div,
      'status': status.name,
      'bayDataList': bayDataList.map((data) => data.toMap()).toList(),
    };
  }

  // Factory method to create a Bay object from a map
  factory Bay.fromMap(Map<String, dynamic> map) {
    return Bay(
      aisle: map['aisle'] ?? '',
      bay: (map['bay'] ?? '').toString().padLeft(3, '0'), // Ensure bay is 3 characters long
      div: map['div'] ?? '',
      status: BayStatus.fromCode(map['status'] ?? '0'),
      bayDataList: (map['bayDataList'] as List?)
              ?.map((item) => BayData.fromMap(item))
              .toList() ??
          [],
    );
  }
}

class BayData {
  String art;
  String descr;
  double qty;

  BayData({
    required this.art,
    required this.descr,
    required this.qty,
  });

  // Convert BayData object to a map
  Map<String, dynamic> toMap() {
    return {
      'art': art,
      'descr': descr,
      'qty': qty,
    };
  }

  // Factory method to create a BayData object from a map
  factory BayData.fromMap(Map<String, dynamic> map) {
    return BayData(
      art: map['art'],
      descr: map['descr'],
      qty: map['qty'],
    );
  }
}

enum BayStatus {
  notCount('ยังไม่ได้นับ', '0'),
  counting('กำลังนับ', '8'),
  bayClose('ปิดเบย์แล้ว', '9');

  final String th;
  final String code;

  const BayStatus(this.th, this.code);

  // Factory method to create BayStatus from a string code
  static BayStatus fromCode(String code) {
    try {
      return BayStatus.values.firstWhere((e) => e.code == code);
    } catch (e) {
      return BayStatus.values.firstWhere((e) => e.name == code, orElse: () => BayStatus.notCount);
    }
  }
}