import 'package:flutter/material.dart';

class AlcMobileButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool enable;
  final MaterialColor? color;
  const AlcMobileButton({super.key, required this.text, required this. onPressed, this.color, this.enable = true });

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
          elevation: WidgetStateProperty.all(0)
        ),
        onPressed: widget.enable ? widget.onPressed : null,
        child: Text(widget.text)
      ),
    );
  }
}