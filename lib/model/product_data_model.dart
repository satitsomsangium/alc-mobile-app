class ProductDataMain {
  final String? barcode;
  final String div;
  final String dept;
  final String? grpdescr;
  final String grp;
  final String art;
  final String descr;
  final String? mutart;
  final String? mutdescr;

  ProductDataMain({
    required this.barcode,
    required this.div,
    required this.dept,
    required this.grpdescr,
    required this.grp,
    required this.art,
    required this.descr,
    required this.mutart,
    required this.mutdescr,
  });

  factory ProductDataMain.fromMap(Map<String, dynamic> map) {
    return ProductDataMain(
      barcode: map['barcode']?.toString() ?? '',
      div: map['div']?.toString() ?? '',
      dept: map['dept']?.toString() ?? '',
      grpdescr: map['grpdescr']?.toString() ?? '',
      grp: map['grp']?.toString() ?? '',
      art: map['art']?.toString() ?? '',
      descr: map['descr']?.toString() ?? '',
      mutart: map['mutart']?.toString() ?? '',
      mutdescr: map['mutdescr']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'div': div,
      'dept': dept,
      'grpdescr': grpdescr,
      'grp': grp,
      'art': art,
      'descr': descr,
      'mutart': mutart,
      'mutdescr': mutdescr,
    };
  }
}

class ProductDataMutation {
  final String dept;
  final String grp;
  final String art;
  final String descr;
  final String artpack;

  ProductDataMutation({
    required this.dept,
    required this.grp,
    required this.art,
    required this.descr,
    required this.artpack,
  });

  factory ProductDataMutation.fromMap(Map<String, dynamic> map) {
    return ProductDataMutation(
      dept: map['dept']?.toString() ?? '',
      grp: map['grp']?.toString() ?? '',
      art: map['art']?.toString() ?? '',
      descr: map['descr']?.toString() ?? '',
      artpack: map['artpack']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dept': dept,
      'grp': grp,
      'art': art,
      'descr': descr,
      'artpack': artpack,
    };
  }
}

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