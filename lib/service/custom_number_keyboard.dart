import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibration/vibration.dart';

class CustomNumericKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspace;
  final bool isShowDot;
  final VoidCallback onPressSave;
  final VoidCallback onPressBack;


  const CustomNumericKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    this.isShowDot = true,
    required this.onPressSave,
    required this.onPressBack
  });

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).size.height * 0.3;
    return Container(
      height: keyboardHeight,
      color: Colors.grey[200],
      child: Column(
        children: [
          _buildKeyboardRow(['1', '2', '3','ลบ']),
          _buildKeyboardRow(['4', '5', '6', '']),
          _buildKeyboardRow(['7', '8', '9', 'บันทึก']),
          _buildKeyboardRow([_getDotOrEmptyString(), '0', '', '']),
        ],
      ),
    );
  }

  String _getDotOrEmptyString() {
    return isShowDot ? '.' : '';
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: keys.map((key) => _buildKeyboardButton(key)).toList(),
      ),
    );
  }

  Widget _buildKeyboardButton(String key) {
    List<String> hilightKey = ['ลบ', 'บันทึก', 'กลับ'];
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: hilightKey.contains(key) ? Colors.red : Colors.white,
            foregroundColor: hilightKey.contains(key) ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            _vibrate(/* intensity: 'light' */);
            if (key == 'ลบ') {
              onBackspace();
            } else if (key == '') {
              // ไม่ทำอะไร
            } else if (key == 'บันทึก') {
              onPressSave();
            } else if (key == 'กลับ') {
              onPressBack();
            } else {
              onKeyPressed(key);
            }
          },
          child: Text(
            key,
            style: TextStyle(fontSize: 24.sp),
          ),
        ),
      ),
    );
  }

  void _vibrate() async {
    if (Platform.isAndroid) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 5, amplitude: 128);
      }
    }
  }
}