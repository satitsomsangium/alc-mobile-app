class MakroProductDetail {
  /* final double displayPrice; */
  final String id;
  final List<String> images;
  final int inStock;
  final String makroId;
  /* final double originalPrice; */
  final String productId;
  final String seller;
  final String sku;
  final int soldCount;
  final String title;
  final String titleEn;
  final String unitSize;
  final int inventoryQuantity;
  final String storeCode;

  MakroProductDetail({
    /* required this.displayPrice, */
    required this.id,
    required this.images,
    required this.inStock,
    required this.makroId,
    /* required this.originalPrice, */
    required this.productId,
    required this.seller,
    required this.sku,
    required this.soldCount,
    required this.title,
    required this.titleEn,
    required this.unitSize,
    required this.inventoryQuantity,
    required this.storeCode,
  });

  factory MakroProductDetail.fromJson(Map<String, dynamic> json) {
    return MakroProductDetail(
      /* displayPrice: json['displayPrice'] ?? 0.0, */
      id: json['id'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      inStock: json['inStock'] ?? 0,
      makroId: json['makroId'] ?? '',
      /* originalPrice: json['originalPrice'] ?? 0.0, */
      productId: json['productId'] ?? '',
      seller: json['seller'] ?? '',
      sku: json['sku'] ?? '',
      soldCount: json['soldCount'] ?? 0,
      title: json['title'] ?? '',
      titleEn: json['titleEn'] ?? '',
      unitSize: json['unitSize'] ?? '',
      inventoryQuantity: json['inventoryQuantity'] ?? 0,
      storeCode: json['storeCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      /* 'displayPrice': displayPrice, */
      'id': id,
      'images': images,
      'inStock': inStock,
      'makroId': makroId,
      /* 'originalPrice': originalPrice, */
      'productId': productId,
      'seller': seller,
      'sku': sku,
      'soldCount': soldCount,
      'title': title,
      'titleEn': titleEn,
      'unitSize': unitSize,
      'inventoryQuantity': inventoryQuantity,
      'storeCode': storeCode,
    };
  }
}