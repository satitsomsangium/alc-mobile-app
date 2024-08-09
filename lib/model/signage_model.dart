enum SignageStatus { pending, sent, printed, deleted }

extension SignageStatusExtension on SignageStatus {
  String get asString {
    switch (this) {
      case SignageStatus.pending:
        return 'รอส่ง';
      case SignageStatus.sent:
        return 'ส่งแล้ว';
      case SignageStatus.printed:
        return 'พิมพ์แล้ว';
      case SignageStatus.deleted:
        return 'ลบแล้ว';
    }
  }
}

enum SignageSize { a3, a4, a5, a6 }

extension SignageSizeExtension on SignageSize {
  String get asString {
    switch (this) {
      case SignageSize.a3:
        return 'A3';
      case SignageSize.a4:
        return 'A4';
      case SignageSize.a5:
        return 'A5';
      case SignageSize.a6:
        return 'A6';
    }
  }
}

enum SignageType { d1, d2, d3, d4, d5, d6, d7 }

extension SignageTypeExtension on SignageType {
  String get asString {
    switch (this) {
      case SignageType.d1:
        return 'D1';
      case SignageType.d2:
        return 'D2';
      case SignageType.d3:
        return 'D3';
      case SignageType.d4:
        return 'D4';
      case SignageType.d5:
        return 'D5';
      case SignageType.d6:
        return 'D6';
      case SignageType.d7:
        return 'D7';
    }
  }
}

class SignageTransaction {
  final String id;
  final String title;
  final String creator;
  final String deviceId;
  SignageStatus status;
  final DateTime created;
  DateTime? sendTime;
  DateTime? printTime;

  SignageTransaction({
    required this.id,
    required this.title,
    required this.creator,
    required this.deviceId,
    this.status = SignageStatus.pending,
    required this.created,
    this.sendTime,
    this.printTime,
  });

  factory SignageTransaction.fromRTDB(Map<String, dynamic> map) {
    return SignageTransaction(
      id: map['id'],
      title: map['title'],
      creator: map['creator'],
      deviceId: map['device_id'],
      status: SignageStatus.values.firstWhere(
        (e) => e.toString() == 'SignageStatus.${map['status']}',
        orElse: () => SignageStatus.pending,
      ),
      created: DateTime.fromMillisecondsSinceEpoch(map['created']),
      sendTime: map['send_time'] != null ? DateTime.fromMillisecondsSinceEpoch(map['send_time']) : null,
      printTime: map['print_time'] != null ? DateTime.fromMillisecondsSinceEpoch(map['print_time']) : null,
    );
  }

  Map<String, dynamic> toRTDB() {
    return {
      'id': id,
      'title': title,
      'creator': creator,
      'device_id': deviceId,
      'status': status.toString().split('.').last,
      'created': created.millisecondsSinceEpoch,
      'send_time': sendTime?.millisecondsSinceEpoch,
      'print_time': printTime?.millisecondsSinceEpoch,
    };
  }
}

class SignageProduct {
  final String art;
  final String dscr;
  final double displayPrice;
  final double? originalPrice;
  final String promotion;

  SignageProduct({
    required this.art,
    required this.dscr,
    required this.displayPrice,
    this.originalPrice,
    this.promotion = '',
  });

  factory SignageProduct.fromRTDB(Map<String, dynamic> map) {
    return SignageProduct(
      art: map['art'] ?? '',
      dscr: map['dscr'] ?? '',
      displayPrice: (map['display_price'] is int) 
          ? (map['display_price'] as int).toDouble() 
          : (map['display_price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['original_price'] is int)
          ? (map['original_price'] as int).toDouble()
          : (map['original_price'] as num?)?.toDouble(),
      promotion: map['promotion'] ?? '',
    );
  }

  Map<String, dynamic> toRTDB() {
    return {
      'art': art,
      'dscr': dscr,
      'display_price': displayPrice,
      'original_price': originalPrice,
      'promotion': promotion,
    };
  }
}

class Signage {
  final String id;
  final String txnId;
  final SignageSize size;
  final SignageType type;
  final bool discountTag;
  final bool headerLogo;
  final List<SignageProduct> listProduct;
  final DateTime created;

  Signage({
    required this.id,
    required this.txnId,
    required this.size,
    required this.type,
    this.discountTag = false,
    this.headerLogo = true,
    required this.listProduct,
    required this.created,
  });

  factory Signage.fromRTDB(Map<String, dynamic> map) {
    return Signage(
      id: map['id'],
      txnId: map['txnId'],
      size: SignageSize.values.firstWhere(
        (e) => e.toString() == 'SignageSize.${map['size']}',
      ),
      type: SignageType.values.firstWhere(
        (e) => e.toString() == 'SignageType.${map['type']}',
      ),
      discountTag: map['discount_tag'] ?? false,
      headerLogo: map['header_logo'] ?? true,
      listProduct: (map['list_product'] as List)
          .map((item) => SignageProduct.fromRTDB(Map<String, dynamic>.from(item)))
          .toList(),
      created: DateTime.fromMillisecondsSinceEpoch(map['created']),
    );
  }

  Map<String, dynamic> toRTDB() {
    return {
      'id': id,
      'txnId': txnId,
      'size': size.toString().split('.').last,
      'type': type.toString().split('.').last,
      'discount_tag': discountTag,
      'header_logo': headerLogo,
      'list_product': listProduct.map((product) => product.toRTDB()).toList(),
      'created': created.millisecondsSinceEpoch,
    };
  }
}