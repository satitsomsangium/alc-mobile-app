import 'package:alc_mobile_app/component/appbar.dart';
import 'package:alc_mobile_app/controller/api_controller.dart';
import 'package:alc_mobile_app/controller/firebase_controller.dart';
import 'package:alc_mobile_app/model/check_price_model.dart';
import 'package:alc_mobile_app/model/product_data_model.dart';
import 'package:alc_mobile_app/service/barcode_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CheckPricePage extends StatefulWidget {
  const CheckPricePage({super.key});

  @override
  State<CheckPricePage> createState() => _CheckPricePageState();
}

class _CheckPricePageState extends State<CheckPricePage> {
  final TextEditingController checkPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FirebaseController.getDateModify();
    return Obx(() {
      String dateModify = FirebaseController.productDateModify.value;
      return Scaffold(
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
                dataModifyStatus(dateModify),
                priceDetail(),
                imagePreview(),
              ],
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.black12, width: 0.3)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 2),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                        maxLength: 14,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(8),
                          isDense: true,
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(75),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[800],
                          hintText: "สแกนหรือพิมพ์รหัสสินค้า",
                          hintStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white60),
                        ),
                        controller: checkPriceController,
                        onChanged: (value) async {
                          await ApiController.checkPriceWithImages(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(100)),
                      width: 40,
                      height: 40,
                      child: IconButton(
                        onPressed: () async {
                          String? barcodeResponse = await BarcodeService.scanAndConvert();
                          if (barcodeResponse != null) {
                            await ApiController.checkPriceWithImages(barcodeResponse);
                          }
                          checkPriceController.clear();
                        },
                        icon: const Icon(Icons.add, size: 25, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        );
      },
    );
  }

  Widget dataModifyStatus(String dataModify) {
    final int currentDay = DateTime.now().day;
    String updateStatus = '';
    Color colorStatus = Colors.black87;
    if (dataModify != '') {
      if (dataModify.substring(2, (dataModify.indexOf('/'))) != currentDay.toString()) {
        colorStatus = Colors.red;
        updateStatus = 'กรุณาแจ้ง ALC อัปเดตราคา';
      } else if (dataModify.substring((dataModify.indexOf(':') - 2), (dataModify.indexOf(':'))) == '05' &&
          dataModify.substring((dataModify.indexOf(':') + 1), (dataModify.indexOf(':') + 3)) == '40') {
        colorStatus = Colors.yellow[800]!;
        updateStatus = 'วันนี้ยังไม่มีการปรับราคา';
      } else {
        colorStatus = Colors.lightGreen;
        updateStatus = 'อัปเดตแล้ว';
      }
    } else {
      updateStatus = 'Unknow';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('สถานะข้อมูล: $updateStatus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colorStatus)),
          Text('อัปเดตราคาล่าสุด: $dataModify', style: const TextStyle(fontSize: 16),)
        ],
      ),
    );
  }

  Widget priceDetail() {
    Product product = FirebaseController.product.value;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.dscr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500), maxLines: 3, overflow: TextOverflow.ellipsis,),
          const SizedBox(height: 8),
          Text('รหัส: ${product.art}', style: const TextStyle(fontSize: 16),),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                constraints: BoxConstraints(
                  minWidth: Get.width * 45 / 100
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${product.price} ', style: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.bold, color: Colors.white),),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 29.sp, width: 30.sp,),
                        Text('฿', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white),),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                return Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.contain,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดรูปภาพ'));
                  },
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
                              duration: const Duration(milliseconds: 300),
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
                              duration: const Duration(milliseconds: 300),
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
}