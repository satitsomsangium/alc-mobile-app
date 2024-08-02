import 'package:alc_mobile_app/ui/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({super.key});

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
      setState(() {});
    });
    controller.repeat(reverse: false);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 500)),
      builder: (context, snapshot) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AlcMobileColors.scaffoldBackgroundColor,
              ),
            ),
            SizedBox.square(
              dimension: 120.w,
              child: CircularProgressIndicator(
                value: controller.value,
                strokeWidth: 25.w,
                color: AlcMobileColors.scaffoldBackgroundColor,
                backgroundColor: AlcMobileColors.scaffoldBackgroundColor,
                semanticsLabel: 'Linear progress indicator',
              ),
            ),
            SizedBox.square(
              dimension: 120.w,
              child: CircularProgressIndicator(
                value: controller.value,
                strokeWidth: 20.w,
                color: AlcMobileColors.primary,
                backgroundColor: AlcMobileColors.textThemeColor,
                semanticsLabel: 'Linear progress indicator',
              ),
            ),
          ],
        );
      },
    );
  }
}