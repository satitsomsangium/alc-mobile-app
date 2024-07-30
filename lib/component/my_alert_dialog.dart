import 'package:flutter/material.dart';

class MyAlertDialog {
  final BuildContext context;
  final String title;
  final String content;
  final String okButtonText;
  final String? cancelButtonText;
  final bool cancelButtonVisible;
  final bool barrierDismissible;
  final VoidCallback? okCallback;
  final VoidCallback? cancelCallback;
  final Widget? contentWidget;

  MyAlertDialog.showAlertDialog({
    required this.context,
    required this.title,
    required this.content,
    required this.okButtonText,
    this.cancelButtonVisible = false,
    this.cancelButtonText,
    this.okCallback,
    this.cancelCallback,
    this.barrierDismissible = true,
    this.contentWidget,
  }) {
    _showAlertDialog();
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 10),
              contentWidget ?? Text(content, style: TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (cancelButtonVisible)
                  _buildButton(
                    text: cancelButtonText!,
                    onPressed: cancelCallback ?? () => Navigator.pop(context),
                  ),
                SizedBox(width: 10),
                _buildButton(
                  text: okButtonText,
                  onPressed: okCallback,
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _buildButton({required String text, VoidCallback? onPressed}) {
    return ElevatedButton(
      style: _buttonStyle(),
      onPressed: onPressed,
      child: SizedBox(
        width: 60,
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _buttonTextStyle(),
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(75),
          side: BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  TextStyle _buttonTextStyle() {
    return TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
  }

  MyAlertDialog.loadingDialog({
    required this.context,
    required this.title,
    required this.content,
    required this.okButtonText,
    this.cancelButtonText,
    this.cancelButtonVisible = false,
    this.okCallback,
    this.cancelCallback,
    this.barrierDismissible = true,
    this.contentWidget,
  }) {
    _showLoadingDialog();
  }

  void _showLoadingDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Wrap(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  width: 150,
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(content, style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  MyAlertDialog.checkQuantityDialog({
    required this.context,
    required this.title,
    required this.content,
    required this.okButtonText,
    this.cancelButtonText,
    this.cancelButtonVisible = false,
    this.okCallback,
    this.cancelCallback,
    this.barrierDismissible = true,
    this.contentWidget,
  }) {
    _showCheckQuantityDialog();
  }

  void _showCheckQuantityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Wrap(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  width: 180,
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title),
                      SizedBox(height: 20),
                      _buildButton(
                        text: 'ตกลง',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  MyAlertDialog.showAlertDialogWithWidgetContent({
    required this.context,
    required this.title,
    required this.contentWidget,
    required this.okButtonText,
    this.cancelButtonVisible = false,
    this.cancelButtonText,
    this.cancelCallback,
    this.okCallback,
    this.barrierDismissible = true,
    this.content = ''
  }) {
    _showAlertDialogWithWidgetContent();
  }

  void _showAlertDialogWithWidgetContent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 20),
              contentWidget!,
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (cancelButtonVisible)
                  _buildButton(
                    text: cancelButtonText!,
                    onPressed: cancelCallback,
                  ),
                SizedBox(width: 10),
                _buildButton(
                  text: okButtonText,
                  onPressed: okCallback,
                ),
              ],
            )
          ],
        );
      },
    );
  }

  MyAlertDialog.showAlertDialogWithWidgetContentNoButtons(this.content, this.okButtonText, this.cancelButtonText, this.cancelButtonVisible, this.barrierDismissible, this.okCallback, this.cancelCallback, {
    required this.context,
    required this.title,
    required this.contentWidget,
  }) {
    _showAlertDialogWithWidgetContentNoButtons();
  }

  void _showAlertDialogWithWidgetContentNoButtons() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 20),
              contentWidget!,
            ],
          ),
        );
      },
    );
  }
}