import 'package:alc_mobile_app/service/barcode_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BarcodeInput extends StatefulWidget {
  final Function(String?) onPressedBuntton;
  final Function(String) onInputChange;
  const BarcodeInput({super.key, required this.onPressedBuntton ,required this.onInputChange });

  @override
  State<BarcodeInput> createState() => BarcodeInputState();
}

class BarcodeInputState extends State<BarcodeInput> {
  final FocusNode focusNode = FocusNode();
  final TextEditingController barcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              focusNode: focusNode,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLength: 14,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                isDense: true,
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(75),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                hintText: "สแกนหรือพิมพ์รหัสสินค้า",
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white60,
                ),
              ),
              controller: barcodeController,
              onChanged: (value) {
                widget.onInputChange(value);
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 45.sp,
            height: 45.sp,
            child: IconButton(
              onPressed: () async {
                String? barcodeResponseWithConvert = await BarcodeService.scanAndConvertV2();
                if (barcodeResponseWithConvert != null) {
                  widget.onPressedBuntton(barcodeResponseWithConvert);
                }
                barcodeController.clear();
                focusNode.unfocus();
              },
              icon: SvgPicture.asset(
                'assets/icon/barcode_scanner_64dp_5F6368_FILL0_wght400_GRAD0_opsz48.svg',
                width: 35.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}