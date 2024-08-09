import 'package:flutter/material.dart';

class AlcPadding extends StatelessWidget {
  final Widget child;
  const AlcPadding({super.key, required this.child });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}