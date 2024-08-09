import 'package:alc_mobile_app/component/appbar.dart';
import 'package:alc_mobile_app/component/barcode_input.dart';
import 'package:alc_mobile_app/controller/api_controller.dart';
import 'package:alc_mobile_app/controller/firebase_controller.dart';
import 'package:alc_mobile_app/model/check_price_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CheckPricePage extends StatefulWidget {
  const CheckPricePage({super.key});

  @override
  State<CheckPricePage> createState() => _CheckPricePageState();
}

class _CheckPricePageState extends State<CheckPricePage> {
  final GlobalKey<BarcodeInputState> _inputBarcodeKey = GlobalKey<BarcodeInputState>();

  @override
  Widget build(BuildContext context) {
    FirebaseController.getDateModify();
    return Obx(() {
      DateTime? dateModify = FirebaseController.productDateModify.value;
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            appBar: const MyAppBar(
              title: 'เช็คราคา', 
              popupMenu: SizedBox.shrink(),
              color1: Color(0xFFFF7765),
              color2: Color(0xFFF7A23C)
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dateModifyStatus(dateModify),
                  priceDetail(),
                  imagePreview(),
                ],
              ),
            ),
            bottomSheet: BarcodeInput(
              key: _inputBarcodeKey,
              onPressedBuntton: (String? barcode) async {
                if (barcode != null) {
                  await ApiController.checkPriceWithImages(barcode);
                }
                _inputBarcodeKey.currentState?.barcodeController.clear();
              },
              onInputChange: (String value) async {
                await ApiController.checkPriceWithImages(value);
              },
            )
          ),
      );
      },
    );
  }

  Widget dateModifyStatus(DateTime? dateModify) {
    final DateTime now = DateTime.now();
    final outputFormat = DateFormat("d MMM yyyy HH:mm", "th_TH");
    String formattedDate = '';
    String updateStatus = '';
    Color colorStatus = Colors.black87;

    if (dateModify != null) {
      int yearBE = dateModify.year + 543;
      formattedDate = outputFormat.format(dateModify);
      formattedDate = formattedDate.replaceFirst(RegExp(r'\d{4}'), yearBE.toString());
      if (dateModify.day != now.day || dateModify.month != now.month || dateModify.year != now.year) {
        colorStatus = Colors.red;
        updateStatus = 'กรุณาแจ้ง ALC อัปเดตราคา';
      } else if (dateModify.hour < 5 || (dateModify.hour == 5 && dateModify.minute < 40)) {
        colorStatus = Colors.yellow[800]!;
        updateStatus = 'วันนี้ยังไม่มีการปรับราคา';
      } else {
        colorStatus = Colors.lightGreen;
        updateStatus = 'อัปเดตแล้ว';
      }
    } else {
      updateStatus = 'Unknown';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('สถานะข้อมูล:  ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              Text(updateStatus, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colorStatus)),
            ],
          ),
          Text('อัปเดตราคาล่าสุด: $formattedDate', style: const TextStyle(fontSize: 16),)
        ],
      ),
    );
  }

  Widget priceDetail() {
    final priceFormat = NumberFormat('#,##0.00', 'th_TH');
    final product = FirebaseController.product.value;
    String formattedPrice = 'XXX';

    if (product.price != 'XXX') {
      try {
        final price = double.parse(product.price);
        formattedPrice = priceFormat.format(price);
      } catch (e) {
        debugPrint('เกิดข้อผิดพลาดในการแปลงราคา: $e');
      }
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Visibility(
        visible: product.art != 'XXXXXX',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.dscr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'รหัส: ${product.art}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                  constraints: BoxConstraints(
                    minWidth: Get.width * 0.45,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedPrice,
                        style: TextStyle(
                          fontSize: 45.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 29.sp, width: 30.sp),
                          Text(
                            '   ฿',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget imagePreview() {
    CheckPriceResponse checkPriceResponse = ApiController.productWithImage.value;
    final List<String> imageUrls = checkPriceResponse.image;
    return AspectRatio(
      aspectRatio: 16 / 9, 
      child: imageUrls.isEmpty
      ? const SizedBox()
      : ImagePreview(imageUrls: checkPriceResponse.image)
    );
  }
}

class ImagePreview extends StatefulWidget {
  final List<String> imageUrls;

  const ImagePreview({super.key, required this.imageUrls});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: widget.imageUrls.isEmpty
          ? const SizedBox()
          : Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    /* return CachedNetworkImage(
                      imageUrl: widget.imageUrls[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Text('เกิดข้อผิดพลาดในการโหลดรูปภาพ'),
                      ),
                    ); */
                    return CachedNetworkImage(
  imageUrl: _getOptimizedImageUrl(widget.imageUrls[index], width: 400, quality: 70),
  /* fit: BoxFit.contain, */
  placeholder: (context, url) => const Center(
    child: CircularProgressIndicator(),
  ),
  errorWidget: (context, url, error) => const Center(
    child: Text('เกิดข้อผิดพลาดในการโหลดรูปภาพ'),
  ),
);
                  },
                ),
                if (widget.imageUrls.length > 1) ...[
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: _currentPage > 0
                            ? () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: _currentPage < widget.imageUrls.length - 1
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  String _getOptimizedImageUrl(String originalUrl, {int width = 800, int quality = 80}) {
    Uri uri = Uri.parse(originalUrl);
    Map<String, String> queryParams = Map.from(uri.queryParameters);
    
    queryParams['w'] = width.toString();
    queryParams['q'] = quality.toString();

    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      path: uri.path,
      queryParameters: queryParams,
    ).toString();
  }
}