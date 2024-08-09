import 'package:alc_mobile_app/component/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyAlertDialog {
  static showalertdialog(BuildContext context, String title, String content,
     String okbtTXT, bool cancelbtstate, String cancelbtTXT, VoidCallback okfunction) {
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
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.red),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                content,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: cancelbtstate,
                  child: AlcMobileButton(
                    text: cancelbtTXT,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ),
                const SizedBox(
                  width: 10,
                ),
                AlcMobileButton(
                  text: okbtTXT,
                  onPressed: okfunction,
                )
              ],
            )
          ],
        );
      },
    );
  }

  static loadingdialog(BuildContext context, String content) {
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
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        content,
                        style: const TextStyle(fontWeight: FontWeight.w500),
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

  static checkqtyDialog(BuildContext context, String title) {
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
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(title),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: AlcMobileButton(
                          text: 'ตกลง',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
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

  static showalertdialogWidgetContent(
      BuildContext context,
      String title,
      Widget contentwidget,
      String okbtTXT,
      bool cancelbtstate,
      String cancelbtTXT,
      VoidCallback cancelfunction,
      VoidCallback okfunction) {
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
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.red),
              ),
              const SizedBox(
                height: 20,
              ),
              contentwidget,
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: cancelbtstate,
                  child: AlcMobileButton(
                    text: cancelbtTXT,
                    onPressed: cancelfunction,
                  )
                ),
                const SizedBox(
                  width: 10,
                ),
                AlcMobileButton(
                  text: okbtTXT,
                  onPressed: okfunction,
                )
              ],
            )
          ],
        );
      },
    );
  }

  static showalertdialogWidgetContentNobtn(
    BuildContext context,
    String title,
    Widget contentwidget,
  ) {
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
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.red),
              ),
              const SizedBox(
                height: 20,
              ),
              contentwidget,
            ],
          ),
        );
      },
    );
  }

  static void showDefaultDialog({
    String? title,
    String? content,
    Widget? contentWidget,
    String? textYes,
    String? textNo,
    bool isNoButton = false,
    bool isYesButton = true,
    VoidCallback? onPressYes,
    VoidCallback? onPressNo,
    VoidCallback? onLongPressYes,
    bool barrierDismissible = true,
  }) {
    showDialog(
      barrierDismissible: barrierDismissible,
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              title ?? 'แจ้งเตือน',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.red),
            ),
          ),
          content: contentWidget ?? Text(
            content ?? 'เกิดข้อผิดพลาด',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: isNoButton ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: isNoButton,
                    child: AlcMobileButton(
                      text: textNo ?? 'ยกเลิก',
                      onPressed: onPressNo ?? () => Get.back(), 
                    )
                  ),
                  Visibility(
                    visible: isYesButton,
                    child: AlcMobileButton(
                      text: textYes ?? 'ตกลง',
                      onPressed: onPressYes ?? () => Get.back(), 
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
