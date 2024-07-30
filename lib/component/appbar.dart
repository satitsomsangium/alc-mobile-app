import 'package:flutter/material.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Widget popupMenu;
  final Color color1;
  final Color color2;

  const MyAppBar({
    required this.title,
    required this.popupMenu,
    required this.color1,
    required this.color2,
    super.key,
  })  : preferredSize = const Size.fromHeight(60.0);

  @override
  final Size preferredSize;

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [widget.popupMenu],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [widget.color1, widget.color2],
          ),
        ),
      ),
    );
  }
}