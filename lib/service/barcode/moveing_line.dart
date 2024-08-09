import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MovingLine extends StatefulWidget {
  final double begin;
  final double end;
  final double leftRight;
  const MovingLine({super.key, required this.begin, required this.end, required this.leftRight });

  @override
  State<MovingLine> createState() => _MovingLineState();
}

class _MovingLineState extends State<MovingLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: widget.begin, end: widget.end).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 1,
          width: Get.width - widget.leftRight,
          margin: EdgeInsets.only(top: _animation.value),
          color: Colors.red,
        );
      },
    );
  }
}