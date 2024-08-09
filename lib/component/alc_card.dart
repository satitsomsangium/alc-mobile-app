import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlcCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? padding;
  final Color? color;
  const AlcCard({
    super.key, 
    this.child, 
    this.padding, 
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(8.sp),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16.sp),
      ),
      child: child,
    );
  }
}