class CheckPriceResponse {
  final String art;
  final String dscr;
  final String price;
  final List<String> image;

  CheckPriceResponse({
    required this.art,
    required this.dscr,
    required this.price,
    required this.image,
  });

  factory CheckPriceResponse.fromJson(Map<String, dynamic> json) {
    return CheckPriceResponse(
      art: json['art'] ?? '',
      dscr: json['dscr'] ?? '',
      price: json['price'] ?? '',
      image: List<String>.from(json['image'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'art': art,
      'dscr': dscr,
      'price': price,
      'image': image,
    };
  }
}

class CheckPriceMakroResponse {
  final String id;
  final String title;
  final String titleEn;
  final String brand;
  final String brandEn;
  final double displayPrice;
  final double originalPrice;
  final String unitSize;
  final List<String> images;
  final int inStock;

  CheckPriceMakroResponse({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.brand,
    required this.brandEn,
    required this.displayPrice,
    required this.originalPrice,
    required this.unitSize,
    required this.images,
    required this.inStock,
  });

  factory CheckPriceMakroResponse.fromJson(Map<String, dynamic> json) {
    var document = json['document'];
    return CheckPriceMakroResponse(
      id: document['id'] ?? '',
      title: document['title'] ?? '',
      titleEn: document['titleEn'] ?? '',
      brand: document['brand'] ?? '',
      brandEn: document['brandEn'] ?? '',
      displayPrice: (document['displayPrice'] ?? 0).toDouble(),
      originalPrice: (document['originalPrice'] ?? 0).toDouble(),
      unitSize: document['unitSize'] ?? '',
      images: List<String>.from(document['images'] ?? []),
      inStock: document['inStock'] ?? 0,
    );
  }
}