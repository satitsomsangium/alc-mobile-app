import 'package:get/get.dart';

class DownloadProgress extends GetxController {
  final RxDouble progress = 0.0.obs;
  final RxString currentOperation = ''.obs;

  void updateProgress(double value, String operation) {
    progress.value = value;
    currentOperation.value = operation;
  }
}