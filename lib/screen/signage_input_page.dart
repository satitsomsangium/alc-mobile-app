import 'dart:math';

import 'package:alc_mobile_app/component/button.dart';
import 'package:alc_mobile_app/component/my_alert_dialog.dart';
import 'package:alc_mobile_app/controller/firebase_controller.dart';
import 'package:alc_mobile_app/controller/signage_controller.dart';
import 'package:alc_mobile_app/model/product_data_model.dart';
import 'package:alc_mobile_app/model/signage_model.dart';
import 'package:alc_mobile_app/service/barcode_service.dart';
import 'package:alc_mobile_app/service/custom_number_keyboard.dart';
import 'package:alc_mobile_app/service/price_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class SignageInputPage extends StatefulWidget {
  final Signage sigange;

  const SignageInputPage({
    super.key,
    required this.sigange
  });

  @override
  State<SignageInputPage> createState() => _SignageInputPageState();
}

class _SignageInputPageState extends State<SignageInputPage> {
  final NumberFormat _numberFormat = NumberFormat("#,###", "th_TH");
  late List<TextEditingController> controllers;
  late List<TextEditingController> discountControllers;
  late List<BehaviorSubject<Product?>> productSubjects;
  late List<FocusNode> controllerFocusNodes;
  late List<FocusNode> discountControllerFocusNodes;
  bool isFormValid = false;

