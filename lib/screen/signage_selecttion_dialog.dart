import 'package:alc_mobile_app/component/button.dart';
import 'package:alc_mobile_app/model/signage_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignageSelectionDialog extends StatefulWidget {
  final Function(SignageSize size, SignageType type, bool headerLogo, bool discountTag) onSignageSelected;

  const SignageSelectionDialog({super.key, required this.onSignageSelected});

  @override
  State<SignageSelectionDialog> createState() => _SignageSelectionDialogState();
}

class _SignageSelectionDialogState extends State<SignageSelectionDialog> {
  bool isVisible = true;
  SignageSize? selectedSize;
  SignageType? selectedType;
  bool headerLogo = true;
  bool discountTag = false;

  bool _shouldShowSize(SignageSize size) {
    if (selectedType == null) return true;
    if (selectedType == SignageType.d1) return true;
    if (selectedType == SignageType.d2) return size != SignageSize.a6;
    return size == SignageSize.a3 || size == SignageSize.a4;
  }

  bool _shouldShowType(SignageType type) {
    if (selectedSize == null) return true;
    if (selectedSize == SignageSize.a3 || selectedSize == SignageSize.a4) return true;
    if (selectedSize == SignageSize.a5) return type == SignageType.d1 || type == SignageType.d2;
    if (selectedSize == SignageSize.a6) return type == SignageType.d1;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Expanded(child: SizedBox()),
        AlertDialog(
          content: SizedBox(
            width: Get.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'เลือกขนาดป้าย',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                          ),
                        ),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8.sp,
                  runSpacing: 8.sp,
                  children: SignageSize.values.where(_shouldShowSize).map((size) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSize = size;
                          if (selectedType != null && !_shouldShowType(selectedType!)) {
                            selectedType = null;
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedSize == size ? Colors.red : null,
                          borderRadius: BorderRadius.circular(50.sp)
                        ),
                        width: 50.sp,
                        height: 50.sp,
                        child: Center(
                          child: Text(
                            size.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16.sp, 
                              fontWeight: FontWeight.w500,
                              color: selectedSize == size ? Colors.white : null
                            ),
                          )
                        )
                      ),
                    );
                  }).toList(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'เลือก จำนวน item',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                          ),
                        ),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8.sp,
                  runSpacing: 8.sp,
                  children: SignageType.values.where(_shouldShowType).map((type) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = type;
                          if (selectedSize != null && !_shouldShowSize(selectedSize!)) {
                            selectedSize = null;
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedType == type ? Colors.red : null,
                          borderRadius: BorderRadius.circular(50)
                        ),
                        width: 50.sp,
                        height: 50.sp,
                        child: Center(
                          child: Text(
                            type.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: selectedType == type ? Colors.white : null
                            ),
                          )
                        )
                      ),
                    );
                  }).toList(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.sp),
                  child: Text('อื่น ๆ', style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp
                    )
                  )
                ),
                CheckboxListTile(
                  title: const Text('เอาหัวป้าย'),
                  value: headerLogo,
                  onChanged: (bool? value) {
                    setState(() {
                      headerLogo = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('ตัดราคา'),
                  value: discountTag,
                  onChanged: (bool? value) {
                    setState(() {
                      discountTag = value!;
                    });
                  },
                ),
                AlcMobileButton(
                  enable: selectedSize != null && selectedType != null,
                  color: Colors.red,
                  text: 'เพิ่ม',
                  onPressed: () {
                    if (selectedSize != null && selectedType != null) {
                      Get.back();
                      widget.onSignageSelected(selectedSize!, selectedType!, headerLogo, discountTag);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}