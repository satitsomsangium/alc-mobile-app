import 'dart:async';

import 'package:alc_mobile_app/service/barcode/barcode_scanner_overlay.dart';
import 'package:alc_mobile_app/service/barcode/moveing_line.dart';
import 'package:alc_mobile_app/service/barcode/scanner_button_widgets.dart';
import 'package:alc_mobile_app/service/barcode/scanner_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState
    extends State<BarcodeScannerPage> with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    autoStart: false,
    useNewCameraSelector: true,
  );

  Barcode? _barcode;
  StreamSubscription<Object?>? _subscription;

  bool isHandled = false;

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
      });
      final String? code = _barcode?.rawValue;
      if (code != null && !isHandled) {
        debugPrint("Scanned code: $code");
        isHandled = true;
        Get.back(result: code);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen(_handleBarcode);
    unawaited(controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = controller.barcodes.listen(_handleBarcode);
        unawaited(controller.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: 380,
      height: 200,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            errorBuilder: (context, error, child) {
              return ScannerErrorWidget(error: error);
            },
            fit: BoxFit.contain,
          ),
          Positioned(
            left: scanWindow.left,
            child: MovingLine(begin: scanWindow.top, end: scanWindow.bottom, leftRight: scanWindow.left * 2,)),
          Positioned(
            top: scanWindow.top,
            left: scanWindow.left,
            child: Container(
              width: 380,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 0.1)
              ),
            ),
          ),
          _buildScanWindow(scanWindow),
          Positioned(
            bottom: 0,
            child: Container(
              width: Get.width,
              color: Colors.black,
              padding: EdgeInsets.all(24.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: ToggleFlashlightButton(controller: controller)),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: SwitchCameraButton(controller: controller)),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: AnalyzeImageFromGalleryButton(controller: controller)),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: () => Get.back(), 
                      icon: const Icon(Icons.cancel),
                      iconSize: 32,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanWindow(Rect scanWindowRect) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized ||
            !value.isRunning ||
            value.error != null ||
            value.size.isEmpty) {
          return const SizedBox();
        }

        return CustomPaint(
          painter: ScannerOverlay(scanWindowRect),
        );
      },
    );
  }
}