  late List<RxString> errorMessagesProduct;
  late List<RxString> errorMessagesDiscountTag;
  int _selectedTextFieldIndex = -1;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(7, (_) => TextEditingController());
    controllerFocusNodes = List.generate(7, (_) => FocusNode());
    discountControllerFocusNodes = List.generate(7, (_) => FocusNode());
    discountControllers = List.generate(7, (_) => TextEditingController());
    productSubjects = List.generate(7, (_) => BehaviorSubject<Product?>());
    errorMessagesProduct = List.generate(7, (_) => ''.obs);
    errorMessagesDiscountTag = List.generate(7, (_) => ''.obs);
    SignageController.getFavoriteItemListByDeviceId();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _populateFields();
    });
    _setupFocusListeners();
  }

  void _populateFields() {
    for (int i = 0; i < widget.sigange.listProduct.length; i++) {
      final product = widget.sigange.listProduct[i];
      controllers[i].text = product.art;
      if (widget.sigange.discountTag && product.originalPrice != null) {
        discountControllers[i].text = _numberFormat.format(product.originalPrice);
      }
      getProduct(i);
    }
  }

  void _setupFocusListeners() {
    for (int i = 0; i < controllerFocusNodes.length; i++) {
      controllerFocusNodes[i].addListener(() {
        if (controllerFocusNodes[i].hasFocus) {
          discountControllerFocusNodes[i].unfocus();
        }
      });
    }

    for (int i = 0; i < discountControllerFocusNodes.length; i++) {
      discountControllerFocusNodes[i].addListener(() {
        if (discountControllerFocusNodes[i].hasFocus) {
          controllerFocusNodes[i].unfocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var node in controllerFocusNodes) {
      node.dispose();
    }
    for (var node in discountControllerFocusNodes) {
      node.dispose();
    }
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var controller in discountControllers) {
      controller.dispose();
    }
    for (var subject in productSubjects) {
      subject.close();
    }
    super.dispose();
  }

  double getPrice(String text) {
    final cleanedText = text.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanedText) ?? 0.0;
  }

  void validateForm() {
    bool valid = true;
    Set<String> uniqueArtValues = {};
    Map<String, Set<int>> artPositions = {};

    for (int i = 0; i < widget.sigange.type.index + 1; i++) {
      if (controllers[i].text.isEmpty || productSubjects[i].valueOrNull == null) {
        errorMessagesProduct[i].value = 'กรุณากรอกรหัสสินค้า';
        valid = false;
      } else {
        errorMessagesProduct[i].value = '';
      }

      if (productSubjects[i].valueOrNull != null) {
        String artValue = productSubjects[i].value?.art ?? '';
        if (uniqueArtValues.contains(artValue)) {
          Set<int>? positions = artPositions[artValue];
          if (positions != null) {
            String positionsStr = positions.map((pos) => (pos + 1).toString()).join(', ');
            errorMessagesProduct[i].value = 'รหัสสินค้า $artValue ซ้ำกับรายการที่ $positionsStr';
          } else {
            errorMessagesProduct[i].value = 'รหัสสินค้า $artValue ซ้ำกัน';
          }
          valid = false;
        } else {
          uniqueArtValues.add(artValue);
          artPositions[artValue] = {i};
        }
      } else {
        continue;
      }

      String artValue = productSubjects[i].value?.art ?? '';
      if (artPositions.containsKey(artValue)) {
        artPositions[artValue]!.add(i);
      }

      if (widget.sigange.discountTag) {
        if (discountControllers[i].text.isEmpty) {
          errorMessagesDiscountTag[i].value = 'กรุณากรอกราคาเดิม';
          valid = false;
        } else {
          double originalPrice = getPrice(discountControllers[i].text);
          double displayPrice = productSubjects[i].valueOrNull != null
            ? double.tryParse(productSubjects[i].value?.price ?? '0') ?? 0
            : 0;
          if (originalPrice <= displayPrice) {
            errorMessagesDiscountTag[i].value = 'ราคาเดิมต้องมากกว่าราคาที่ลดแล้ว';
            valid = false;
          } else {
            errorMessagesDiscountTag[i].value = '';
          }
        }
      }
    }

    setState(() {
      isFormValid = valid;
    });
  }

  Future<void> getProduct(int index) async {
    if (controllers[index].text.isEmpty || controllers[index].text.length < 2) {
      productSubjects[index].add(null);
    } else {
      Product? product = await FirebaseController.getProduct(controllers[index].text);
      productSubjects[index].add(product);
    }
    Get.overlayContext?.loaderOverlay.hide();
    validateForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'กรอกรายละเอียดป้าย ${widget.sigange.size.asString} ${widget.sigange.type.asString} ${widget.sigange.discountTag ? 'ตัดราคา' : ''} ${!widget.sigange.headerLogo ? 'ไม่เอาหัว' : ''}',
          style: TextStyle(fontSize: 16.sp),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < max(widget.sigange.type.index + 1, widget.sigange.listProduct.length); i++)
                    _buildProductInputRow(i),
                  SizedBox(height: 20.sp),
                ],
              ),
            ),
          ),
          CustomNumericKeyboard(
            onKeyPressed: (key) {
              if (_selectedTextFieldIndex != -1) {
                setState(() {
                  TextEditingController controller;
                  if (_selectedTextFieldIndex < controllers.length) {
                    controller = controllers[_selectedTextFieldIndex];
                  } else {
                    int discountIndex = _selectedTextFieldIndex - controllers.length;
                    controller = discountControllers[discountIndex];
                  }
                  
                  final currentPosition = controller.selection.base.offset;
                  final textBeforeCursor = controller.text.substring(0, currentPosition);
                  final textAfterCursor = controller.text.substring(currentPosition);
                  controller.text = textBeforeCursor + key + textAfterCursor;
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: currentPosition + 1),
                  );
                  
                  if (_selectedTextFieldIndex < controllers.length) {
                    getProduct(_selectedTextFieldIndex);
                  } else {
                    validateForm();
                  }
                });
              }
            },
            onBackspace: () {
              if (_selectedTextFieldIndex != -1) {
                setState(() {
                  TextEditingController controller;
                  if (_selectedTextFieldIndex < controllers.length) {
                    controller = controllers[_selectedTextFieldIndex];
                  } else {
                    int discountIndex = _selectedTextFieldIndex - controllers.length;
                    controller = discountControllers[discountIndex];
                  }
                  
                  final currentPosition = controller.selection.base.offset;
                  if (currentPosition > 0) {
                    final textBeforeCursor = controller.text.substring(0, currentPosition - 1);
                    final textAfterCursor = controller.text.substring(currentPosition);
                    controller.text = textBeforeCursor + textAfterCursor;
                    controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: currentPosition - 1),
                    );
                    
                    if (_selectedTextFieldIndex < controllers.length) {
                      getProduct(_selectedTextFieldIndex);
                    } else {
                      validateForm();
                    }
                  }
                });
              }
            },
            onPressBack: _showChangeFormConfirmation,
            onPressSave: _saveSignage,
            isShowDot: _selectedTextFieldIndex >= controllers.length,
          ),
        ],
      ),
   
    );
  }

  Widget _buildProductInputRow(int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: index % 2 != 0 ? Colors.red.withOpacity(0.05): null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${index + 1}. ', style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              Expanded(
                child: TextField(
                  autofocus: false,
                  focusNode: controllerFocusNodes[index],
                  controller: controllers[index],
                  textAlign: TextAlign.center,
                  readOnly: true,
                  showCursor: true,
                  cursorColor: Colors.red,
                  keyboardType: TextInputType.number,
                  /* maxLength: 14, */
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    /* LengthLimitingTextInputFormatter(14), */
                  ],
                  maxLength: 14,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    isDense: true,
                    counterText: "",
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    hintText: "กรอกรหัสสินค้า",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black26,
                    ),
                  ),
                  onChanged: (value) {
                    getProduct(index);
                    validateForm();
                  },
                  onTap: () {
                    setState(() {
                      _selectedTextFieldIndex = index;
                    });
                    FocusScope.of(context).requestFocus(controllerFocusNodes[index]);
                  },
                ),
              ),
              IconButton(
                onPressed: () => _scanBarcode(index),
                icon: SvgPicture.asset(
                  'assets/icon/barcode_scanner_64dp_5F6368_FILL0_wght400_GRAD0_opsz48.svg',
                  width: 30.sp,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_outlined, color: Colors.red,),
                onPressed: () {
                  _showFavoriteItems(context, controllers[index], index);
                  FocusScope.of(Get.context!).unfocus();
                },
              ),
            ],
          ),
          Obx(() => errorMessagesProduct[index].value.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  errorMessagesProduct[index].value,
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
              )
            : const SizedBox.shrink(),
          ),
          _buildProductInfo(index),
          if (widget.sigange.discountTag) _buildDiscountInput(index),
        ],
      ),
    );
  }

  Widget _buildProductInfo(int index) {
    return StreamBuilder<Product?>(
      stream: productSubjects[index].stream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${snapshot.data!.art} ',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: Colors.red,
                        ),
                      ),
                      TextSpan(
                        text: snapshot.data!.dscr,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!SignageController.favoriteItems.any((product) => product.art == snapshot.data?.art)) ...[
                  IconButton(
                    onPressed: () {
                      MyAlertDialog.showDefaultDialog(
                        title: 'บันทึกรายการที่ใช้บ่อย',
                        content: 'รหัส ${snapshot.data?.art}\n${snapshot.data?.dscr}\nต้องการบันทึกสินค้าหรือไม่',
                        isNoButton: true,
                        onPressYes: () async {
                          if (snapshot.data != null) {
                            Get.back();
                            Get.overlayContext?.loaderOverlay.show();
                            await SignageController.insertFavoriteItem(
                              Product(art: snapshot.data!.art, dscr: snapshot.data!.dscr, price: snapshot.data!.price)
                            );
                            await SignageController.getFavoriteItemListByDeviceId();
                            setState(() {});
                            Get.overlayContext?.loaderOverlay.hide();
                          }
                        }
                      );
                    }, 
                    icon: const Icon(Icons.favorite_border),
                  )
                ]
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildDiscountInput(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('ตัดราคา จาก '),
            Expanded(
              child: TextField(
                autofocus: false,
                focusNode: discountControllerFocusNodes[index],
                controller: discountControllers[index],
                textAlign: TextAlign.center,
                readOnly: true,
                showCursor: true,
                cursorColor: Colors.red,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(14),
                  FilteringTextInputFormatter.digitsOnly,
                  PriceInputFormatter(_numberFormat)
                ],
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  isDense: true,
                  counterText: "",
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white60,
                  ),
                ),
                onChanged: (value) => validateForm(),
                onTap: () {
                  setState(() {
                    _selectedTextFieldIndex = controllers.length + index;
                  });
                  FocusScope.of(context).requestFocus(discountControllerFocusNodes[index]);
                },
              ),
            ),
            StreamBuilder<Product?>(
              stream: productSubjects[index].stream,
              builder: (context, snapshot) {
                final priceFormat = NumberFormat('#,##0.00', 'th_TH');
                if (snapshot.hasData && snapshot.data != null) {
                  String formattedPrice = '';
                  try {
                    final price = double.parse(snapshot.data!.price);
                    formattedPrice = priceFormat.format(price);
                  } catch (e) {
                    debugPrint('เกิดข้อผิดพลาดในการแปลงราคา: $e');
                  }
                  return Text('เหลือ  $formattedPrice');
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
        Obx(() => errorMessagesDiscountTag[index].value.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                errorMessagesDiscountTag[index].value,
                style: TextStyle(color: Colors.red, fontSize: 14.sp),
              ),
            )
          : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Future<void> _scanBarcode(int index) async {
    String? barcode = await BarcodeService.scanAndConvertV2();
    if (barcode != null && barcode.isNotEmpty) {
      controllers[index].text = barcode;
      getProduct(index);
    }
  }

  void _showFavoriteItems(BuildContext context, TextEditingController controller, int index) {
    FocusScope.of(context).unfocus();

    Get.dialog(
      AlertDialog(
        title: const Center(child: Text('รายการที่ใช้บ่อย')),
        content: SizedBox(
          height: Get.height * 60 / 100,
          width: double.maxFinite,
          child: Obx(() {
            if (SignageController.isLoadingFavorites.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (SignageController.favoriteItems.isEmpty) {
              return const Center(child: Text('ไม่มีรายการโปรด'));
            } else {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: SignageController.favoriteItems.length,
                itemBuilder: (context, i) {
                  final favoriteItem = SignageController.favoriteItems[i];
                  return Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(favoriteItem.art),
                              subtitle: Text(favoriteItem.dscr),
                              onTap: () async {
                                Get.overlayContext?.loaderOverlay.show();
                                controller.text = favoriteItem.art;
                                await getProduct(index);
                                Get.back();
                              },
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              MyAlertDialog.showDefaultDialog(
                                title: 'ลบรายการโปรด',
                                content: 'รหัส ${favoriteItem.art}\n${favoriteItem.dscr}\nต้องการลบสินค้านี้หรือไม่',
                                isNoButton: true,
                                onPressYes: () async {
                                  Get.overlayContext?.loaderOverlay.show();
                                  await SignageController.deleteFavoriteItemsByArticle(favoriteItem.art);
                                  Get.overlayContext?.loaderOverlay.hide();
                                  Get.back();
                                },
                              );
                            },
                            icon: const Icon(Icons.delete_rounded, color: Colors.red,),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black12,),
                    ],
                  );
                },
              );
            }
          }),
        ),
        actions: [
          AlcMobileButton(
            text: 'ปิด',
            onPressed: () => Get.back(),
          )
        ],
      ),
    );

    SignageController.getFavoriteItemListByDeviceId();
  }

  void _showChangeFormConfirmation() {
    MyAlertDialog.showDefaultDialog(
      title: 'ยกเลิกรายการนี้',
      content: 'ต้องการยกเลิกป้ายนี้หรือไม่',
      isNoButton: true,
      textNo: 'ไม่',
      textYes: 'ตกลง',
      onPressYes: () {
        Get.back();
        Get.back();
      },
    );
  }

  Future<void> _saveSignage() async {
    validateForm();
    if (!isFormValid) {
      MyAlertDialog.showDefaultDialog(
        title: 'ข้อมูลไม่ถูกต้อง',
        content: 'กรุณาตรวจสอบข้อมูลและกรอกให้ครบถ้วน',
      );
      return;
    }
    Get.context!.loaderOverlay.show();
    List<SignageProduct> products = [];
    for (int i = 0; i < max(widget.sigange.type.index + 1, widget.sigange.listProduct.length); i++) {
      if (controllers[i].text.isNotEmpty) {
        double? originalPrice;
        if (widget.sigange.discountTag && discountControllers[i].text.isNotEmpty) {
          originalPrice = getPrice(discountControllers[i].text);
        }
        
        products.add(SignageProduct(
          art: productSubjects[i].hasValue ? productSubjects[i].value?.art ?? '' : '',
          dscr: productSubjects[i].hasValue ? productSubjects[i].value?.dscr ?? '' : '',
          displayPrice: productSubjects[i].hasValue
              ? double.tryParse(productSubjects[i].value?.price ?? '0') ?? 0
              : 0,
          originalPrice: originalPrice,
        ));
      }
    }

    if (widget.sigange.id.isNotEmpty && widget.sigange.txnId.isNotEmpty) {
      // Update existing signage
      Signage updatedSignage = Signage(
        id: widget.sigange.id,
        txnId: widget.sigange.txnId,
        size: widget.sigange.size,
        type: widget.sigange.type,
        discountTag: widget.sigange.discountTag,
        headerLogo: widget.sigange.headerLogo,
        listProduct: products,
        created: widget.sigange.created,
      );
      await SignageController.updateSignage(updatedSignage);
    } else {
      // Insert new signage
      Signage newSignage = Signage(
        id: const Uuid().v4(),
        txnId: widget.sigange.txnId,
        size: widget.sigange.size,
        type: widget.sigange.type,
        discountTag: widget.sigange.discountTag,
        headerLogo: widget.sigange.headerLogo,
        listProduct: products,
        created: DateTime.now(),
      );
      await SignageController.insertSignage(newSignage);
    }

    await SignageController.to.getSignagesList([widget.sigange.txnId]);
    Get.context!.loaderOverlay.hide();
    Get.back();

    for (var controller in controllers) {
      controller.clear();
    }
    for (var controller in discountControllers) {
      controller.clear();
    }
    for (var subject in productSubjects) {
      subject.add(null);
    }
  }
}