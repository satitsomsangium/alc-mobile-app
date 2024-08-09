import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlcMobileButton extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;
  final String text;
  final bool enable;
  final MaterialColor? color;
  final Size size;
  const AlcMobileButton({
    super.key, 
    required this.text, 
    required this.onPressed, 
    this.onLongPressed,
    this.color, 
    this.enable = true,
    this.size = const Size(70, 50)
  });

  @override
  State<AlcMobileButton> createState() => _AlcMobileButtonState();
}

class _AlcMobileButtonState extends State<AlcMobileButton> {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.enable ? 1.0 : 0.5,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(widget.color ?? Colors.red),
          elevation: WidgetStateProperty.all(0),
          minimumSize: WidgetStateProperty.all(Size(widget.size.width.w, widget.size.height.w))
        ),
        onPressed: widget.enable ? widget.onPressed : null,
        onLongPress: widget.onLongPressed,
        child: Text(widget.text)
      ),
    );
  }
}