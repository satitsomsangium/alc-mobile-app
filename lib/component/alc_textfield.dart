import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlcTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  const AlcTextField({super.key, 
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(fontSize: 18.sp),
      textInputAction: textInputAction,
      obscureText: obscureText,
      textAlign: TextAlign.center,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Colors.black54),
        labelText: labelText,
        contentPadding: const EdgeInsets.fromLTRB(15, 8, 15, 12),
        isDense: true,
        counterText: "",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(75),
          borderSide: const BorderSide(
            width: 1,
            color: Colors.black26,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(75),
          borderSide: const BorderSide(
            width: 1,
            color: Colors.black45,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(
            fontWeight: FontWeight.w700, color: Colors.white60),
      ),
      controller: controller,
    );
  }
}